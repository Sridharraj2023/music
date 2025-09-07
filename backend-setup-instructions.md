# Elevate Backend Setup Instructions

## 🚀 Quick Setup

### 1. Initialize Node.js Project
```bash
mkdir elevate-backend
cd elevate-backend
npm init -y
```

### 2. Install Dependencies
```bash
npm install express cors helmet compression morgan express-rate-limit express-validator multer nodemailer redis winston dotenv bcryptjs jsonwebtoken stripe mongoose
npm install -D nodemon jest eslint supertest
```

### 3. Environment Setup
```bash
# Copy the environment template
cp backend.env.example .env

# Edit .env with your actual values
nano .env
```

### 4. Required Environment Variables

#### 🔑 Essential Variables (Must Set):
```env
# Stripe Keys (Get from Stripe Dashboard)
STRIPE_SECRET_KEY=sk_test_your_actual_secret_key_here
STRIPE_PUBLISHABLE_KEY=pk_test_your_actual_publishable_key_here
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here

# Database
DB_HOST=localhost
DB_NAME=elevate_db
DB_USER=your_db_username
DB_PASSWORD=your_db_password

# JWT
JWT_SECRET=your_super_secret_jwt_key_here_make_it_long_and_random
```

#### 📱 Stripe Product Setup:
1. Go to [Stripe Dashboard](https://dashboard.stripe.com/)
2. Create Products and Prices for your subscription plans
3. Copy the Price IDs to your `.env` file:
```env
STRIPE_BASIC_PLAN_PRICE_ID=price_1234567890
STRIPE_PREMIUM_PLAN_PRICE_ID=price_0987654321
STRIPE_PRO_PLAN_PRICE_ID=price_1122334455
```

### 5. Project Structure
```
elevate-backend/
├── .env
├── package.json
├── server.js
├── config/
│   ├── stripe-config.js
│   └── database.js
├── routes/
│   ├── auth.js
│   ├── users.js
│   ├── music.js
│   ├── binaural.js
│   ├── subscriptions.js
│   └── payments.js
├── models/
│   ├── User.js
│   ├── Music.js
│   └── Subscription.js
├── middleware/
│   ├── auth.js
│   └── validation.js
└── utils/
    ├── logger.js
    └── helpers.js
```

### 6. Start Development Server
```bash
# Development mode with auto-restart
npm run dev

# Production mode
npm start
```

## 🔧 Stripe Webhook Setup

### 1. Install Stripe CLI
```bash
# Windows (using Chocolatey)
choco install stripe-cli

# macOS (using Homebrew)
brew install stripe/stripe-cli/stripe

# Linux
wget https://github.com/stripe/stripe-cli/releases/latest/download/stripe_X.X.X_linux_x86_64.tar.gz
```

### 2. Login to Stripe
```bash
stripe login
```

### 3. Forward Webhooks to Local Server
```bash
stripe listen --forward-to localhost:5000/api/subscriptions/webhook
```

### 4. Copy Webhook Secret
Copy the webhook secret from the terminal output and add it to your `.env` file:
```env
STRIPE_WEBHOOK_SECRET=whsec_your_webhook_secret_here
```

## 🗄️ Database Setup

### MongoDB (Recommended)
```bash
# Install MongoDB
# Windows: Download from https://www.mongodb.com/try/download/community
# macOS: brew install mongodb-community
# Linux: sudo apt-get install mongodb

# Start MongoDB
mongod

# Create database
mongo
> use elevate_db
> db.createUser({user: "elevate_user", pwd: "your_password", roles: ["readWrite"]})
```

### PostgreSQL (Alternative)
```bash
# Install PostgreSQL
# Windows: Download from https://www.postgresql.org/download/windows/
# macOS: brew install postgresql
# Linux: sudo apt-get install postgresql postgresql-contrib

# Create database
sudo -u postgres psql
> CREATE DATABASE elevate_db;
> CREATE USER elevate_user WITH PASSWORD 'your_password';
> GRANT ALL PRIVILEGES ON DATABASE elevate_db TO elevate_user;
```

## 🔒 Security Checklist

- ✅ Secret keys only in backend
- ✅ Environment variables properly configured
- ✅ CORS configured for your frontend URLs
- ✅ Rate limiting enabled
- ✅ Input validation implemented
- ✅ JWT tokens with proper expiration
- ✅ HTTPS in production
- ✅ Webhook signature verification

## 📱 Frontend Integration

Update your Flutter app's `api_constants.dart`:
```dart
class ApiConstants {
  static const String apiUrl = "http://192.168.0.100:5000/api";
  static const String publishKey = 'pk_test_your_publishable_key_here';
  // Remove secret key - never use in frontend!
}
```

## 🚀 Production Deployment

### Environment Variables for Production:
```env
NODE_ENV=production
PORT=5000
HOST=0.0.0.0

# Use production Stripe keys
STRIPE_SECRET_KEY=sk_live_your_live_secret_key
STRIPE_PUBLISHABLE_KEY=pk_live_your_live_publishable_key

# Production database
DB_HOST=your_production_db_host
DB_NAME=elevate_production_db
DB_USER=production_user
DB_PASSWORD=secure_production_password

# Production URLs
API_BASE_URL=https://your-api-domain.com/api
FRONTEND_URL=https://your-app-domain.com
```

## 🧪 Testing

```bash
# Run tests
npm test

# Test Stripe integration
npm run test:stripe

# Test API endpoints
npm run test:api
```

## 📊 Monitoring

- Set up logging with Winston
- Monitor Stripe webhook events
- Track API performance
- Set up error reporting (Sentry, etc.)

## 🆘 Troubleshooting

### Common Issues:

1. **Stripe Webhook Errors**
   - Check webhook endpoint URL
   - Verify webhook secret
   - Check Stripe CLI connection

2. **Database Connection Issues**
   - Verify database credentials
   - Check database server status
   - Ensure proper network access

3. **CORS Issues**
   - Update CORS_ORIGIN in .env
   - Check frontend URL configuration

4. **JWT Token Issues**
   - Verify JWT_SECRET is set
   - Check token expiration settings
   - Ensure proper token format
