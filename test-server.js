const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 5000;
const HOST = '0.0.0.0'; // Listen on all interfaces

// Enable CORS for all routes
app.use(cors({
  origin: ['http://localhost:3000', 'http://192.168.0.15:3000', 'http://10.0.2.2:3000'],
  credentials: true
}));

// Parse JSON bodies
app.use(express.json());

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'OK',
    message: 'Backend server is running',
    timestamp: new Date().toISOString(),
    port: PORT
  });
});

// Test auth endpoint
app.post('/api/users/auth', (req, res) => {
  console.log('Auth request received:', req.body);
  res.json({
    success: true,
    message: 'Auth endpoint working',
    data: req.body
  });
});

// Test subscription endpoints
app.get('/api/subscriptions/status', (req, res) => {
  res.json({
    success: true,
    subscription: null,
    message: 'No active subscription'
  });
});

app.post('/api/subscriptions/create', (req, res) => {
  console.log('Subscription create request:', req.body);
  res.json({
    success: true,
    subscription: {
      id: 'test_sub_123',
      status: 'pending',
      clientSecret: 'pi_test_client_secret_123'
    }
  });
});

// Start server
app.listen(PORT, HOST, () => {
  console.log(`🚀 Test server running on http://${HOST}:${PORT}`);
  console.log(`📱 API Base URL: http://192.168.0.15:${PORT}/api`);
  console.log(`🌍 Health check: http://192.168.0.15:${PORT}/api/health`);
});

module.exports = app;

