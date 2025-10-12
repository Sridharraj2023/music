# 🚀 Deploying Resend to Render.com

## 📍 Current Status

✅ Your backend is running on **Render.com**  
✅ Local backend has Resend integrated  
⚠️ Need to add Resend config to Render  

---

## 🔧 Step 1: Get New Resend API Key

**⚠️ IMPORTANT:** The API key shared earlier is compromised and invalid.

1. **Go to:** https://resend.com/api-keys
2. **Click:** "Create API Key"
3. **Name it:** "Elevate Backend - Production"
4. **Copy the key** (you'll need it in next step)

---

## 🌐 Step 2: Add Environment Variables to Render

### **Option A: Via Render Dashboard (Recommended)**

1. **Go to Render Dashboard**
   - Visit: https://dashboard.render.com/
   - Sign in to your account

2. **Select Your Service**
   - Click on your backend service (e.g., "elevate-backend")

3. **Go to Environment**
   - Click the **"Environment"** tab in the left sidebar

4. **Add New Environment Variables**
   
   Click **"Add Environment Variable"** and add these:

   | Key | Value |
   |-----|-------|
   | `RESEND_API_KEY` | `re_YOUR_NEW_KEY_FROM_STEP_1` |
   | `EMAIL_FROM` | `Elevate <onboarding@resend.dev>` |

   **Make sure these existing variables are also set:**
   | Key | Current Value |
   |-----|---------------|
   | `FRONTEND_URL` | Your Flutter app URL or `http://localhost:3000` |
   | `NODE_ENV` | `production` |
   | `PORT` | `5000` (or Render's auto PORT) |
   | `MONGO_URI` | Your MongoDB connection string |
   | `JWT_SECRET` | Your JWT secret |
   | `STRIPE_SECRET_KEY` | Your Stripe key |
   | `STRIPE_PRICE_ID` | Your Stripe price ID |
   | `STRIPE_WEBHOOK_SECRET` | Your Stripe webhook secret |

5. **Save Changes**
   - Click **"Save Changes"**
   - Render will automatically redeploy your service

---

### **Option B: Via Render API (Advanced)**

Using the Render API:

```bash
curl -X PATCH \
  https://api.render.com/v1/services/YOUR_SERVICE_ID/env-vars \
  -H "Authorization: Bearer YOUR_RENDER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '[
    {
      "key": "RESEND_API_KEY",
      "value": "re_YOUR_NEW_KEY_HERE"
    },
    {
      "key": "EMAIL_FROM",
      "value": "Elevate <onboarding@resend.dev>"
    }
  ]'
```

---

## 🔄 Step 3: Deploy Updated Code to Render

### **If using Git deployment (most common):**

```bash
# Navigate to your backend directory
cd D:\Elevate-Backend\backend

# Check git status
git status

# Stage the changes
git add .

# Commit the changes
git commit -m "Integrate Resend email service for password reset"

# Push to your repository
git push origin main
# or: git push origin master
```

**Render will automatically detect the push and redeploy!**

---

### **If using Manual Deploy:**

1. **Go to Render Dashboard**
2. **Select your service**
3. **Click "Manual Deploy"**
4. **Select the branch to deploy**
5. **Click "Deploy"**

---

## ✅ Step 4: Verify Deployment

### **Check Build Logs:**

1. **Go to Render Dashboard**
2. **Click on your service**
3. **Click "Logs" tab**
4. **Look for:**
   ```
   ✅ Resend email service initialized
   📧 Email from: Elevate <onboarding@resend.dev>
   Server running on port 5000
   ```

### **Common Issues:**

❌ **"RESEND_API_KEY is not set"**
- Solution: Add environment variable in Render dashboard

❌ **Build fails**
- Solution: Make sure `resend` is in `package.json` dependencies
- Run: `npm install resend` locally and commit `package-lock.json`

❌ **Service not restarting**
- Solution: Manually trigger deploy in Render dashboard

---

## 🧪 Step 5: Test the Deployed API

### **Test 1: Check Server Health**

```bash
curl https://your-backend-url.onrender.com/
```

Replace `your-backend-url.onrender.com` with your actual Render URL.

---

### **Test 2: Test Forgot Password Endpoint**

```bash
curl -X POST https://your-backend-url.onrender.com/api/users/forgot-password \
  -H "Content-Type: application/json" \
  -d '{"email": "your-test-email@example.com"}'
```

**Expected response:**
```json
{
  "message": "If an account with that email exists, a password reset link has been sent."
}
```

**Check your email inbox!**

---

### **Test 3: Check Render Logs**

1. **Go to Render Dashboard**
2. **Click "Logs"**
3. **Look for:**
   ```
   📧 Sending password reset email to: test@example.com
   ✅ Password reset email sent successfully via Resend
   📬 Email ID: xxx-xxx-xxx
   ```

---

## 📱 Step 6: Update Flutter App

### **Update API URL (if needed):**

**File:** `D:\Elevate-main\lib\utlis\api_constants.dart`

Make sure your API URL points to Render:

```dart
class ApiConstants {
  // Production URL
  static const String apiUrl = 'https://your-backend.onrender.com/api';
  
  // Or use environment-based URL:
  static String get resolvedApiUrl {
    if (environment == 'production') {
      return 'https://your-backend.onrender.com/api';
    } else {
      return 'http://localhost:5000/api';
    }
  }
}
```

---

## 🎯 Step 7: Test Complete Flow

### **From Flutter App:**

1. **Open your Flutter app**
2. **Click "Forgot Password?"**
3. **Enter your email**
4. **Click "Send Reset Link"**
5. **Check your email** ✉️
6. **Click the reset link** in email
7. **Enter new password**
8. **Get confirmation email** ✅
9. **Login with new password** 🎉

---

## 📊 Monitor Email Delivery

### **Resend Dashboard:**

1. **Go to:** https://resend.com/logs
2. **View:**
   - Email delivery status
   - Open rates
   - Click rates
   - Failed deliveries
   - Error logs

### **Render Logs:**

1. **Go to:** https://dashboard.render.com/
2. **Select your service**
3. **Click "Logs"**
4. **Monitor:**
   - Email send attempts
   - Success/failure messages
   - Error details

---

## 🔒 Production Best Practices

### **1. Verify Your Domain (Recommended)**

**Why?** Better email deliverability and professional sender address.

**Steps:**
1. Go to: https://resend.com/domains
2. Click "Add Domain"
3. Enter: `elevateintune.com`
4. Add DNS records to your domain registrar:
   - SPF record
   - DKIM record
   - Domain verification record
5. Wait for verification (up to 48 hours)
6. Update `EMAIL_FROM` in Render environment variables:
   ```
   EMAIL_FROM=Elevate <noreply@elevateintune.com>
   ```

---

### **2. Update Frontend URL**

Make sure `FRONTEND_URL` in Render points to your production URL:

```bash
# For web app:
FRONTEND_URL=https://your-app.com

# For mobile app (deep linking):
FRONTEND_URL=elevateapp://reset-password

# For testing (local):
FRONTEND_URL=http://localhost:3000
```

---

### **3. Enable HTTPS**

✅ **Render automatically provides HTTPS** - you're good!

Just make sure your reset links use `https://`:
```javascript
const resetLink = `${process.env.FRONTEND_URL}/reset-password?token=${resetToken}`;
```

---

### **4. Set Up Monitoring**

**Render Health Checks:**
1. Go to Render Dashboard
2. Click your service
3. Go to "Health & Alerts"
4. Set up health check endpoint

**Resend Webhooks (Optional):**
1. Go to: https://resend.com/webhooks
2. Add webhook URL: `https://your-backend.onrender.com/api/webhooks/resend`
3. Subscribe to events: delivery, bounce, complaint

---

## 🐛 Troubleshooting

### **Issue: Emails not sending from Render**

**Check these:**
1. ✅ `RESEND_API_KEY` is set in Render environment variables
2. ✅ API key is valid (not expired/revoked)
3. ✅ `EMAIL_FROM` is set correctly
4. ✅ Check Render logs for error messages
5. ✅ Check Resend dashboard logs

**Debug:**
```bash
# Check environment variables are loaded
curl https://your-backend.onrender.com/api/health

# Test email endpoint directly
curl -X POST https://your-backend.onrender.com/api/users/forgot-password \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'
```

---

### **Issue: "Unable to fetch data" error**

**Causes:**
1. Invalid API key
2. Network/firewall issues on Render
3. Resend service outage

**Solutions:**
1. Regenerate API key at https://resend.com/api-keys
2. Update environment variable in Render
3. Check Resend status: https://resend.com/status

---

### **Issue: Reset link not working**

**Check:**
1. `FRONTEND_URL` is set correctly in Render
2. Flutter app handles deep links properly
3. Token hasn't expired (1 hour limit)
4. URL encoding is correct

**Fix:**
Update `FRONTEND_URL` in Render to match your app's actual URL.

---

### **Issue: Build/Deploy fails**

**Common causes:**
1. `resend` package not in `package.json`
2. Syntax errors in `emailService.js`
3. Missing environment variables

**Fix:**
```bash
# Locally, ensure resend is installed
cd D:\Elevate-Backend\backend
npm install resend

# Commit package.json and package-lock.json
git add package.json package-lock.json
git commit -m "Add resend dependency"
git push origin main
```

---

## ✅ Deployment Checklist

### **Before Deploying:**
- [ ] Get new Resend API key from https://resend.com/api-keys
- [ ] Test locally with `node test-resend.js`
- [ ] Commit and push code changes to Git
- [ ] Ensure `resend` is in `package.json`

### **In Render Dashboard:**
- [ ] Add `RESEND_API_KEY` environment variable
- [ ] Add `EMAIL_FROM` environment variable
- [ ] Verify `FRONTEND_URL` is correct
- [ ] Verify other env vars are set (MONGO_URI, JWT_SECRET, etc.)
- [ ] Save changes (triggers auto-deploy)

### **After Deployment:**
- [ ] Check build logs for errors
- [ ] Verify "Resend email service initialized" in logs
- [ ] Test forgot password endpoint with cURL
- [ ] Test from Flutter app
- [ ] Check email received
- [ ] Test complete reset flow
- [ ] Monitor Resend dashboard logs

### **For Production:**
- [ ] Verify domain at Resend
- [ ] Add DNS records (SPF, DKIM)
- [ ] Update `EMAIL_FROM` to custom domain
- [ ] Set up health checks in Render
- [ ] Set up monitoring/alerts
- [ ] Test with real users

---

## 📚 Quick Reference

### **Important URLs:**

| Service | URL |
|---------|-----|
| **Render Dashboard** | https://dashboard.render.com/ |
| **Resend Dashboard** | https://resend.com/dashboard |
| **Resend API Keys** | https://resend.com/api-keys |
| **Resend Email Logs** | https://resend.com/logs |
| **Resend Domains** | https://resend.com/domains |
| **Resend Status** | https://resend.com/status |

---

### **Environment Variables:**

```bash
# Required for Resend
RESEND_API_KEY=re_YOUR_KEY_HERE
EMAIL_FROM=Elevate <onboarding@resend.dev>

# Other required variables
FRONTEND_URL=https://your-app.com
NODE_ENV=production
MONGO_URI=mongodb+srv://...
JWT_SECRET=your_secret
STRIPE_SECRET_KEY=sk_live_...
```

---

### **Test Commands:**

```bash
# Test forgot password
curl -X POST https://your-backend.onrender.com/api/users/forgot-password \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com"}'

# Check server health
curl https://your-backend.onrender.com/

# View logs
# Go to: https://dashboard.render.com → Your Service → Logs
```

---

## 🎉 You're Ready!

Follow these steps and your forgot password feature will be live on Render!

### **Quick Summary:**
1. ✅ Get new API key from Resend
2. ✅ Add to Render environment variables
3. ✅ Push code to Git (triggers deploy)
4. ✅ Wait for deployment
5. ✅ Test the feature
6. ✅ Celebrate! 🎊

---

## 💡 Pro Tips

1. **Keep API keys secure** - Never commit them to Git
2. **Monitor logs** - Check both Render and Resend dashboards
3. **Test thoroughly** - Try with different email providers
4. **Verify domain** - For production (better deliverability)
5. **Set up alerts** - Get notified of failures
6. **Rate limiting** - Monitor your Resend usage

---

**Need Help?**
- Render Docs: https://render.com/docs
- Resend Docs: https://resend.com/docs
- Render Support: https://render.com/support
- Resend Support: support@resend.com

**Good luck! 🚀**

