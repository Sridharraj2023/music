import 'package:shared_preferences/shared_preferences.dart';
import 'package:elevate/Controller/Subscription_Controller.dart';

/// Utility to debug subscription flow and help verify the login process
class SubscriptionFlowDebug {
  
  /// Debug the current user's subscription status
  /// This helps verify if the login flow is working correctly
  static Future<void> debugSubscriptionStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Get user info
      String? userEmail = prefs.getString('email');
      String? authToken = prefs.getString('auth_token');
      String? paymentDateStr = prefs.getString('payment_date');
      
      print('=== SUBSCRIPTION FLOW DEBUG ===');
      print('User Email: $userEmail');
      print('Auth Token: ${authToken != null ? "Present" : "Missing"}');
      print('Payment Date: $paymentDateStr');
      
      if (userEmail == null) {
        print('❌ No user email found - user not logged in');
        return;
      }
      
      // Check subscription status
      final SubscriptionController subscriptionController = SubscriptionController();
      final status = await subscriptionController.checkSubscriptionStatus(userEmail);
      
      print('Subscription Status: $status');
      
      // Check recent payment
      bool hasRecentPayment = false;
      if (paymentDateStr != null) {
        try {
          DateTime paymentDate = DateTime.parse(paymentDateStr);
          DateTime now = DateTime.now();
          hasRecentPayment = now.difference(paymentDate).inDays < 7;
          print('Recent Payment (within 7 days): $hasRecentPayment');
        } catch (e) {
          print('Error parsing payment date: $e');
        }
      } else {
        print('Recent Payment: No payment date found');
      }
      
      // Determine access level
      bool hasActiveSubscription = status != null && status['isActive'] == true;
      bool shouldHaveAccess = hasActiveSubscription || hasRecentPayment;
      
      print('Has Active Subscription: $hasActiveSubscription');
      print('Should Have Access: $shouldHaveAccess');
      
      if (shouldHaveAccess) {
        print('✅ User should be redirected to HOMEPAGE');
      } else {
        print('❌ User should be redirected to SUBSCRIPTION TIER SCREEN');
      }
      
      print('=== END DEBUG ===');
      
    } catch (e) {
      print('Error in subscription flow debug: $e');
    }
  }
  
  /// Clear all user data for testing
  static Future<void> clearAllUserData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      await prefs.remove('auth_token');
      await prefs.remove('email');
      await prefs.remove('name');
      await prefs.remove('id');
      await prefs.remove('payment_date');
      
      print('All user data cleared for testing');
    } catch (e) {
      print('Error clearing user data: $e');
    }
  }
  
  /// Simulate a user without payment for testing
  static Future<void> simulateUserWithoutPayment() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Set user data but no payment date
      await prefs.setString('email', 'test@example.com');
      await prefs.setString('name', 'Test User');
      await prefs.setString('auth_token', 'test_token');
      
      // Ensure no payment date
      await prefs.remove('payment_date');
      
      print('Simulated user without payment for testing');
    } catch (e) {
      print('Error simulating user without payment: $e');
    }
  }
}
