import express from 'express';
import { createSubscription, getSubscriptionStatus, cancelSubscription, confirmPayment, updateSubscriptionPaymentMethod, fixSubscriptionStatus, getSubscriptionDetails } from '../controllers/subscriptionController.js';
import { protect } from '../middleware/authMiddleware.js';

const router = express.Router();

// POST /subscriptions/create
router.post('/create', protect, createSubscription);

// GET /subscriptions/status - Get current subscription status
router.get('/status', protect, getSubscriptionStatus);

// GET /subscriptions/details - Get detailed subscription information including countdown
router.get('/details', protect, getSubscriptionDetails);

// POST /subscriptions/cancel - Cancel subscription at period end
router.post('/cancel', protect, cancelSubscription);

// POST /subscriptions/update-payment-method - Update subscription with payment method from payment intent
router.post('/update-payment-method', protect, updateSubscriptionPaymentMethod);

// POST /subscriptions/fix-status - Manually fix subscription status based on successful charge
router.post('/fix-status', protect, fixSubscriptionStatus);

// POST /subscriptions/confirm - Manually confirm payment and activate subscription
router.post('/confirm', protect, confirmPayment);

// Webhook is registered at app level in server.js before JSON body parsing

export default router;
