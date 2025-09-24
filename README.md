# Elevate Music Backend Server

This is the backend server for the Elevate Music application, featuring dynamic subscription pricing management.

## Features

- **Dynamic Subscription Pricing**: Admin can manage subscription plans through a web interface
- **Stripe Integration**: Automatic Stripe product and price creation
- **User Management**: Complete user authentication and authorization system
- **Music Management**: Upload, manage, and serve music files
- **Category Management**: Organize music into categories
- **Notification System**: Email notifications and user alerts
- **Admin Panel**: Full-featured admin interface for content management

## Tech Stack

- **Backend**: Node.js, Express.js
- **Database**: MongoDB with Mongoose
- **Payment Processing**: Stripe
- **File Storage**: Local file system with multer
- **Authentication**: JWT tokens
- **Frontend**: React.js (admin panel)

## Project Structure

```
Backend-Server/
├── music/
│   ├── backend/           # Node.js backend API
│   │   ├── controllers/   # API controllers
│   │   ├── models/        # Database models
│   │   ├── routes/        # API routes
│   │   ├── middleware/    # Custom middleware
│   │   ├── services/      # Business logic services
│   │   └── utils/         # Utility functions
│   └── frontend/          # React admin panel
│       ├── src/
│       │   ├── admin/     # Admin panel components
│       │   └── components/ # Shared components
│       └── public/
└── html/                  # Static HTML files
```

## Dynamic Subscription Pricing System

The system allows administrators to:

- Create new subscription plans with custom pricing
- Edit existing subscription plans
- Activate/deactivate plans
- Set default subscription plans
- Automatic Stripe integration for payment processing
- Preserve existing customer pricing (grandfathered pricing)

### Key Features:
- **Admin Interface**: Web-based admin panel for managing subscription plans
- **API Endpoints**: RESTful API for subscription plan management
- **Stripe Integration**: Automatic product and price creation in Stripe
- **Version Control**: Track pricing changes over time
- **Customer Protection**: Existing customers retain their original pricing

## Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   cd music/backend
   npm install
   
   cd ../frontend
   npm install
   ```

3. Set up environment variables:
   ```bash
   # Create .env file in backend directory
   MONGODB_URI=your_mongodb_connection_string
   STRIPE_SECRET_KEY=your_stripe_secret_key
   STRIPE_PRICE_ID=your_stripe_price_id
   JWT_SECRET=your_jwt_secret
   ```

4. Start the servers:
   ```bash
   # Backend
   cd music/backend
   npm start
   
   # Frontend (admin panel)
   cd music/frontend
   npm start
   ```

## API Endpoints

### Subscription Plans
- `GET /api/subscription-plans/current` - Get current active pricing
- `GET /api/subscription-plans/admin/subscription-plans` - List all plans (admin)
- `POST /api/subscription-plans/admin/subscription-plans` - Create new plan (admin)
- `PUT /api/subscription-plans/admin/subscription-plans/:id` - Update plan (admin)
- `DELETE /api/subscription-plans/admin/subscription-plans/:id` - Deactivate plan (admin)

### Users
- `POST /api/users/register` - User registration
- `POST /api/users/login` - User login
- `GET /api/users/profile` - Get user profile

### Music
- `GET /api/music` - Get all music
- `POST /api/music` - Upload music (admin)
- `DELETE /api/music/:id` - Delete music (admin)

### Categories
- `GET /api/categories` - Get all categories
- `POST /api/categories` - Create category (admin)
- `PUT /api/categories/:id` - Update category (admin)
- `DELETE /api/categories/:id` - Delete category (admin)

## Deployment

The application is designed to be deployed on platforms like:
- Render.com
- Heroku
- AWS
- DigitalOcean

Make sure to set up the following environment variables in your deployment platform:
- MONGODB_URI
- STRIPE_SECRET_KEY
- STRIPE_PRICE_ID
- JWT_SECRET
- NODE_ENV=production

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is proprietary software for Elevate Music application.
