const Stripe = require('stripe');

// Initialize Stripe with secret key
const stripe = Stripe(process.env.STRIPE_SECRET_KEY);

// Stripe configuration
const stripeConfig = {
  plans: {
    basic: {
      name: 'Basic Plan',
      price: 5.00,
      priceId: process.env.STRIPE_BASIC_PLAN_PRICE_ID || 'price_basic_plan_id_here',
      features: ['Basic audio quality', 'Limited downloads', 'Ad-supported']
    },
    premium: {
      name: 'Premium Plan',
      price: 15.00,
      priceId: process.env.STRIPE_PREMIUM_PLAN_PRICE_ID || 'price_premium_plan_id_here',
      features: ['High quality audio', 'Unlimited downloads', 'No ads', 'Binaural tracks']
    },
    pro: {
      name: 'Pro Plan',
      price: 25.00,
      priceId: process.env.STRIPE_PRO_PLAN_PRICE_ID || 'price_pro_plan_id_here',
      features: ['Premium audio quality', 'Unlimited downloads', 'No ads', 'All binaural tracks', 'Custom requests']
    }
  }
};

// Stripe helper functions
const stripeHelpers = {
  // Create a new Stripe customer
  async createCustomer(email, name) {
    try {
      const customer = await stripe.customers.create({
        email: email,
        name: name,
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

  // Get subscription details
  async getSubscription(subscriptionId) {
    try {
      const subscription = await stripe.subscriptions.retrieve(subscriptionId);
      return subscription;
    } catch (error) {
      console.error('Error retrieving subscription:', error);
      throw error;
    }
  },

  // Cancel subscription
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

  // Verify webhook signature
  verifyWebhookSignature(payload, signature) {
    try {
      const event = stripe.webhooks.constructEvent(
        payload,
        signature,
        process.env.STRIPE_WEBHOOK_SECRET
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
