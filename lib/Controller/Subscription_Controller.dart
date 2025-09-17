// controllers/subscription_controller.dart

import 'dart:convert';

import 'package:elevate/View/Screens/Homepage_Screen.dart';
import 'package:elevate/View/Screens/Login_Screen.dart';
import 'package:elevate/utlis/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Model/Subscription_Tiers.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

class SubscriptionController {
  bool isActive = false;
  DateTime? expiryDate;
  String? subscriptionStatus;
  bool autoDebitEnabled = false;
  bool hasDefaultPaymentMethod = false;
  List<SubscriptionTier> getSubscriptionTiers() {
    return [
      
      SubscriptionTier(
          title: 'Standard',
          monthlyCost: '\$5.00',
          annualCost: '\$54.00',
          adSupported: 'No',
          audioFileType: '320 kbps MF3',
          offlineDownloads: '0',
          binauralTracks: '3 Every',
          soundscapeTracks: 'All',
          dynamicAudioFeatures: 'No',
          customTrackRequests: 'No',
          priceId: ApiConstants.priceId),
       ];
  }

  Future<void> createSubscription(
      BuildContext context, String pricePlan) async {
    try {
      // Get user email from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        await prefs.remove('auth_token');
        await prefs.remove('email');
        throw Exception("Session expired. Please login again.");
      }

      // Call your backend API to create subscription
      final response = await http.post(
        Uri.parse("${ApiConstants.resolvedApiUrl}/subscriptions/create"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "priceId": pricePlan,
        }),
      );

      if (response.statusCode == 200) {
        // Success - continue with existing logic
      } else if (response.statusCode == 401) {
        // Token expired or invalid - clear it and redirect to login
        await prefs.remove('auth_token');
        await prefs.remove('email');
        throw Exception("Session expired. Please login again.");
      } else {
        final errorData = jsonDecode(response.body);
        print("Subscription creation error: ${errorData}");
        
        // Handle specific error messages
        String errorMessage = errorData['message'] ?? "Subscription creation failed";
        if (errorMessage.contains('Payment method configuration error') || 
            errorMessage.contains('Payment setup error')) {
          errorMessage = "Payment setup error. Please try again.";
        } else if (errorMessage.contains('Invalid subscription plan')) {
          errorMessage = "Subscription plan error. Please contact support.";
        } else if (errorMessage.contains('Customer account error')) {
          errorMessage = "Account error. Please try again.";
        } else if (errorMessage.contains('Invoice processing error')) {
          errorMessage = "Payment processing error. Please try again.";
        } else if (errorMessage.contains('Payment method attachment error')) {
          errorMessage = "Payment method attachment error. Please try again.";
        }
        
        throw Exception(errorMessage);
      }

      final subscriptionData = jsonDecode(response.body);
      
      // Debug: Print what backend returned
      print("Backend response: $subscriptionData");
      
      // Check if subscription data exists
      if (subscriptionData["subscription"] == null) {
        throw Exception("No subscription data in response");
      }
      
      // Check if clientSecret exists
      if (subscriptionData["subscription"]["clientSecret"] == null) {
        print("Available keys in subscription: ${subscriptionData["subscription"].keys}");
        print("Full subscription data: ${subscriptionData["subscription"]}");
        throw Exception("Subscription created but no payment intent was generated. Please try again.");
      }
      
      // Extract payment intent ID from client secret
      String clientSecret = subscriptionData["subscription"]["clientSecret"];
      String paymentIntentId = clientSecret.split('_secret_')[0];
      print("Payment intent ID: $paymentIntentId");
      
      // Handle mobile platforms with client secret from backend
      print("Initializing payment sheet with client secret: ${subscriptionData["subscription"]["clientSecret"]}");
      
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: subscriptionData["subscription"]["clientSecret"],
          merchantDisplayName: 'Elevate',
          style: ThemeMode.system,
          allowsDelayedPaymentMethods: true,
        ),
      );
      
      print("Payment sheet initialized successfully");

      print("Payment sheet initialized, presenting...");
      await Stripe.instance.presentPaymentSheet();
      print("Payment sheet completed");
      
      // Save payment date immediately after successful payment
      await prefs.setString('payment_date', DateTime.now().toIso8601String());
      
      // After successful payment, update subscription with payment method
      print("Updating subscription with payment method...");
      final paymentConfirmed = await updateSubscriptionPaymentMethod(paymentIntentId);
      
      if (paymentConfirmed) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Subscription Successful!")));
        Get.off(() => const HomePage());
      } else {
        // Try checking status with more retries and longer delays
        bool subscriptionActive = false;
        for (int i = 0; i < 5; i++) {
          await Future.delayed(Duration(seconds: 3));
          final statusCheck = await checkSubscriptionStatus(prefs.getString('email') ?? '');
          if (statusCheck != null && statusCheck['isActive'] == true) {
            subscriptionActive = true;
            break;
          }
          print("Retry ${i + 1}: Subscription not active yet, checking again...");
        }
        
        if (subscriptionActive) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Subscription Successful!")));
          Get.off(() => const HomePage());
        } else {
          // Try the fix-status endpoint as fallback
          print("Trying fix-status endpoint as fallback...");
          final fixResult = await fixSubscriptionStatus();
          if (fixResult) {
            ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Subscription Successful!")));
            Get.off(() => const HomePage());
          } else {
            // Try one more time with the confirm payment endpoint
            print("Trying confirm payment endpoint as final fallback...");
            final confirmResult = await confirmPayment();
            if (confirmResult) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Subscription Successful!")));
              Get.off(() => const HomePage());
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Payment completed but subscription activation is delayed. Please refresh the app or contact support.")));
            }
          }
        }
      }
    } catch (e) {
      print("Error: $e");
      
      // Handle specific Stripe errors
      if (e.toString().contains('PaymentSheetError')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment was cancelled or failed. Please try again."))
        );
      } else if (e.toString().contains('PaymentIntent')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment processing error. Please try again."))
        );
      } else if (e.toString().contains('Session expired')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Session expired. Please login again."))
        );
        // Redirect to login screen if 
        Get.offAll(() => LoginScreen());
      } else if (e.toString().contains('Payment setup error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment setup error. Please try again."))
        );
      } else if (e.toString().contains('Subscription plan error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Subscription plan error. Please contact support."))
        );
      } else if (e.toString().contains('Account error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Account error. Please try again."))
        );
      } else if (e.toString().contains('Payment processing error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment processing error. Please try again."))
        );
      } else if (e.toString().contains('Payment method update failed')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment method update failed. Please try again."))
        );
      } else if (e.toString().contains('Payment method attachment error')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment method attachment error. Please try again."))
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment Failed: ${e.toString().replaceAll('Exception: ', '')}"))
        );
      }
    }
  }

  // Billing status: whether user has default payment method and auto-debit preference
  Future<Map<String, dynamic>> getBillingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      await prefs.remove('auth_token');
      await prefs.remove('email');
      throw Exception("Session expired. Please login again.");
    }

    final response = await http.get(
      Uri.parse("${ApiConstants.resolvedApiUrl}/users/billing"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      hasDefaultPaymentMethod = (data['hasDefaultPaymentMethod'] ?? false) as bool;
      autoDebitEnabled = (data['autoDebit'] ?? false) as bool;
      return data;
    } else if (response.statusCode == 401) {
      await prefs.remove('auth_token');
      await prefs.remove('email');
      throw Exception("Session expired. Please login again.");
    }

    throw Exception('Failed to load billing status');
  }

  // Prompt user to set a default payment method via SetupIntent (no raw card data stored)
  Future<bool> ensureDefaultPaymentMethod(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      await prefs.remove('auth_token');
      await prefs.remove('email');
      throw Exception("Session expired. Please login again.");
    }

    // Request a SetupIntent client secret from backend
    final setupIntentResp = await http.post(
      Uri.parse("${ApiConstants.resolvedApiUrl}/payments/setup-intent"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (setupIntentResp.statusCode != 200) {
      return false;
    }
    final setupData = jsonDecode(setupIntentResp.body) as Map<String, dynamic>;
    final clientSecret = setupData['clientSecret'] as String?;
    if (clientSecret == null) return false;

    // Present Stripe payment sheet to collect and attach a payment method (mandate)
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        setupIntentClientSecret: clientSecret,
        merchantDisplayName: 'Elevate',
        style: ThemeMode.system,
        allowsDelayedPaymentMethods: true,
      ),
    );

    await Stripe.instance.presentPaymentSheet();

    // Backend should attach the payment method in webhook or by returning id
    // Re-check billing status
    final status = await getBillingStatus();
    return (status['hasDefaultPaymentMethod'] ?? false) as bool;
  }

  // Toggle auto-debit preference on backend
  Future<bool> setAutoDebit(bool enabled) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) {
      await prefs.remove('auth_token');
      await prefs.remove('email');
      throw Exception("Session expired. Please login again.");
    }

    final resp = await http.put(
      Uri.parse("${ApiConstants.resolvedApiUrl}/subscriptions/auto-debit"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"autoDebit": enabled}),
    );

    if (resp.statusCode == 200) {
      autoDebitEnabled = enabled;
      return true;
    } else if (resp.statusCode == 401) {
      await prefs.remove('auth_token');
      await prefs.remove('email');
      throw Exception("Session expired. Please login again.");
    }
    return false;
  }

  Future<Map<String, dynamic>?> checkSubscriptionStatus(String email) async {
    try {
      // Get auth token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        // Treat as session expired for consistent handling
        await prefs.remove('auth_token');
        await prefs.remove('email');
        throw Exception("Session expired. Please login again.");
      }

      // Call your backend API to check subscription status
      final response = await http.get(
        Uri.parse("${ApiConstants.resolvedApiUrl}/subscriptions/status"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode == 200) {
        // Success - continue with existing logic
      } else if (response.statusCode == 401) {
        // Token expired or invalid - clear it and surface explicit error
        await prefs.remove('auth_token');
        await prefs.remove('email');
        throw Exception("Session expired. Please login again.");
      } else {
        return null; // No subscription or other error
      }

      final subscriptionData = jsonDecode(response.body);
      
      if (subscriptionData['subscription'] == null) {
        return null; // No subscription found
      }

      final subscription = subscriptionData['subscription'];
      final status = subscription['status'];
      
      // Only consider 'active' and 'trialing' as valid subscription statuses
      // 'incomplete' means payment hasn't been completed yet
      final isActive = status == 'active' || status == 'trialing';
      
      // Debug: Log subscription status for troubleshooting
      print("Subscription status: $status");
      print("Is active: $isActive");
      
      // If subscription is incomplete, it means payment wasn't completed
      if (status == 'incomplete') {
        print("Warning: Subscription is incomplete - payment not completed");
      }

      DateTime? expiryDate;
      if (subscription['currentPeriodEnd'] != null) {
        expiryDate = DateTime.fromMillisecondsSinceEpoch(
            (subscription['currentPeriodEnd'] as int) * 1000);
      }

      this.isActive = isActive;
      this.expiryDate = expiryDate;
      subscriptionStatus = subscription['status'];

      return {
        "isActive": isActive,
        "expiryDate": expiryDate,
      };
    } catch (e) {
      print("Error fetching subscription: $e");
      return null;
    }
  }

  // New: Fetch full subscription status payload for UI needs
  // This is additive and does not change existing behavior. Use when you need
  // the raw response that includes status, currentPeriodEnd, etc.
  Future<Map<String, dynamic>> getSubscriptionStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        await prefs.remove('auth_token');
        await prefs.remove('email');
        throw Exception("Session expired. Please login again.");
      }

      final response = await http.get(
        Uri.parse("${ApiConstants.resolvedApiUrl}/subscriptions/status"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        // Token expired or invalid - clear it and redirect to login
        await prefs.remove('auth_token');
        await prefs.remove('email');
        throw Exception("Session expired. Please login again.");
      }

      throw Exception('Failed to load subscription status');
    } catch (e) {
      rethrow;
    }
  }

  // New: Update subscription with payment method from payment intent
  // This updates the subscription with the payment method after successful payment
  Future<bool> updateSubscriptionPaymentMethod(String paymentIntentId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        await prefs.remove('auth_token');
        await prefs.remove('email');
        throw Exception("Session expired. Please login again.");
      }

      final response = await http.post(
        Uri.parse("${ApiConstants.resolvedApiUrl}/subscriptions/update-payment-method"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "paymentIntentId": paymentIntentId
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Subscription updated with payment method: ${data['message']}");
        
        // Check if the subscription is actually active
        if (data['subscription'] != null && data['subscription']['isActive'] == true) {
          return true;
        } else {
          print("Payment method updated but subscription not active yet");
          return false;
        }
      } else if (response.statusCode == 401) {
        await prefs.remove('auth_token');
        await prefs.remove('email');
        throw Exception("Session expired. Please login again.");
      } else {
        final errorData = jsonDecode(response.body);
        print("Payment method update failed: ${errorData['message']}");
        
        // Handle specific error messages
        String errorMessage = errorData['message'] ?? "Payment method update failed";
        if (errorMessage.contains('Payment method attachment error')) {
          print("Payment method attachment error - will retry");
        } else if (errorMessage.contains('Payment intent error')) {
          print("Payment intent error - will retry");
        } else if (errorMessage.contains('Subscription update error')) {
          print("Subscription update error - will retry");
        }
        
        return false;
      }
    } catch (e) {
      print("Error updating subscription payment method: $e");
      return false;
    }
  }

  // New: Fix subscription status based on successful charge
  // This manually fixes subscription status when payment succeeded but subscription is incomplete
  Future<bool> fixSubscriptionStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        await prefs.remove('auth_token');
        await prefs.remove('email');
        throw Exception("Session expired. Please login again.");
      }

      final response = await http.post(
        Uri.parse("${ApiConstants.resolvedApiUrl}/subscriptions/fix-status"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Subscription status fixed: ${data['message']}");
        
        // Check if the subscription is actually active
        if (data['subscription'] != null && data['subscription']['isActive'] == true) {
          return true;
        } else {
          print("Subscription status fixed but not active yet");
          return false;
        }
      } else if (response.statusCode == 401) {
        await prefs.remove('auth_token');
        await prefs.remove('email');
        throw Exception("Session expired. Please login again.");
      } else {
        final errorData = jsonDecode(response.body);
        print("Subscription status fix failed: ${errorData['message']}");
        return false;
      }
    } catch (e) {
      print("Error fixing subscription status: $e");
      return false;
    }
  }

  // New: Confirm payment and activate subscription
  // This manually checks Stripe and updates the subscription status
  Future<bool> confirmPayment() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        await prefs.remove('auth_token');
        await prefs.remove('email');
        throw Exception("Session expired. Please login again.");
      }

      final response = await http.post(
        Uri.parse("${ApiConstants.resolvedApiUrl}/subscriptions/confirm"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Payment confirmed: ${data['message']}");
        
        // Check if the subscription is actually active
        if (data['subscription'] != null && data['subscription']['isActive'] == true) {
          return true;
        } else {
          print("Payment confirmed but subscription not active yet");
          return false;
        }
      } else if (response.statusCode == 401) {
        await prefs.remove('auth_token');
        await prefs.remove('email');
        throw Exception("Session expired. Please login again.");
      } else {
        final errorData = jsonDecode(response.body);
        print("Payment confirmation failed: ${errorData['message']}");
        print("Subscription status: ${errorData['status']}");
        print("Is active: ${errorData['isActive']}");
        return false;
      }
    } catch (e) {
      print("Error confirming payment: $e");
      return false;
    }
  }

  // New: Cancel subscription via backend
  // Safe additive method that calls POST /subscriptions/cancel
  Future<void> cancelSubscription() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        await prefs.remove('auth_token');
        await prefs.remove('email');
        throw Exception("Session expired. Please login again.");
      }

      final response = await http.post(
        Uri.parse("${ApiConstants.resolvedApiUrl}/subscriptions/cancel"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        return; // Success
      } else if (response.statusCode == 401) {
        // Token expired or invalid - clear it
        await prefs.remove('auth_token');
        await prefs.remove('email');
        throw Exception("Session expired. Please login again.");
      }

      throw Exception('Failed to cancel subscription');
    } catch (e) {
      rethrow;
    }
  }
}
