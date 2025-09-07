import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // API Configuration
  static String get apiUrl => dotenv.env['API_URL'] ?? "http://192.168.0.100:5000/api";
  
  // Stripe Configuration (Publishable Key only - safe for frontend)
  static String get publishKey => dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? 'pk_test_51RqimhIjXTLOotvoR7Z3f1z7Ud8BWXwKOjDHoGLnhM8QIMdJS31JVZ0zqpAPTghFS0GZ9NwIl4zT1I3mkvzfRatm00isg3USh7';
  
  // Secret Key (should only be used in backend, but keeping for reference)
  static String get secretKey => dotenv.env['STRIPE_SECRET_KEY'] ?? 'sk_test_your_stripe_secret_key_here';
  
  // Stripe Price ID (hardcoded)
  static const String priceId = 'price_1S2wmjIjXTLOotvon7MPBu3q';
}
