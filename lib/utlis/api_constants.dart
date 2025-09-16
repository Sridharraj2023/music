import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // API Configuration
  static String get apiUrl => dotenv.env['API_URL'] ?? "http://192.168.0.101:5000/api";
  
  // Stripe Configuration (Publishable Key only - safe for frontend)
  static String get publishKey => dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? 'pk_test_51RqimhIjXTLOotvoR7Z3f1z7Ud8BWXwKOjDHoGLnhM8QIMdJS31JVZ0zqpAPTghFS0GZ9NwIl4zT1I3mkvzfRatm00isg3USh7';
  
  // Secret Key (should only be used in backend, but keeping for reference)
  static String get secretKey => dotenv.env['STRIPE_SECRET_KEY'] ?? 'sk_test_your_stripe_secret_key_here';
  
  // Stripe Price ID (hardcoded)
  static const String priceId = 'price_1S2wmjIjXTLOotvon7MPBu3q';
  
  // Debug method to print all environment variables
  static void printEnvVars() {
    print('=== Environment Variables Debug ===');
    print('API_URL: ${dotenv.env['API_URL']}');
    print('STRIPE_PUBLISHABLE_KEY: ${dotenv.env['STRIPE_PUBLISHABLE_KEY']}');
    print('STRIPE_SECRET_KEY: ${dotenv.env['STRIPE_SECRET_KEY']}');
    print('ENVIRONMENT: ${dotenv.env['ENVIRONMENT']}');
    print('===================================');
  }
  
  // Method to manually override API URL (for testing)
  static String? _overrideApiUrl;
  static void setApiUrlOverride(String url) {
    _overrideApiUrl = url;
    print('API URL overridden to: $url');
  }
  
  // Get API URL with override support
  static String get resolvedApiUrl => _overrideApiUrl ?? apiUrl;
  
  // Convenience methods for switching between environments
  static void useLocalServer() {
    setApiUrlOverride("http://192.168.0.101:5000/api");
  }
  
  static void useProductionServer() {
    setApiUrlOverride("https://api.elevateintune.com/api");
  }
  
  static void resetToEnvDefault() {
    _overrideApiUrl = null;
    print('API URL reset to environment default: $apiUrl');
  }
}
