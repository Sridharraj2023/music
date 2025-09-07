const express = require('express');
const router = express.Router();
const { stripeHelpers, stripeConfig } = require('../config/stripe-config');
const auth = require('../middleware/auth');
const User = require('../models/User');

// Get subscription plans
router.get('/plans', async (req, res) => {
  try {
    const plans = Object.keys(stripeConfig.plans).map(key => ({
      id: key,
      name: stripeConfig.plans[key].name,
      price: stripeConfig.plans[key].price,
      features: stripeConfig.plans[key].features,
      priceId: stripeConfig.plans[key].priceId
    }));

    res.json({
      success: true,
      plans
    });
  } catch (error) {
    console.error('Error fetching plans:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch subscription plans'
    });
  }
});

// Create subscription
router.post('/create', auth, async (req, res) => {
  try {
    const { priceId } = req.body;
    const userId = req.user.id;

    // Get user from database
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Create or get Stripe customer
    let customerId = user.stripeCustomerId;
    if (!customerId) {
      const customer = await stripeHelpers.createCustomer(user.email, user.name);
      customerId = customer.id;
      
      // Update user with Stripe customer ID
      user.stripeCustomerId = customerId;
      await user.save();
    }

    // Create subscription
    const subscription = await stripeHelpers.createSubscription(customerId, priceId);

    // Update user subscription info
    user.subscriptionId = subscription.id;
    user.subscriptionStatus = subscription.status;
    await user.save();

    res.json({
      success: true,
      subscription: {
        id: subscription.id,
        status: subscription.status,
        clientSecret: subscription.latest_invoice.payment_intent.client_secret
      }
    });
  } catch (error) {
    console.error('Error creating subscription:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create subscription'
    });
  }
});

// Get subscription status
router.get('/status', auth, async (req, res) => {
  try {
    const userId = req.user.id;
    const user = await User.findById(userId);

    if (!user || !user.subscriptionId) {
      return res.json({
        success: true,
        subscription: null
      });
    }

    const subscription = await stripeHelpers.getSubscription(user.subscriptionId);

    res.json({
      success: true,
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
    res.status(500).json({
      success: false,
      message: 'Failed to fetch subscription status'
    });
  }
});

// Cancel subscription
router.post('/cancel', auth, async (req, res) => {
  try {
    const userId = req.user.id;
    const user = await User.findById(userId);

    if (!user || !user.subscriptionId) {
      return res.status(404).json({
        success: false,
        message: 'No active subscription found'
      });
    }

    const subscription = await stripeHelpers.cancelSubscription(user.subscriptionId);

    // Update user subscription status
    user.subscriptionStatus = subscription.status;
    await user.save();

    res.json({
      success: true,
      message: 'Subscription will be canceled at the end of the current period',
      subscription: {
        id: subscription.id,
        status: subscription.status,
        cancelAtPeriodEnd: subscription.cancel_at_period_end
      }
    });
  } catch (error) {
    console.error('Error canceling subscription:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to cancel subscription'
    });
  }
});

// Webhook endpoint for Stripe events
router.post('/webhook', express.raw({ type: 'application/json' }), async (req, res) => {
  try {
    const signature = req.headers['stripe-signature'];
    const event = stripeHelpers.verifyWebhookSignature(req.body, signature);

    switch (event.type) {
      case 'customer.subscription.created':
      case 'customer.subscription.updated':
        await handleSubscriptionUpdate(event.data.object);
        break;
      
      case 'customer.subscription.deleted':
        await handleSubscriptionDeleted(event.data.object);
        break;
      
      case 'invoice.payment_succeeded':
        await handlePaymentSucceeded(event.data.object);
        break;
      
      case 'invoice.payment_failed':
        await handlePaymentFailed(event.data.object);
        break;
      
      default:
        console.log(`Unhandled event type: ${event.type}`);
    }

    res.json({ received: true });
  } catch (error) {
    console.error('Webhook error:', error);
    res.status(400).json({
      success: false,
      message: 'Webhook signature verification failed'
    });
  }
});

// Helper functions for webhook handling
async function handleSubscriptionUpdate(subscription) {
  try {
    const user = await User.findOne({ subscriptionId: subscription.id });
    if (user) {
      user.subscriptionStatus = subscription.status;
      await user.save();
    }
  } catch (error) {
    console.error('Error handling subscription update:', error);
  }
}

async function handleSubscriptionDeleted(subscription) {
  try {
    const user = await User.findOne({ subscriptionId: subscription.id });
    if (user) {
      user.subscriptionStatus = 'canceled';
      user.subscriptionId = null;
      await user.save();
    }
  } catch (error) {
    console.error('Error handling subscription deletion:', error);
  }
}

async function handlePaymentSucceeded(invoice) {
  try {
    const user = await User.findOne({ stripeCustomerId: invoice.customer });
    if (user) {
      // Update user's subscription status
      user.subscriptionStatus = 'active';
      await user.save();
    }
  } catch (error) {
    console.error('Error handling payment success:', error);
  }
}

async function handlePaymentFailed(invoice) {
  try {
    const user = await User.findOne({ stripeCustomerId: invoice.customer });
    if (user) {
      // Update user's subscription status
      user.subscriptionStatus = 'past_due';
      await user.save();
    }
  } catch (error) {
    console.error('Error handling payment failure:', error);
  }
}

module.exports = router;
