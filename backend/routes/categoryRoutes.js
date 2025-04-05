import express from "express";
import { getCategories, createCategory,updateCategory, deleteCategory } from "../controllers/categoryController.js";
import { protect } from '../middleware/authMiddleware.js';
import { adminOnly } from '../middleware/adminMiddleware.js';

const router = express.Router();

router.get('/', getCategories); // Public access
router.post('/create', protect, adminOnly, createCategory); // Admin only
router.put('/:id', protect, adminOnly, updateCategory);
router.delete('/:id', protect, adminOnly, deleteCategory);

export default router;