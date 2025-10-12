# 📧 Resend Email Integration - Complete Guide

## ⚠️ IMPORTANT: Backend Setup Only (No Flutter Changes Needed!)

Your **Flutter app is already complete** with the forgot password feature. You only need to update your **Node.js backend** to use Resend instead of Gmail SMTP.

---

## 📍 Directory Structure

```
D:\
├── Elevate-main\                  ← YOUR FLUTTER APP (NO CHANGES NEEDED!)
│   └── lib\
│       ├── View\
│       │   └── Screens\
│       │       ├── ForgotPassword_Screen.dart  ✅ Already exists
│       │       └── ResetPassword_Screen.dart   ✅ Already exists
│       └── Controller\
│           └── Auth_Controller.dart            ✅ Already has reset methods
│
└── Elevate-Backend\               ← YOUR BACKEND (UPDATE THESE FILES!)
    └── backend\
        ├── .env                   🔧 Update this
        ├── package.json           🔧 Update this
        ├── services\
        │   └── emailService.js    🔧 Replace this
        └── test-resend.js         ✨ Create this (new)
```

---

## 🚀 Step-by-Step Implementation

### **Step 1: Install Resend SDK in Backend**

Open terminal and run:

```bash
cd D:\Elevate-Backend\backend
npm install resend
```

---

### **Step 2: Update Backend Environment Variables**

**File Location:** `D:\Elevate-Backend\backend\.env`

Add these lines (or update existing ones):

```bash
# Resend Configuration
RESEND_API_KEY=re_VMB9MuCr_JcU3Wfob24KbrJQcCnuFSbLF
EMAIL_FROM=Elevate <onboarding@resend.dev>
FRONTEND_URL=http://localhost:3000

# Remove or comment out old Gmail SMTP settings:
# EMAIL_USER=...
# EMAIL_PASS=...
```

**⚠️ SECURITY WARNING:** The API key above was shared publicly and is compromised. You MUST regenerate it at https://resend.com/api-keys before going to production!

---

### **Step 3: Replace Email Service File**

**File Location:** `D:\Elevate-Backend\backend\services\emailService.js`

Replace the entire contents with:

```javascript
const { Resend } = require('resend');

// Initialize Resend with API key from environment
const resend = new Resend(process.env.RESEND_API_KEY);

/**
 * Send password reset email
 */
const sendPasswordResetEmail = async (toEmail, resetToken) => {
  const resetLink = \`\${process.env.FRONTEND_URL}/reset-password?token=\${resetToken}\`;
  
  const htmlContent = \`
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Reset Your Password</title>
    </head>
    <body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f4f4f7;">
      <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0">
        <tr>
          <td align="center" style="padding: 40px 20px;">
            <table role="presentation" width="600" cellspacing="0" cellpadding="0" border="0" style="background-color: #ffffff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
              
              <!-- Header -->
              <tr>
                <td style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 50px 40px; text-align: center; border-radius: 12px 12px 0 0;">
                  <h1 style="color: #ffffff; margin: 0; font-size: 32px; font-weight: 700;">ELEVATE</h1>
                  <p style="color: rgba(255,255,255,0.9); margin: 8px 0 0 0; font-size: 14px;">by Frequency Tuning</p>
                </td>
              </tr>
              
              <!-- Content -->
              <tr>
                <td style="padding: 50px 40px;">
                  <h2 style="color: #1a1a1a; margin: 0 0 24px 0; font-size: 26px;">Reset Your Password</h2>
                  <p style="color: #4a4a4a; font-size: 16px; line-height: 1.7; margin: 0 0 24px 0;">
                    Click the button below to reset your password:
                  </p>
                  
                  <!-- Button -->
                  <table role="presentation" cellspacing="0" cellpadding="0" border="0" style="margin: 32px 0;">
                    <tr>
                      <td style="border-radius: 32px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                        <a href="\${resetLink}" target="_blank" style="display: inline-block; padding: 18px 48px; font-size: 17px; color: #ffffff; text-decoration: none; font-weight: 600;">
                          Reset My Password
                        </a>
                      </td>
                    </tr>
                  </table>
                  
                  <p style="color: #6b6b6b; font-size: 14px; margin: 24px 0 8px 0;">Or copy this link:</p>
                  <div style="background-color: #f8f9fa; padding: 14px; border-radius: 6px; word-break: break-all;">
                    <a href="\${resetLink}" style="color: #667eea; font-size: 13px;">\${resetLink}</a>
                  </div>
                  
                  <!-- Warning -->
                  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0" style="margin: 32px 0; background-color: #fff3cd; border-left: 4px solid #ffc107; border-radius: 6px;">
                    <tr>
                      <td style="padding: 16px 20px;">
                        <p style="color: #856404; font-size: 14px; margin: 0;">
                          <strong>⚠️ Important:</strong> This link expires in <strong>1 hour</strong>.
                        </p>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
              
              <!-- Footer -->
              <tr>
                <td style="background-color: #f8f9fa; padding: 32px 40px; text-align: center; border-radius: 0 0 12px 12px;">
                  <p style="color: #9ca3af; font-size: 13px; margin: 0;">
                    © \${new Date().getFullYear()} Elevate by Frequency Tuning
                  </p>
                </td>
              </tr>
              
            </table>
          </td>
        </tr>
      </table>
    </body>
    </html>
  \`;

  const textContent = \`
    ELEVATE - Password Reset Request
    
    Click this link to reset your password: \${resetLink}
    
    This link expires in 1 hour.
    
    If you didn't request this, please ignore this email.
  \`;

  try {
    const { data, error } = await resend.emails.send({
      from: process.env.EMAIL_FROM || 'Elevate <onboarding@resend.dev>',
      to: [toEmail],
      subject: 'Reset Your Password - Elevate',
      html: htmlContent,
      text: textContent,
    });

    if (error) {
      console.error('Resend error:', error);
      throw new Error(\`Failed to send email: \${error.message}\`);
    }

    console.log('Password reset email sent successfully:', data);
    return { success: true, data };
  } catch (error) {
    console.error('Error sending password reset email:', error);
    throw error;
  }
};

/**
 * Send password reset confirmation email
 */
const sendPasswordResetConfirmation = async (toEmail) => {
  const loginLink = \`\${process.env.FRONTEND_URL}/login\`;
  
  const htmlContent = \`
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Password Reset Successful</title>
    </head>
    <body style="margin: 0; padding: 0; font-family: Arial, sans-serif; background-color: #f4f4f7;">
      <table role="presentation" width="100%" cellspacing="0" cellpadding="0" border="0">
        <tr>
          <td align="center" style="padding: 40px 20px;">
            <table role="presentation" width="600" cellspacing="0" cellpadding="0" border="0" style="background-color: #ffffff; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
              
              <!-- Header -->
              <tr>
                <td style="background: linear-gradient(135deg, #10b981 0%, #059669 100%); padding: 50px 40px; text-align: center; border-radius: 12px 12px 0 0;">
                  <h1 style="color: #ffffff; margin: 0; font-size: 32px; font-weight: 700;">ELEVATE</h1>
                  <p style="color: rgba(255,255,255,0.9); margin: 8px 0 0 0; font-size: 14px;">by Frequency Tuning</p>
                </td>
              </tr>
              
              <!-- Success Icon -->
              <tr>
                <td align="center" style="padding: 50px 40px 30px 40px;">
                  <div style="width: 90px; height: 90px; background: linear-gradient(135deg, #10b981 0%, #059669 100%); border-radius: 50%; display: inline-flex; margin-bottom: 24px;">
                    <span style="color: white; font-size: 48px; line-height: 90px; margin: 0 auto;">✓</span>
                  </div>
                  <h2 style="color: #1a1a1a; margin: 0 0 16px 0; font-size: 28px;">Password Reset Successful!</h2>
                  <p style="color: #4a4a4a; font-size: 16px; margin: 0;">
                    You can now log in with your new password.
                  </p>
                </td>
              </tr>
              
              <!-- Login Button -->
              <tr>
                <td align="center" style="padding: 0 40px 40px 40px;">
                  <table role="presentation" cellspacing="0" cellpadding="0" border="0">
                    <tr>
                      <td style="border-radius: 32px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                        <a href="\${loginLink}" target="_blank" style="display: inline-block; padding: 18px 48px; font-size: 17px; color: #ffffff; text-decoration: none; font-weight: 600;">
                          Login to Your Account
                        </a>
                      </td>
                    </tr>
                  </table>
                </td>
              </tr>
              
              <!-- Footer -->
              <tr>
                <td style="background-color: #f8f9fa; padding: 32px 40px; text-align: center; border-radius: 0 0 12px 12px;">
                  <p style="color: #9ca3af; font-size: 13px; margin: 0;">
                    © \${new Date().getFullYear()} Elevate by Frequency Tuning
                  </p>
                </td>
              </tr>
              
            </table>
          </td>
        </tr>
      </table>
    </body>
    </html>
  \`;

  const textContent = \`
    ELEVATE - Password Reset Successful
    
    Your password has been successfully reset.
    
    Login at: \${loginLink}
  \`;

  try {
    const { data, error } = await resend.emails.send({
      from: process.env.EMAIL_FROM || 'Elevate <onboarding@resend.dev>',
      to: [toEmail],
      subject: 'Password Reset Successful - Elevate',
      html: htmlContent,
      text: textContent,
    });

    if (error) {
      console.error('Resend error:', error);
      throw new Error(\`Failed to send confirmation: \${error.message}\`);
    }

    console.log('Confirmation email sent successfully:', data);
    return { success: true, data };
  } catch (error) {
    console.error('Error sending confirmation:', error);
    throw error;
  }
};

module.exports = {
  sendPasswordResetEmail,
  sendPasswordResetConfirmation,
};
```

---

### **Step 4: Create Test Script**

**File Location:** `D:\Elevate-Backend\backend\test-resend.js` (NEW FILE)

```javascript
require('dotenv').config();
const { Resend } = require('resend');

console.log('\\n🧪 Testing Resend Integration...\\n');

// Check API key
if (!process.env.RESEND_API_KEY) {
  console.error('❌ ERROR: RESEND_API_KEY not found in .env');
  process.exit(1);
}

console.log('✓ RESEND_API_KEY is set');

// Initialize Resend
const resend = new Resend(process.env.RESEND_API_KEY);

// Send test email
(async function() {
  try {
    // ⚠️ CHANGE THIS TO YOUR EMAIL!
    const testEmail = 'YOUR_EMAIL@example.com';
    
    if (testEmail === 'YOUR_EMAIL@example.com') {
      console.error('\\n❌ Please update testEmail in test-resend.js\\n');
      process.exit(1);
    }

    console.log(\`\\nSending test email to: \${testEmail}\\n\`);

    const { data, error } = await resend.emails.send({
      from: process.env.EMAIL_FROM || 'Elevate <onboarding@resend.dev>',
      to: [testEmail],
      subject: 'Resend Test - Elevate',
      html: '<h1>✅ It Works!</h1><p>Resend is configured correctly.</p>',
      text: 'It works! Resend is configured correctly.',
    });

    if (error) {
      console.error('❌ Failed:', error);
      process.exit(1);
    }

    console.log('✅ SUCCESS! Email sent');
    console.log('📧 Email ID:', data.id);
    console.log('\\n✓ Check your inbox!\\n');
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
})();
```

---

### **Step 5: Test the Integration**

```bash
# Navigate to backend
cd D:\Elevate-Backend\backend

# Edit test-resend.js and replace YOUR_EMAIL@example.com with your actual email

# Run the test
node test-resend.js

# You should see:
# ✓ RESEND_API_KEY is set
# ✅ SUCCESS! Email sent
# 📧 Email ID: xxx
# ✓ Check your inbox!
```

---

### **Step 6: Restart Backend Server**

```bash
# Stop the server (Ctrl+C)
# Then restart:
npm start
```

---

### **Step 7: Test Forgot Password Flow**

**From your Flutter app:**
1. Open the app
2. Click "Forgot Password?" on login screen
3. Enter your email
4. Click "Send Reset Link"
5. Check your email inbox
6. Click the reset link in the email
7. Enter new password
8. Should receive confirmation email
9. Login with new password

---

## 📊 Summary of Changes

| Location | Action | File |
|----------|--------|------|
| **Flutter** | ✅ Nothing | Already complete! |
| **Backend** | 🔧 Install | `npm install resend` |
| **Backend** | 🔧 Update | `.env` |
| **Backend** | 🔧 Replace | `services/emailService.js` |
| **Backend** | ✨ Create | `test-resend.js` (optional) |

---

## 🔒 Important Security Steps

Before going to production:

1. **Regenerate API Key** (the shared key is compromised!)
   - Go to https://resend.com/api-keys
   - Delete old key
   - Create new key
   - Update `.env`

2. **Verify Your Domain**
   - Go to https://resend.com/domains
   - Add `elevateintune.com`
   - Add DNS records (SPF, DKIM)
   - Wait for verification
   - Update `EMAIL_FROM` to `Elevate <noreply@elevateintune.com>`

3. **Update Production Environment**
   - Set all environment variables on production server
   - Use production `FRONTEND_URL`
   - Test email delivery

---

## ❓ Troubleshooting

**Emails not sending?**
- Check `.env` has `RESEND_API_KEY`
- Verify API key is valid at https://resend.com/api-keys
- Check backend console for error messages
- Run `node test-resend.js` to isolate the issue

**Emails going to spam?**
- Verify your domain at https://resend.com/domains
- Add proper SPF/DKIM DNS records
- Use verified domain in `EMAIL_FROM`

**API key error?**
- The shared key is compromised - regenerate it
- Make sure `.env` is loaded (`require('dotenv').config()`)
- Check for typos in `.env` file

---

## ✅ Checklist

- [ ] Install Resend: `npm install resend`
- [ ] Update `.env` with `RESEND_API_KEY`
- [ ] Replace `services/emailService.js`
- [ ] Create and run `test-resend.js`
- [ ] Restart backend server
- [ ] Test forgot password from Flutter app
- [ ] Verify email received
- [ ] Test password reset
- [ ] Verify confirmation email received
- [ ] Test login with new password
- [ ] **Regenerate API key before production!**
- [ ] Verify domain for production

---

## 🎉 That's It!

Your Flutter app doesn't need ANY changes - it's already perfect! Just update your backend with these 3 simple changes and you're done.

**Questions?** Check the Resend docs at https://resend.com/docs

