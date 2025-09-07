const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

// Stripe configuration
const stripeConfig = {
  // Product and Price IDs for subscription plans
  plans: {
    basic: {
      priceId: process.env.STRIPE_BASIC_PLAN_PRICE_ID,
      name: 'Basic Plan',
      price: 9.99,
      features: ['Access to basic music library', 'Standard quality audio']
    },
    premium: {
      priceId: process.env.STRIPE_PREMIUM_PLAN_PRICE_ID,
      name: 'Premium Plan',
      price: 19.99,
      features: ['Full music library', 'High quality audio', 'Binaural beats']
    },
    pro: {
      priceId: process.env.STRIPE_PRO_PLAN_PRICE_ID,
      name: 'Pro Plan',
      price: 29.99,
      features: ['Everything in Premium', 'Custom playlists', 'Priority support']
    }
  },
  
  // Webhook configuration
  webhookSecret: process.env.STRIPE_WEBHOOK_SECRET,
  
  // Payment methods
  paymentMethods: ['card'],
  
  // Currency
  currency: 'usd',
  
  // Subscription settings
  subscriptionSettings: {
    trialPeriodDays: 7,
    cancelAtPeriodEnd: true
  }
};

// Helper functions for Stripe operations
const stripeHelpers = {
  // Create a customer
  async createCustomer(email, name) {
    try {
      const customer = await stripe.customers.create({
        email,
        name,
        metadata: {
          app: 'elevate'
        }
      });
      return customer;
    } catch (error) {
      console.error('Error creating Stripe customer:', error);
      throw error;
    }
  },

  // Create a subscription
  async createSubscription(customerId, priceId) {
    try {
      const subscription = await stripe.subscriptions.create({
        customer: customerId,
        items: [{ price: priceId }],
        payment_behavior: 'default_incomplete',
        payment_settings: { save_default_payment_method: 'on_subscription' },
        expand: ['latest_invoice.payment_intent'],
      });
      return subscription;
    } catch (error) {
      console.error('Error creating subscription:', error);
      throw error;
    }
  },

  // Cancel a subscription
  async cancelSubscription(subscriptionId) {
    try {
      const subscription = await stripe.subscriptions.update(subscriptionId, {
        cancel_at_period_end: true
      });
      return subscription;
    } catch (error) {
      console.error('Error canceling subscription:', error);
      throw error;
    }
  },

  // Get subscription status
  async getSubscription(subscriptionId) {
    try {
      const subscription = await stripe.subscriptions.retrieve(subscriptionId);
      return subscription;
    } catch (error) {
      console.error('Error retrieving subscription:', error);
      throw error;
    }
  },

  // Create payment intent
  async createPaymentIntent(amount, currency = 'usd', customerId = null) {
    try {
      const paymentIntent = await stripe.paymentIntents.create({
        amount: amount * 100, // Convert to cents
        currency,
        customer: customerId,
        metadata: {
          app: 'elevate'
        }
      });
      return paymentIntent;
    } catch (error) {
      console.error('Error creating payment intent:', error);
      throw error;
    }
  },

  // Verify webhook signature
  verifyWebhookSignature(payload, signature) {
    try {
      const event = stripe.webhooks.constructEvent(
        payload,
        signature,
        stripeConfig.webhookSecret
      );
      return event;
    } catch (error) {
      console.error('Webhook signature verification failed:', error);
      throw error;
    }
  }
};

module.exports = {
  stripe,
  stripeConfig,
  stripeHelpers
};
