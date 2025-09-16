# Notification System Setup Guide

## Environment Variables Required

Add these environment variables to your `.env` file:

```env
# Email Configuration
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password
EMAIL_FROM=noreply@elevate.com

# Frontend URL (for email links)
FRONTEND_URL=https://your-app.com

# Firebase Configuration (for push notifications)
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-client-email
```

## Email Service Setup

### Gmail Setup
1. Enable 2-factor authentication on your Gmail account
2. Generate an App Password:
   - Go to Google Account settings
   - Security → 2-Step Verification → App passwords
   - Generate password for "Mail"
   - Use this password as `EMAIL_PASS`

### Other Email Services
You can modify `emailService.js` to use other services like:
- SendGrid
- Mailgun
- AWS SES

## Firebase Setup (for Push Notifications)

1. Create a Firebase project
2. Enable Cloud Messaging
3. Download service account key
4. Add the credentials to your environment variables

## Installation

1. Install required dependencies:
```bash
npm install node-cron nodemailer firebase-admin
```

2. Start the server:
```bash
npm start
```

The notification scheduler will automatically start and run daily checks.

## Testing

### Test Email Notifications
```bash
curl -X POST http://localhost:5000/api/notifications/test \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"reminderType": "7day_reminder"}'
```

### Manual Notification Check
```bash
curl -X POST http://localhost:5000/api/notifications/trigger-check \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

### Get Notification Stats
```bash
curl -X GET http://localhost:5000/api/notifications/stats \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Flutter Setup

1. Add dependencies to `pubspec.yaml`:
```yaml
dependencies:
  firebase_core: ^3.6.0
  firebase_messaging: ^15.1.3
  flutter_local_notifications: ^18.0.1
  permission_handler: ^11.3.1
```

2. Run `flutter pub get`

3. Configure Firebase for your Flutter app:
   - Add `google-services.json` (Android)
   - Add `GoogleService-Info.plist` (iOS)

## Notification Flow

1. **Daily Check**: Cron job runs every day at 9:00 AM UTC
2. **User Filtering**: Finds users with incomplete subscriptions
3. **Date Calculation**: Calculates remaining days until expiry
4. **Reminder Logic**: Determines which reminder to send (7, 3, 1 days, or expired)
5. **Preference Check**: Verifies user has enabled this reminder type
6. **Duplicate Check**: Ensures no duplicate reminders within 24 hours
7. **Email Sending**: Sends formatted email with renewal link
8. **Logging**: Records notification in database for tracking

## Customization

### Email Templates
Modify templates in `emailService.js`:
- `get7DayReminderHTML()`
- `get3DayReminderHTML()`
- `get1DayReminderHTML()`
- `getExpiredReminderHTML()`

### Reminder Timing
Modify cron schedule in `notificationScheduler.js`:
```javascript
// Run every day at 9:00 AM UTC
cron.schedule('0 9 * * *', async () => {
  await this.checkExpiringSubscriptions();
});
```

### Notification Frequency
Users can customize their preferences through the Flutter app:
- Email reminders on/off
- Push notifications on/off
- Reminder frequency (7, 3, 1 days, expired)
- Preferred notification time
- Timezone

## Monitoring

### Health Checks
The system includes automatic health checks:
- Monitors notification delivery rates
- Alerts on high failure rates
- Tracks system performance

### Analytics
Track notification effectiveness:
- Open rates
- Click-through rates
- Renewal conversions
- Churn reduction

## Troubleshooting

### Common Issues

1. **Emails not sending**:
   - Check email credentials
   - Verify SMTP settings
   - Check spam folder

2. **Push notifications not working**:
   - Verify Firebase configuration
   - Check FCM token registration
   - Ensure app has notification permissions

3. **Scheduler not running**:
   - Check server logs
   - Verify cron job is active
   - Test manual trigger

### Debug Mode
Enable debug logging by setting:
```env
DEBUG=notification:*
```

## Production Deployment

1. **Environment Variables**: Set all required environment variables
2. **Database**: Ensure MongoDB is accessible
3. **Email Service**: Use production email service (SendGrid, etc.)
4. **Monitoring**: Set up monitoring and alerts
5. **Backup**: Regular database backups
6. **SSL**: Use HTTPS for all endpoints

## Security Considerations

1. **Authentication**: All endpoints require valid JWT tokens
2. **Rate Limiting**: Implement rate limiting for notification endpoints
3. **Data Privacy**: Follow GDPR/privacy regulations
4. **Email Security**: Use secure SMTP connections
5. **Token Management**: Secure FCM token storage
