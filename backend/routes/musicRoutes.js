// import express from 'express';
// import { getMusic, createMusic } from '../controllers/musicController.js';
// import { protect } from '../middleware/authMiddleware.js';
// import { adminOnly } from '../middleware/adminMiddleware.js';
// import { upload } from '../middleware/uploadMiddleware.js';


// const router = express.Router();

// router.get('/', getMusic); 
// router.post('/create', protect, adminOnly, upload.single('file'), createMusic);

// export default router;

import express from 'express';
import { getMusic, createMusic,updateMusic, deleteMusic } from '../controllers/musicController.js';
import { protect } from '../middleware/authMiddleware.js';
import { adminOnly } from '../middleware/adminMiddleware.js';

import upload  from '../middleware/uploadMiddleware.js';

const router = express.Router();

router.get('/', getMusic); // Public access
// Change the route to:
router.post(
    '/create',
    protect,
    adminOnly,
    (req, res, next) => {
      upload(req, res, (err) => {
        if (err) {
          return res.status(400).json({ message: 'File upload error' });
        }
        next();
      });
    },
    createMusic
  );
  // Ensure routes are properly defined
router.route('/:id')
.delete(protect, adminOnly, deleteMusic)
.put(protect, adminOnly, upload, updateMusic); // Include upload middleware for updates

export default router;