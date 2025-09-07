// controllers/subscription_controller.dart

import 'dart:convert';

import 'package:elevate/View/Screens/Homepage_Screen.dart';
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
      String? email = prefs.getString('email');
      String? token = prefs.getString('auth_token');

      if (email == null || token == null) {
        throw Exception("User not authenticated");
      }

      // Call your backend API to create subscription
      final response = await http.post(
        Uri.parse("${ApiConstants.apiUrl}/subscriptions/create"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "priceId": pricePlan,
        }),
      );

      if (response.statusCode != 200) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? "Subscription creation failed");
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
        throw Exception("Subscription created but no payment intent was generated");
      }
      
      // Handle mobile platforms with client secret from backend
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: subscriptionData["subscription"]["clientSecret"],
          merchantDisplayName: 'Elevate',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Subscription Successful")));
      Get.off(() => const HomePage());
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Payment Failed: $e")));
    }
  }

  Future<Map<String, dynamic>?> checkSubscriptionStatus(String email) async {
    try {
      // Get auth token from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null) {
        return null; // User not authenticated
      }

      // Call your backend API to check subscription status
      final response = await http.get(
        Uri.parse("${ApiConstants.apiUrl}/subscriptions/status"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
      );

      if (response.statusCode != 200) {
        return null; // No subscription or error
      }

      final subscriptionData = jsonDecode(response.body);
      
      if (subscriptionData['subscription'] == null) {
        return null; // No subscription found
      }

      final subscription = subscriptionData['subscription'];
      final isActive = subscription['status'] == 'active' ||
          subscription['status'] == 'trialing';

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
}
