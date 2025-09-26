import express from 'express';
import { createSetupIntent } from '../controllers/subscriptionController.js';
import { protect } from '../middleware/authMiddleware.js';

const router = express.Router();

// POST /payments/setup-intent - Create SetupIntent for payment method collection
router.post('/setup-intent', protect, createSetupIntent);

export default router;
