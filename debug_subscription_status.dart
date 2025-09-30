// Debug script to help troubleshoot subscription status issues
// Run this in your Flutter app to get detailed subscription information

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'lib/utlis/api_constants.dart';

class SubscriptionDebugger {
  static Future<void> debugSubscriptionStatus() async {
    print('=== SUBSCRIPTION DEBUG REPORT ===');
    
    try {
      // 1. Check local storage
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');
      String? email = prefs.getString('email');
      String? paymentDate = prefs.getString('payment_date');
      
      print('1. LOCAL STORAGE:');
      print('   Auth Token: ${token != null ? "Present (${token.substring(0, 20)}...)" : "Missing"}');
      print('   Email: ${email ?? "Missing"}');
      print('   Payment Date: ${paymentDate ?? "Missing"}');
      
      if (paymentDate != null) {
        try {
          DateTime paymentDateTime = DateTime.parse(paymentDate);
          DateTime now = DateTime.now();
          int daysSincePayment = now.difference(paymentDateTime).inDays;
          print('   Days since payment: $daysSincePayment');
          print('   Payment is recent (< 7 days): ${daysSincePayment < 7}');
        } catch (e) {
          print('   Error parsing payment date: $e');
        }
      }
      
      if (token == null || email == null) {
        print('\n❌ Cannot proceed - missing authentication data');
        return;
      }
      
      // 2. Check backend subscription status
      print('\n2. BACKEND SUBSCRIPTION STATUS:');
      try {
        final response = await http.get(
          Uri.parse("${ApiConstants.resolvedApiUrl}/subscriptions/status"),
          headers: {
            "Authorization": "Bearer $token",
            "Content-Type": "application/json"
          },
        );
        
        print('   Status Code: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('   Response: ${jsonEncode(data)}');
          
          if (data['subscription'] != null) {
            final subscription = data['subscription'];
            print('   Subscription ID: ${subscription['id'] ?? "Missing"}');
            print('   Status: ${subscription['status'] ?? "Missing"}');
            print('   Is Active: ${subscription['isActive'] ?? "Missing"}');
            print('   Current Period End: ${subscription['currentPeriodEnd'] ?? "Missing"}');
          } else {
            print('   ❌ No subscription found in response');
          }
        } else {
          print('   ❌ Error response: ${response.body}');
        }
      } catch (e) {
        print('   ❌ Error calling backend: $e');
      }
      
      // 3. Check billing status
      print('\n3. BILLING STATUS:');
      try {
        final response = await http.get(
          Uri.parse("${ApiConstants.resolvedApiUrl}/users/billing"),
          headers: {
            "Authorization": "Bearer $token",
          },
        );
        
        print('   Status Code: ${response.statusCode}');
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('   Response: ${jsonEncode(data)}');
          print('   Has Default Payment Method: ${data['hasDefaultPaymentMethod'] ?? "Missing"}');
          print('   Auto Debit Enabled: ${data['autoDebit'] ?? "Missing"}');
        } else {
          print('   ❌ Error response: ${response.body}');
        }
      } catch (e) {
        print('   ❌ Error calling billing endpoint: $e');
      }
      
      // 4. Test fix-status endpoint
      print('\n4. TESTING FIX-STATUS ENDPOINT:');
      try {
        final response = await http.post(
          Uri.parse("${ApiConstants.resolvedApiUrl}/subscriptions/fix-status"),
          headers: {
            "Authorization": "Bearer $token",
          },
        );
        
        print('   Status Code: ${response.statusCode}');
        print('   Response: ${response.body}');
        
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          print('   ✅ Fix-status successful');
          print('   Message: ${data['message'] ?? "No message"}');
          if (data['subscription'] != null) {
            print('   Fixed Subscription Status: ${data['subscription']['status']}');
            print('   Fixed Is Active: ${data['subscription']['isActive']}');
          }
        }
      } catch (e) {
        print('   ❌ Error calling fix-status: $e');
      }
      
      // 5. Recommendations
      print('\n5. RECOMMENDATIONS:');
      if (paymentDate != null) {
        try {
          DateTime paymentDateTime = DateTime.parse(paymentDate);
          DateTime now = DateTime.now();
          int daysSincePayment = now.difference(paymentDateTime).inDays;
          
          if (daysSincePayment < 7) {
            print('   ✅ Recent payment found - subscription should be active');
            print('   💡 Try calling fix-status endpoint to resolve any sync issues');
          } else {
            print('   ⚠️  Payment is older than 7 days - may need to renew');
          }
        } catch (e) {
          print('   ❌ Cannot parse payment date');
        }
      } else {
        print('   ❌ No payment date found - user may not have made a payment');
      }
      
    } catch (e) {
      print('❌ Debug error: $e');
    }
    
    print('\n=== END DEBUG REPORT ===');
  }
  
  static Future<void> clearPaymentData() async {
    print('=== CLEARING PAYMENT DATA ===');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('payment_date');
    print('✅ Payment date cleared');
    print('=== DONE ===');
  }
  
  static Future<void> setTestPaymentDate() async {
    print('=== SETTING TEST PAYMENT DATE ===');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String testDate = DateTime.now().toIso8601String();
    await prefs.setString('payment_date', testDate);
    print('✅ Test payment date set to: $testDate');
    print('=== DONE ===');
  }
}

// Usage examples:
// SubscriptionDebugger.debugSubscriptionStatus();
// SubscriptionDebugger.clearPaymentData();
// SubscriptionDebugger.setTestPaymentDate();
