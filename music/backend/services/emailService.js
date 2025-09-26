import nodemailer from 'nodemailer';

class EmailService {
  constructor() {
    this.transporter = nodemailer.createTransport({
      service: 'gmail', // or your preferred email service
      auth: {
        user: process.env.EMAIL_USER,
        pass: process.env.EMAIL_PASS,
      },
    });
  }

  async sendReminderEmail(user, reminderType, remainingDays) {
    const template = this.getEmailTemplate(reminderType, user, remainingDays);
    
    const mailOptions = {
      from: process.env.EMAIL_FROM || 'noreply@elevate.com',
      to: user.email,
      subject: template.subject,
      html: template.html,
      text: template.text,
    };

    try {
      const result = await this.transporter.sendMail(mailOptions);
      console.log('Email sent successfully:', result.messageId);
      return { success: true, messageId: result.messageId };
    } catch (error) {
      console.error('Error sending email:', error);
      return { success: false, error: error.message };
    }
  }

  getEmailTemplate(reminderType, user, remainingDays) {
    const expiryDate = this.calculateExpiryDate(user.subscription.paymentDate);
    const renewalLink = `${process.env.FRONTEND_URL}/subscription/renew`;
    
    const templates = {
      '7day_reminder': {
        subject: 'Your Elevate Subscription Expires in 7 Days',
        html: this.get7DayReminderHTML(user.name, expiryDate, remainingDays, renewalLink),
        text: this.get7DayReminderText(user.name, expiryDate, remainingDays, renewalLink),
      },
      '3day_reminder': {
        subject: 'Your Elevate Subscription Expires in 3 Days',
        html: this.get3DayReminderHTML(user.name, expiryDate, remainingDays, renewalLink),
        text: this.get3DayReminderText(user.name, expiryDate, remainingDays, renewalLink),
      },
      '1day_reminder': {
        subject: 'Your Elevate Subscription Expires Tomorrow',
        html: this.get1DayReminderHTML(user.name, expiryDate, remainingDays, renewalLink),
        text: this.get1DayReminderText(user.name, expiryDate, remainingDays, renewalLink),
      },
      'expired_reminder': {
        subject: 'Your Elevate Subscription Has Expired',
        html: this.getExpiredReminderHTML(user.name, expiryDate, renewalLink),
        text: this.getExpiredReminderText(user.name, expiryDate, renewalLink),
      },
    };

    return templates[reminderType] || templates['7day_reminder'];
  }

  calculateExpiryDate(paymentDate) {
    if (!paymentDate) return null;
    const expiry = new Date(paymentDate);
    expiry.setDate(expiry.getDate() + 30);
    return expiry.toLocaleDateString();
  }

  get7DayReminderHTML(name, expiryDate, remainingDays, renewalLink) {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <title>Subscription Expiring Soon</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #6F41F3; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background-color: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
          .highlight { background-color: #fff3cd; padding: 15px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #ffc107; }
          .button { background-color: #6F41F3; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px; display: inline-block; margin: 20px 0; }
          .footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🎵 Elevate Music</h1>
            <h2>Subscription Reminder</h2>
          </div>
          <div class="content">
            <h3>Hi ${name},</h3>
            <p>Your Elevate subscription will expire in <strong>${remainingDays} days</strong>. Don't lose access to your premium music features!</p>
            
            <div class="highlight">
              <h4>📅 Subscription Details:</h4>
              <p><strong>Expiry Date:</strong> ${expiryDate}</p>
              <p><strong>Days Remaining:</strong> ${remainingDays}</p>
            </div>
            
            <p>Continue enjoying unlimited access to:</p>
            <ul>
              <li>🎵 Unlimited music streaming</li>
              <li>📱 Offline downloads</li>
              <li>🎧 High-quality audio</li>
              <li>🚫 Ad-free experience</li>
            </ul>
            
            <div style="text-align: center;">
              <a href="${renewalLink}" class="button">🔄 Renew Subscription</a>
            </div>
            
            <p>If you have any questions or need assistance, please don't hesitate to contact our support team.</p>
            
            <div class="footer">
              <p>Best regards,<br>The Elevate Team</p>
              <p>This is an automated message. Please do not reply to this email.</p>
            </div>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  get3DayReminderHTML(name, expiryDate, remainingDays, renewalLink) {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <title>Subscription Expiring Soon</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #ff6b35; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background-color: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
          .highlight { background-color: #f8d7da; padding: 15px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #dc3545; }
          .button { background-color: #dc3545; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px; display: inline-block; margin: 20px 0; }
          .footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>⚠️ Elevate Music</h1>
            <h2>Urgent: Subscription Expiring Soon</h2>
          </div>
          <div class="content">
            <h3>Hi ${name},</h3>
            <p><strong>URGENT:</strong> Your Elevate subscription will expire in just <strong>${remainingDays} days</strong>!</p>
            
            <div class="highlight">
              <h4>🚨 Action Required:</h4>
              <p><strong>Expiry Date:</strong> ${expiryDate}</p>
              <p><strong>Days Remaining:</strong> ${remainingDays}</p>
            </div>
            
            <p>Don't lose access to your premium music experience. Renew now to continue enjoying:</p>
            <ul>
              <li>🎵 Unlimited music streaming</li>
              <li>📱 Offline downloads</li>
              <li>🎧 High-quality audio</li>
              <li>🚫 Ad-free experience</li>
            </ul>
            
            <div style="text-align: center;">
              <a href="${renewalLink}" class="button">🔄 Renew Now</a>
            </div>
            
            <p><strong>Need help?</strong> Contact our support team for assistance.</p>
            
            <div class="footer">
              <p>Best regards,<br>The Elevate Team</p>
              <p>This is an automated message. Please do not reply to this email.</p>
            </div>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  get1DayReminderHTML(name, expiryDate, remainingDays, renewalLink) {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <title>Subscription Expires Tomorrow</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #dc3545; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background-color: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
          .highlight { background-color: #f8d7da; padding: 15px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #dc3545; }
          .button { background-color: #dc3545; color: white; padding: 15px 30px; text-decoration: none; border-radius: 8px; display: inline-block; margin: 20px 0; font-size: 16px; font-weight: bold; }
          .footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🚨 Elevate Music</h1>
            <h2>LAST CHANCE: Subscription Expires Tomorrow!</h2>
          </div>
          <div class="content">
            <h3>Hi ${name},</h3>
            <p><strong>FINAL REMINDER:</strong> Your Elevate subscription expires <strong>tomorrow</strong>!</p>
            
            <div class="highlight">
              <h4>⏰ Time is Running Out:</h4>
              <p><strong>Expiry Date:</strong> ${expiryDate}</p>
              <p><strong>Status:</strong> Expires in 24 hours</p>
            </div>
            
            <p>This is your last chance to renew and keep your premium music experience. Don't let your subscription lapse!</p>
            
            <div style="text-align: center;">
              <a href="${renewalLink}" class="button">🔄 RENEW NOW</a>
            </div>
            
            <p><strong>Questions?</strong> Our support team is here to help you renew your subscription.</p>
            
            <div class="footer">
              <p>Best regards,<br>The Elevate Team</p>
              <p>This is an automated message. Please do not reply to this email.</p>
            </div>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  getExpiredReminderHTML(name, expiryDate, renewalLink) {
    return `
      <!DOCTYPE html>
      <html>
      <head>
        <title>Subscription Expired</title>
        <style>
          body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
          .container { max-width: 600px; margin: 0 auto; padding: 20px; }
          .header { background-color: #6c757d; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
          .content { background-color: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px; }
          .highlight { background-color: #f8d7da; padding: 15px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #dc3545; }
          .button { background-color: #6F41F3; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px; display: inline-block; margin: 20px 0; }
          .footer { text-align: center; margin-top: 30px; color: #666; font-size: 14px; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>📵 Elevate Music</h1>
            <h2>Subscription Expired</h2>
          </div>
          <div class="content">
            <h3>Hi ${name},</h3>
            <p>Your Elevate subscription expired on <strong>${expiryDate}</strong>. We miss you!</p>
            
            <div class="highlight">
              <h4>📅 Subscription Status:</h4>
              <p><strong>Expiry Date:</strong> ${expiryDate}</p>
              <p><strong>Status:</strong> Expired</p>
            </div>
            
            <p>Don't worry - you can reactivate your subscription anytime and get back to enjoying:</p>
            <ul>
              <li>🎵 Unlimited music streaming</li>
              <li>📱 Offline downloads</li>
              <li>🎧 High-quality audio</li>
              <li>🚫 Ad-free experience</li>
            </ul>
            
            <div style="text-align: center;">
              <a href="${renewalLink}" class="button">🔄 Reactivate Subscription</a>
            </div>
            
            <p>We'd love to have you back! Contact our support team if you need any assistance.</p>
            
            <div class="footer">
              <p>Best regards,<br>The Elevate Team</p>
              <p>This is an automated message. Please do not reply to this email.</p>
            </div>
          </div>
        </div>
      </body>
      </html>
    `;
  }

  // Text versions for email clients that don't support HTML
  get7DayReminderText(name, expiryDate, remainingDays, renewalLink) {
    return `
Hi ${name},

Your Elevate subscription will expire in ${remainingDays} days. Don't lose access to your premium music features!

Subscription Details:
- Expiry Date: ${expiryDate}
- Days Remaining: ${remainingDays}

Continue enjoying unlimited access to:
- Unlimited music streaming
- Offline downloads
- High-quality audio
- Ad-free experience

Renew your subscription: ${renewalLink}

If you have any questions, please contact our support team.

Best regards,
The Elevate Team
    `;
  }

  get3DayReminderText(name, expiryDate, remainingDays, renewalLink) {
    return `
Hi ${name},

URGENT: Your Elevate subscription will expire in just ${remainingDays} days!

Action Required:
- Expiry Date: ${expiryDate}
- Days Remaining: ${remainingDays}

Don't lose access to your premium music experience. Renew now!

Renew your subscription: ${renewalLink}

Need help? Contact our support team for assistance.

Best regards,
The Elevate Team
    `;
  }

  get1DayReminderText(name, expiryDate, remainingDays, renewalLink) {
    return `
Hi ${name},

FINAL REMINDER: Your Elevate subscription expires tomorrow!

Time is Running Out:
- Expiry Date: ${expiryDate}
- Status: Expires in 24 hours

This is your last chance to renew and keep your premium music experience!

Renew now: ${renewalLink}

Questions? Our support team is here to help you renew your subscription.

Best regards,
The Elevate Team
    `;
  }

  getExpiredReminderText(name, expiryDate, renewalLink) {
    return `
Hi ${name},

Your Elevate subscription expired on ${expiryDate}. We miss you!

Subscription Status:
- Expiry Date: ${expiryDate}
- Status: Expired

Don't worry - you can reactivate your subscription anytime and get back to enjoying:
- Unlimited music streaming
- Offline downloads
- High-quality audio
- Ad-free experience

Reactivate your subscription: ${renewalLink}

We'd love to have you back! Contact our support team if you need any assistance.

Best regards,
The Elevate Team
    `;
  }
}

export default new EmailService();
