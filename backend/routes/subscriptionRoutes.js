import express from 'express';
import { createSubscription } from '../controllers/subscriptionController.js';
import { protect } from '../middleware/authMiddleware.js';

const router = express.Router();

// POST /subscriptions/create
router.post('/create', protect, createSubscription);

export default router;
