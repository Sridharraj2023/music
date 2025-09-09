import Stripe from 'stripe';
import User from '../models/userModel.js';

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

export const handleWebhook = async (req, res) => {
  const sig = req.headers['stripe-signature'];
  const endpointSecret = process.env.STRIPE_WEBHOOK_SECRET;
  let event;

  try {
    event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      endpointSecret
    );
  } catch (err) {
    console.error(`Webhook signature verification failed: ${err.message}`);
    return res.status(400).send(`Webhook Error: ${err.message}`);
  }

  // Handle the event
  switch (event.type) {
    case 'payment_intent.succeeded':
      const paymentIntent = event.data.object;
      console.log('PaymentIntent was successful!', paymentIntent.id);
      break;
      
    case 'payment_intent.payment_failed':
      const paymentFailed = event.data.object;
      console.log('Payment failed:', paymentFailed.id);
      // Handle failed payment
      break;
      
    case 'customer.subscription.created':
      const subscriptionCreated = event.data.object;
      console.log('Subscription created:', subscriptionCreated.id);
      await User.findOneAndUpdate(
        { stripeCustomerId: subscriptionCreated.customer },
        { 
          'subscription.status': subscriptionCreated.status,
          'subscription.currentPeriodEnd': new Date(subscriptionCreated.current_period_end * 1000)
        }
      );
      break;
      
    case 'customer.subscription.updated':
      const subscriptionUpdated = event.data.object;
      console.log('Subscription updated:', subscriptionUpdated.id);
      await User.findOneAndUpdate(
        { stripeCustomerId: subscriptionUpdated.customer },
        { 
          'subscription.status': subscriptionUpdated.status,
          'subscription.currentPeriodEnd': new Date(subscriptionUpdated.current_period_end * 1000)
        }
      );
      break;
      
    case 'customer.subscription.deleted':
      const subscriptionDeleted = event.data.object;
      console.log('Subscription deleted:', subscriptionDeleted.id);
      await User.findOneAndUpdate(
        { stripeCustomerId: subscriptionDeleted.customer },
        { 
          'subscription.status': 'canceled',
          'subscription.currentPeriodEnd': null
        }
      );
      break;
      
    case 'invoice.payment_succeeded':
      const invoicePaid = event.data.object;
      console.log('Invoice paid:', invoicePaid.id);
      // Update user subscription status to active
      await User.findOneAndUpdate(
        { stripeCustomerId: invoicePaid.customer },
        { 
          'subscription.status': 'active',
          'subscription.currentPeriodEnd': new Date(invoicePaid.period_end * 1000)
        }
      );
      break;
      
    case 'invoice.payment_failed':
      const invoiceFailed = event.data.object;
      console.log('Invoice payment failed:', invoiceFailed.id);
      // Update user subscription status to past_due
      await User.findOneAndUpdate(
        { stripeCustomerId: invoiceFailed.customer },
        { 
          'subscription.status': 'past_due'
        }
      );
      break;
      
    default:
      console.log(`Unhandled event type ${event.type}`);
  }

  // Return a 200 response to acknowledge receipt of the event
  res.json({ received: true });
};

// GET /subscriptions/status - Get current subscription status
export const getSubscriptionStatus = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    if (!userId) {
      return res.status(401).json({ message: 'Not authenticated' });
    }

    const user = await User.findById(userId);
    if (!user || !user.subscription || !user.subscription.id) {
      return res.json({
        subscription: null
      });
    }

    // Get latest subscription data from Stripe
    const subscription = await stripe.subscriptions.retrieve(user.subscription.id);

    return res.json({
      subscription: {
        id: subscription.id,
        status: subscription.status,
        currentPeriodStart: subscription.current_period_start,
        currentPeriodEnd: subscription.current_period_end,
        cancelAtPeriodEnd: subscription.cancel_at_period_end,
        plan: subscription.items.data[0]?.price?.id
      }
    });
  } catch (error) {
    console.error('Error fetching subscription status:', error);
    return res.status(500).json({ 
      message: 'Failed to fetch subscription status',
      error: error.message 
    });
  }
};

// POST /subscriptions/confirm - Manually confirm payment and activate subscription
export const confirmPayment = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    if (!userId) {
      return res.status(401).json({ message: 'Not authenticated' });
    }

    const user = await User.findById(userId);
    if (!user || !user.subscription || !user.subscription.id) {
      return res.status(404).json({ 
        message: 'No subscription found' 
      });
    }

    // Get subscription from Stripe
    const subscription = await stripe.subscriptions.retrieve(user.subscription.id);
    
    // Check if payment was successful
    if (subscription.status === 'active' || subscription.status === 'trialing') {
      // Update user subscription status
      user.subscription.status = subscription.status;
      user.subscription.currentPeriodEnd = new Date(subscription.current_period_end * 1000);
      await user.save();

      return res.json({
        message: 'Subscription confirmed and activated',
        subscription: {
          id: subscription.id,
          status: subscription.status,
          currentPeriodEnd: subscription.current_period_end
        }
      });
    } else {
      return res.status(400).json({
        message: 'Subscription is not active yet',
        status: subscription.status
      });
    }
  } catch (error) {
    console.error('Error confirming payment:', error);
    return res.status(500).json({ 
      message: 'Failed to confirm payment',
      error: error.message 
    });
  }
};

// POST /subscriptions/cancel - Cancel subscription at period end
export const cancelSubscription = async (req, res) => {
  try {
    const userId = req.user && req.user._id;
    if (!userId) {
      return res.status(401).json({ message: 'Not authenticated' });
    }

    const user = await User.findById(userId);
    if (!user || !user.subscription || !user.subscription.id) {
      return res.status(404).json({ 
        message: 'No active subscription found' 
      });
    }

    // Cancel subscription at period end
    const subscription = await stripe.subscriptions.update(user.subscription.id, {
      cancel_at_period_end: true
    });

    // Update user subscription status
    user.subscription.status = subscription.status;
    user.subscription.cancelAtPeriodEnd = subscription.cancel_at_period_end;
    await user.save();

    return res.json({
      message: 'Subscription will be canceled at the end of the current period',
      subscription: {
        id: subscription.id,
        status: subscription.status,
        cancelAtPeriodEnd: subscription.cancel_at_period_end
      }
    });
  } catch (error) {
    console.error('Error canceling subscription:', error);
    return res.status(500).json({ 
      message: 'Failed to cancel subscription',
      error: error.message 
    });
  }
};

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
        expand: ['latest_invoice.payment_intent'],
        collection_method: 'charge_automatically'
      });

      console.log('Subscription created:', {
        id: subscription.id,
        status: subscription.status,
        latest_invoice: subscription.latest_invoice,
        payment_intent: subscription.latest_invoice?.payment_intent
      });
      
      // Debug: Check if payment intent exists
      if (subscription.latest_invoice?.payment_intent) {
        console.log('Payment intent found:', subscription.latest_invoice.payment_intent);
      } else {
        console.log('No payment intent in subscription.latest_invoice');
      }

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
          console.log('Payment intent created:', paymentIntent);
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
      const responseData = {
        subscription: {
          clientSecret: clientSecret
        }
      };
      
      console.log('Returning to client:', responseData);
      
      return res.json(responseData);
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
