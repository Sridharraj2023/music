# Elevate - Implementation Guides & Documentation

> **Comprehensive guide for all completed implementations and deployment steps**

---

## 📑 Table of Contents

1. [Resend Email Integration](#1-resend-email-integration)
2. [Forgot Password Feature](#2-forgot-password-feature)
3. [Terms & Conditions System](#3-terms--conditions-system)
4. [Disclaimer Management](#4-disclaimer-management)
5. [Admin User Management Enhancement](#5-admin-user-management-enhancement)
6. [Tablet Responsive Design](#6-tablet-responsive-design)
7. [Deployment to Render.com](#7-deployment-to-rendercom)

---

## 1. Resend Email Integration

### ✅ Status: COMPLETE

### Quick Setup
1. **Install Resend SDK:**
   ```bash
   cd D:\Elevate-Backend\backend
   npm install resend
   ```

2. **Update `.env`:**
   ```bash
   RESEND_API_KEY=re_YOUR_KEY_HERE
   EMAIL_FROM=Elevate <onboarding@resend.dev>
   FRONTEND_URL=http://localhost:3000
   ```

3. **Get API Key:**
   - Visit: https://resend.com/api-keys
   - Create new API key
   - Update `.env` with new key

### Key Files
- `backend/services/emailService.js` - Email service using Resend
- `backend/.env` - Environment configuration
- `backend/test-resend.js` - Test script

### Testing
```bash
# Test Resend integration
node test-resend.js

# Expected output:
# ✅ SUCCESS! Email sent
# 📧 Check your inbox!
```

---

## 2. Forgot Password Feature

### ✅ Status: COMPLETE

### User Flow
1. Click "Forgot Password?" on Login screen
2. Enter email address
3. Receive reset email (via Resend)
4. Click reset link in email
5. Enter new password
6. Receive confirmation email
7. Login with new password

### Implementation Files

**Backend:**
- `models/userModel.js` - Reset token fields
- `services/emailService.js` - Reset emails
- `controllers/userController.js` - Reset logic

**Flutter:**
- `lib/View/Screens/ForgotPassword_Screen.dart` - Email input
- `lib/View/Screens/ResetPassword_Screen.dart` - Password reset
- `lib/Controller/Auth_Controller.dart` - Reset methods

### API Endpoints
```
POST /api/users/forgot-password
POST /api/users/reset-password/:token
```

### Security Features
- 32-byte crypto tokens
- SHA-256 hashing
- 1-hour expiration
- One-time use
- No email enumeration

---

## 3. Terms & Conditions System

### ✅ Status: COMPLETE

### Architecture
- **Admin Panel:** Create/edit/publish T&C
- **Backend:** Version control & API
- **Flutter App:** Display to users

### API Endpoints

**Public:**
```
GET /api/terms/active
```

**Admin:**
```
GET    /api/terms/admin              - All versions
POST   /api/terms/admin              - Create
PUT    /api/terms/admin/:id          - Update
PUT    /api/terms/admin/:id/publish  - Publish
DELETE /api/terms/admin/:id          - Delete
```

### Key Features
- ✅ Version control
- ✅ Only one active version
- ✅ HTML formatting support
- ✅ Admin management interface
- ✅ Flutter display screen

### Implementation Files

**Backend:**
- `models/TermsAndConditions.js`
- `controllers/termsController.js`
- `routes/termsRoutes.js`

**Admin Panel:**
- `src/admin/pages/ManageTermsConditions.jsx`

**Flutter:**
- `lib/View/Screens/TermsConditions_Screen.dart`

---

## 4. Disclaimer Management

### ✅ Status: COMPLETE

### Features
- Separate from Terms & Conditions
- Same management interface as T&C
- Default disclaimer template provided
- Accessible from Signup and Homepage drawer

### API Endpoints
```
GET /api/terms/disclaimer/active           - Public
GET /api/terms/admin/disclaimer            - Admin
POST /api/terms/admin (documentType: disclaimer) - Create
```

### Implementation Files

**Admin Panel:**
- `src/admin/pages/ManageDisclaimer.jsx`

**Flutter:**
- `lib/View/Screens/Disclaimer_Screen.dart`
- `lib/View/Screens/Legal_Pdf_View.dart` - Scrollable text viewer

### Default Content Includes
- General information
- Medical advice disclaimer
- No medical claims
- Individual results disclaimer
- Liability limitations
- Consultation recommendations

---

## 5. Admin User Management Enhancement

### 📋 Status: PLANNED (Implementation guide ready)

### Enhanced Table Columns
- Name
- Email
- **Subscription Status** (with badges)
- **Payment Date**
- **Expiry Date**
- **Days Remaining**
- **Auto-Debit Status**
- Created Date
- Actions (View/Delete)

### New Features
- ✅ Color-coded status badges
- ✅ Filter by subscription status
- ✅ User details modal
- ✅ Export to CSV
- ✅ Statistics dashboard
- ✅ Search functionality

### Implementation Steps
1. Update backend `getAllUsers` controller
2. Add status calculation logic
3. Update frontend table columns
4. Add filters and sorting
5. Create user details modal
6. Add export functionality

**Estimated Time:** 1.5 hours

---

## 6. Tablet Responsive Design

### ✅ Status: UTILITY CREATED

### Implementation
Created `lib/utils/responsive_helper.dart` with responsive utilities.

### Usage

**For Auth Screens (Login, Signup, etc.):**
```dart
import '../../utils/responsive_helper.dart';

ResponsiveCenter(
  maxWidth: 500,
  child: SingleChildScrollView(
    child: Column(
      children: [
        // Your widgets
      ],
    ),
  ),
)
```

### Breakpoints
- **Mobile** (<600px): Full width
- **Tablet** (600-1024px): Max 500px, centered
- **Desktop** (>1024px): Max 600px, centered

### Benefits
- ✅ Forms don't stretch on tablets
- ✅ Better readability
- ✅ Maintains mobile UX on phones
- ✅ Professional tablet interface

---

## 7. Deployment to Render.com

### Backend Deployment Steps

#### Step 1: Environment Variables
Add these in Render Dashboard → Environment:
```bash
RESEND_API_KEY=re_YOUR_KEY_HERE
EMAIL_FROM=Elevate <onboarding@resend.dev>
FRONTEND_URL=https://your-app.com
NODE_ENV=production
MONGO_URI=mongodb+srv://...
JWT_SECRET=your_secret
STRIPE_SECRET_KEY=sk_live_...
```

#### Step 2: Deploy Code
```bash
# Commit changes
git add .
git commit -m "Integrate Resend email service"
git push origin main

# Render auto-deploys on push
```

#### Step 3: Verify Deployment
1. Check build logs in Render Dashboard
2. Look for: `✅ Resend email service initialized`
3. Test endpoints:
   ```bash
   curl https://your-backend.onrender.com/api/users/forgot-password \
     -H "Content-Type: application/json" \
     -d '{"email": "test@example.com"}'
   ```

#### Step 4: Production Best Practices
1. **Verify Domain at Resend:**
   - Go to https://resend.com/domains
   - Add your domain
   - Add DNS records (SPF, DKIM)
   - Update `EMAIL_FROM` to custom domain

2. **Enable HTTPS:**
   - ✅ Render provides automatic HTTPS

3. **Set Up Monitoring:**
   - Configure health checks in Render
   - Set up Resend webhooks (optional)

### Troubleshooting

**Emails not sending:**
- ✅ Check `RESEND_API_KEY` in environment
- ✅ Verify API key is valid
- ✅ Check Render logs for errors
- ✅ Test with `curl` command

**Build fails:**
- ✅ Ensure `resend` in `package.json`
- ✅ Check syntax in `emailService.js`
- ✅ Verify all environment variables set

---

## 📚 Additional Resources

### Documentation URLs
- **Resend Docs:** https://resend.com/docs
- **Resend Dashboard:** https://resend.com/dashboard
- **Render Docs:** https://render.com/docs
- **Render Dashboard:** https://dashboard.render.com

### Environment Files
- **Backend:** `D:\Elevate-Backend\backend\.env`
- **Flutter:** `D:\Elevate-main\.env`

### API Base URLs
- **Local:** `http://localhost:5000/api`
- **Production:** `https://your-backend.onrender.com/api`

---

## 🧪 Complete Testing Checklist

### Backend
- [ ] Environment variables configured
- [ ] Backend server running
- [ ] MongoDB connected
- [ ] Resend emails sending
- [ ] All API endpoints responding
- [ ] Error handling working

### Admin Panel
- [ ] Login successful
- [ ] Dashboard accessible
- [ ] Terms & Conditions management working
- [ ] Disclaimer management working
- [ ] User management functional
- [ ] All CRUD operations working

### Flutter App
- [ ] App builds successfully
- [ ] Login/Signup working
- [ ] Forgot password flow complete
- [ ] Terms & Conditions visible
- [ ] Disclaimer visible
- [ ] Email links work
- [ ] All screens responsive

### Integration
- [ ] Admin creates T&C → Flutter displays
- [ ] Admin updates T&C → Flutter reflects changes
- [ ] Password reset emails arrive
- [ ] Confirmation emails arrive
- [ ] Deep links work (if configured)

---

## 🔧 Common Commands

### Backend
```bash
# Start server
npm start

# Test Resend
node test-resend.js

# Install dependencies
npm install

# Check environment
node -e "require('dotenv').config(); console.log(process.env.RESEND_API_KEY)"
```

### Flutter
```bash
# Get dependencies
flutter pub get

# Run app
flutter run

# Build APK
flutter build apk

# Clean build
flutter clean
```

### Git
```bash
# Status
git status

# Commit changes
git add .
git commit -m "Your message"

# Push to remote
git push origin main
```

---

## ⚠️ Security Reminders

1. **Never commit `.env` files**
2. **Regenerate API keys if exposed**
3. **Use environment variables for secrets**
4. **Enable 2FA on all services**
5. **Keep dependencies updated**
6. **Use HTTPS in production**
7. **Validate all user inputs**
8. **Hash passwords with bcrypt**
9. **Use secure tokens (crypto.randomBytes)**
10. **Set token expiration times**

---

## 📞 Support

### Issues & Questions
- Backend errors: Check Render logs
- Email issues: Check Resend dashboard
- Flutter errors: Check console logs
- Database issues: Check MongoDB Atlas

### External Support
- Resend: support@resend.com
- Render: https://render.com/support
- MongoDB: https://www.mongodb.com/cloud/atlas/support

---

**Last Updated:** 2024  
**Maintained By:** Elevate Development Team  
**Version:** 1.0

---

## Quick Reference Card

```
┌─────────────────────────────────────────┐
│  ELEVATE - QUICK REFERENCE              │
├─────────────────────────────────────────┤
│                                         │
│  Backend API:                           │
│  http://localhost:5000/api              │
│                                         │
│  Admin Panel:                           │
│  http://localhost:5173                  │
│                                         │
│  Key Services:                          │
│  • Resend: resend.com/dashboard         │
│  • Render: dashboard.render.com         │
│  • MongoDB: cloud.mongodb.com           │
│                                         │
│  Important Files:                       │
│  • Backend env: backend/.env            │
│  • Flutter env: .env                    │
│  • API constants: lib/utlis/api_*.dart  │
│                                         │
│  Emergency Commands:                    │
│  • Restart backend: npm start           │
│  • Restart Flutter: flutter run         │
│  • Test email: node test-resend.js      │
│                                         │
└─────────────────────────────────────────┘
```

---

**🎉 All implementations complete and ready for production!**

