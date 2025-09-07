import Stripe from 'stripe';
import User from '../models/userModel.js';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

// POST /subscriptions/create
export const createSubscription = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    if (!userId) {
      return res.status(401).json({ message: 'Not authenticated' });
    }

    // Find user
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }

    // Price ID for $5/month plan (from .env)
    const priceId = process.env.STRIPE_PRICE_ID;
    if (!priceId) {
      return res.status(500).json({ message: 'Stripe price ID not configured' });
    }

    // Create Stripe customer if not exists
    let stripeCustomerId = user.stripeCustomerId;
    if (!stripeCustomerId) {
      const customer = await stripe.customers.create({
        email: user.email,
        name: user.name,
      });
      stripeCustomerId = customer.id;
      user.stripeCustomerId = stripeCustomerId;
      await user.save();
    }

    try {
      console.log('Creating subscription with price ID:', priceId);
      
      // Create subscription with payment settings
      const subscription = await stripe.subscriptions.create({
        customer: stripeCustomerId,
        items: [{ price: priceId }],
        payment_behavior: 'default_incomplete',
        payment_settings: {
          payment_method_types: ['card'],
          save_default_payment_method: 'on_subscription'
        },
        expand: ['latest_invoice.payment_intent']
      });

      console.log('Subscription created:', {
        id: subscription.id,
        status: subscription.status,
        latest_invoice: subscription.latest_invoice,
        payment_intent: subscription.latest_invoice?.payment_intent
      });

      // Get the client secret from the subscription's payment intent
      let clientSecret = subscription.latest_invoice?.payment_intent?.client_secret;
      
      // Fallback: If no payment intent is attached, try to retrieve it from the invoice
      if (!clientSecret && subscription.latest_invoice) {
        console.log('No payment intent in subscription, retrieving from invoice...');
        const invoice = await stripe.invoices.retrieve(
          subscription.latest_invoice.id,
          { expand: ['payment_intent'] }
        );
        
        if (invoice.payment_intent) {
          console.log('Found payment intent in invoice');
          clientSecret = invoice.payment_intent.client_secret;
        } else {
          // Last resort: create a new payment intent
          console.log('Creating new payment intent for invoice');
          const paymentIntent = await stripe.paymentIntents.create({
            customer: stripeCustomerId,
            amount: invoice.amount_due,
            currency: invoice.currency,
            payment_method_types: ['card'],
            description: `Subscription creation for invoice ${invoice.id}`,
            metadata: {
              subscription_id: subscription.id,
              invoice_id: invoice.id
            }
          });
          clientSecret = paymentIntent.client_secret;
        }
      }
      
      if (!clientSecret) {
        console.error('No client secret available after fallback attempts:', {
          subscriptionId: subscription.id,
          invoiceId: subscription.latest_invoice?.id,
          paymentIntent: subscription.latest_invoice?.payment_intent
        });
        throw new Error('Failed to retrieve or create payment intent');
      }
      
      // Save subscription details to user
      user.subscription = {
        id: subscription.id,
        status: subscription.status,
        currentPeriodEnd: subscription.current_period_end
      };
      await user.save();

      // Return the client secret for the client to complete the payment
      return res.json({
        subscription: {
          clientSecret: clientSecret
        }
      });
    } catch (error) {
      console.error('Stripe subscription error:', {
        message: error.message,
        stack: error.stack,
        response: error.response?.data
      });
      return res.status(500).json({
        message: 'Failed to create subscription',
        error: error.message,
        details: error.type || 'Unknown error'
      });
    }
  } catch (error) {
    console.error('Stripe subscription error:', error);
    return res.status(500).json({ message: 'Subscription creation failed', error: error.message });
  }
};
