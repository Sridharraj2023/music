// Load environment variables FIRST before any other imports
import dotenv from 'dotenv';
import { fileURLToPath } from 'url';
import path from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Try multiple paths to find .env file
const envPaths = [
  path.join(__dirname, '.env'),
  path.join(__dirname, '..', '.env'),
  path.join(process.cwd(), '.env'),
  path.join(process.cwd(), 'Backend-Server', 'music', 'backend', '.env')
];

console.log('Looking for .env file in:');
envPaths.forEach(envPath => {
  console.log('-', envPath);
});

// Load .env from the backend directory
const result = dotenv.config({ path: path.join(__dirname, '.env') });
if (result.error) {
  console.error('Error loading .env file:', result.error);
} else {
  console.log('.env file loaded successfully');
}

// Also try to manually read the file to verify it exists
import fs from 'fs';
try {
  const envContent = fs.readFileSync(path.join(__dirname, '.env'), 'utf8');
  console.log('Manual file read successful. First 100 chars:', envContent.substring(0, 100));
} catch (fileError) {
  console.error('Manual file read failed:', fileError.message);
}

import express from 'express';

// Debug: Check if environment variables are loaded
console.log('=== SERVER STARTUP DEBUG ===');
console.log('Environment check:');
console.log('STRIPE_SECRET_KEY:', process.env.STRIPE_SECRET_KEY ? 'Found' : 'NOT FOUND');
console.log('NODE_ENV:', process.env.NODE_ENV);
console.log('PORT:', process.env.PORT);
console.log('Current working directory:', process.cwd());
console.log('__dirname:', __dirname);
console.log('=== END SERVER STARTUP DEBUG ===');

import connectDB from './config/db.js';
import cookieParser from 'cookie-parser';
import { notFound, errorHandler } from './middleware/errorMiddleware.js';
import categoryRoutes from './routes/categoryRoutes.js';
import musicRoutes from './routes/musicRoutes.js';
import cors from 'cors';
import { handleWebhook } from './controllers/subscriptionController.js';
import userRoutes from './routes/userRoutes.js';

const port = process.env.PORT || 5000;

connectDB();

const app = express();


// Stripe webhook must be registered BEFORE express.json() to preserve raw body
app.post('/api/subscriptions/webhook', express.raw({ type: 'application/json' }), handleWebhook);

app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));

const corsOptions = {
  origin: function (origin, callback) {
    // Allow requests with no origin (like mobile apps or curl requests)
    if (!origin) return callback(null, true);
    
    const allowedOrigins = [
      'https://elevateintune.com',
      'http://localhost:3000',
      'http://127.0.0.1:3000',
      'http://192.168.1.7:3000'
    ];
    
    if (allowedOrigins.indexOf(origin) !== -1) {
      callback(null, true);
    } else {
      // For development, allow any local network origin
      if (origin.includes('192.168.') || origin.includes('localhost') || origin.includes('127.0.0.1')) {
        callback(null, true);
      } else {
        callback(new Error('Not allowed by CORS'));
      }
    }
  },
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  optionsSuccessStatus: 200
};

app.use(cors(corsOptions));
app.options('*', cors(corsOptions));



app.use('/uploads', express.static(path.join(__dirname, 'uploads'))); // Use path.join for cross-platform compatibility

app.use((req, res, next) => {
  console.log('CORS headers set for:', req.method, req.url);
  next();
});


app.use(cookieParser());

// Mount routes
app.use('/api/users', userRoutes);
app.use('/api/categories', categoryRoutes);
app.use('/api/music', musicRoutes);
import subscriptionRoutes from './routes/subscriptionRoutes.js';
import subscriptionPlanRoutes from './routes/subscriptionPlanRoutes.js';
import paymentRoutes from './routes/paymentRoutes.js';
import notificationRoutes from './routes/notificationRoutes.js';
import notificationScheduler from './services/notificationScheduler.js';

app.use('/api/subscriptions', subscriptionRoutes);
app.use('/api/subscription-plans', subscriptionPlanRoutes);
app.use('/api/payments', paymentRoutes);
app.use('/api/notifications', notificationRoutes);

if (process.env.NODE_ENV === 'production') {
  const __dirname = path.resolve();
  app.use(express.static(path.join(__dirname, '/frontend/dist')));
  app.get('*', (req, res) =>
    res.sendFile(path.resolve(__dirname, 'frontend', 'dist', 'index.html'))
  );
} else {
  app.get('/', (req, res) => {
    res.send('API is running....');
  });
}

app.use(notFound);
app.use(errorHandler);

// Start notification scheduler
notificationScheduler.start();

app.listen(port, () => console.log(`Server started on port ${port}`));
