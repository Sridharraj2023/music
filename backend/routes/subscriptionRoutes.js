import express from 'express';
import { createSubscription, handleWebhook, getSubscriptionStatus, cancelSubscription, confirmPayment, updateSubscriptionPaymentMethod, fixSubscriptionStatus } from '../controllers/subscriptionController.js';
import { protect } from '../middleware/authMiddleware.js';

const router = express.Router();

// POST /subscriptions/create
router.post('/create', protect, createSubscription);

// GET /subscriptions/status - Get current subscription status
router.get('/status', protect, getSubscriptionStatus);

// POST /subscriptions/cancel - Cancel subscription at period end
router.post('/cancel', protect, cancelSubscription);

// POST /subscriptions/update-payment-method - Update subscription with payment method from payment intent
router.post('/update-payment-method', protect, updateSubscriptionPaymentMethod);

// POST /subscriptions/fix-status - Manually fix subscription status based on successful charge
router.post('/fix-status', protect, fixSubscriptionStatus);

// POST /subscriptions/confirm - Manually confirm payment and activate subscription
router.post('/confirm', protect, confirmPayment);

// Stripe webhook endpoint - must be raw body for signature verification
router.post('/webhook', 
  express.raw({type: 'application/json'}), 
  handleWebhook
);

export default router;
