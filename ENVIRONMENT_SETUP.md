# Environment Setup Guide

## Overview
This project uses environment variables to securely manage sensitive configuration like API keys and URLs. The sensitive data is no longer hardcoded in the source code.

## Required Environment Variables

Create a `.env` file in the root directory with the following variables:

```bash
# API Configuration
API_URL=https://api.elevateintune.com/api

# Stripe Configuration
STRIPE_SECRET_KEY=your_stripe_secret_key_here
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key_here

# Environment
ENVIRONMENT=development
```

## Setup Instructions

1. **Copy the template**: Copy `env.example` to `.env`
   ```bash
   cp env.example .env
   ```

2. **Fill in your values**: Replace the placeholder values with your actual API keys and configuration

3. **Never commit .env**: The `.env` file is already in `.gitignore` and should never be committed to version control

4. **Install dependencies**: Run `flutter pub get` to install the `flutter_dotenv` package

## Security Notes

- ✅ **DO**: Use environment variables for sensitive data
- ✅ **DO**: Keep `.env` file local and never commit it
- ✅ **DO**: Use `env.example` as a template for team members
- ❌ **DON'T**: Hardcode API keys in source code
- ❌ **DON'T**: Commit `.env` files to version control
- ❌ **DON'T**: Share API keys in public repositories

## Production Deployment

For production deployment:
1. Set environment variables on your deployment platform
2. Use production API keys (not test keys)
3. Ensure `.env` files are not included in production builds

## Troubleshooting

If you get errors about missing environment variables:
1. Check that `.env` file exists in the root directory
2. Verify all required variables are set
3. Ensure `.env` is included in `pubspec.yaml` assets
4. Restart the app after making changes to `.env`
