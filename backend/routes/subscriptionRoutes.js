import express from 'express';
import { createSubscription, handleWebhook, getSubscriptionStatus, cancelSubscription } from '../controllers/subscriptionController.js';
import { protect } from '../middleware/authMiddleware.js';

const router = express.Router();

// POST /subscriptions/create
router.post('/create', protect, createSubscription);

// GET /subscriptions/status - Get current subscription status
router.get('/status', protect, getSubscriptionStatus);

// POST /subscriptions/cancel - Cancel subscription at period end
router.post('/cancel', protect, cancelSubscription);

// Stripe webhook endpoint - must be raw body for signature verification
router.post('/webhook', 
  express.raw({type: 'application/json'}), 
  handleWebhook
);

export default router;
