import 'package:shared_preferences/shared_preferences.dart';
import 'package:elevate/Controller/Subscription_Controller.dart';

/// Utility to clear false payment data for users who haven't actually made payments
class ClearFalsePaymentData {
  
  /// Clear any false payment date data for the current user
  /// This is useful when users sign up but haven't made actual payments
  static Future<void> clearFalsePaymentData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      // Get user email
      String? userEmail = prefs.getString('email');
      if (userEmail == null) return;
      
      // Check subscription status
      final SubscriptionController subscriptionController = SubscriptionController();
      final status = await subscriptionController.checkSubscriptionStatus(userEmail);
      
      // If user doesn't have active subscription, clear payment date
      if (status == null || status['isActive'] != true) {
        String? paymentDateString = prefs.getString('payment_date');
        if (paymentDateString != null) {
          print('Clearing false payment date for user: $userEmail');
          await prefs.remove('payment_date');
          print('False payment data cleared successfully');
        }
      }
    } catch (e) {
      print('Error clearing false payment data: $e');
    }
  }
  
  /// Force clear payment date regardless of subscription status
  /// Use this for debugging purposes
  static Future<void> forceClearPaymentData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('email');
      
      await prefs.remove('payment_date');
      print('Payment data force cleared for user: $userEmail');
    } catch (e) {
      print('Error force clearing payment data: $e');
    }
  }
}
