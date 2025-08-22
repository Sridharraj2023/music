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
          priceId: "price_1RBxGh4QLgkRN4K3NjMCXJ1A"),
       ];
  }

  Future<void> createSubscription(
      BuildContext context, String pricePlan) async {
    try {
      // Firebase User
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? email = prefs.getString('email');

      String secretKey = ApiConstants.secretKey;
      String priceId = pricePlan;

      final customerResponse = await http.post(
        Uri.parse("https://api.stripe.com/v1/customers"),
        headers: {
          "Authorization": "Bearer $secretKey",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: {
          "email": email!,
        },
      );
      final customerData = jsonDecode(customerResponse.body);
      if (customerResponse.statusCode != 200) {
        throw Exception("Customer creation failed");
      }

      // 2️⃣ Create a Subscription
      final subscriptionResponse = await http.post(
        Uri.parse("https://api.stripe.com/v1/subscriptions"),
        headers: {
          "Authorization": "Bearer $secretKey",
          "Content-Type": "application/x-www-form-urlencoded"
        },
        body: {
          "customer": customerData["id"],
          "items[0][price]": priceId,
          "payment_behavior": "default_incomplete",
          "expand[]": "latest_invoice.payment_intent",
        },
      );
      final subscriptionData = jsonDecode(subscriptionResponse.body);
      if (subscriptionResponse.statusCode != 200) {
        throw Exception("Subscription failed");
      }

      // Handle mobile platforms
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: subscriptionData["latest_invoice"]
              ["payment_intent"]["client_secret"],
          merchantDisplayName: 'Elevate',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Subscription Successful")));
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => const HomePage(),
      //   ),
      // );
      Get.off(() => const HomePage());
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Payment Failed")));
    }
  }

  Future<Map<String, dynamic>?> checkSubscriptionStatus(String email) async {
    try {
      // 2️⃣ Stripe Secret Key
      String secretKey = ApiConstants.secretKey;

      // 3️⃣ Fetch Customer from Stripe using email
      final customerResponse = await http.get(
        Uri.parse("https://api.stripe.com/v1/customers?email=$email"),
        headers: {
          "Authorization": "Bearer $secretKey",
          "Content-Type": "application/x-www-form-urlencoded"
        },
      );

      final customerData = jsonDecode(customerResponse.body);
      if (customerResponse.statusCode != 200 || customerData['data'].isEmpty) {
        return null; // User has no Stripe customer record
      }

      String customerId = customerData['data'][0]['id'];

      // 4️⃣ Fetch Subscriptions for Customer
      final subscriptionResponse = await http.get(
        Uri.parse(
            "https://api.stripe.com/v1/subscriptions?customer=$customerId"),
        headers: {
          "Authorization": "Bearer $secretKey",
          "Content-Type": "application/x-www-form-urlencoded"
        },
      );

      final subscriptionData = jsonDecode(subscriptionResponse.body);
      if (subscriptionResponse.statusCode != 200 ||
          subscriptionData['data'].isEmpty) {
        return null; // No active subscription found
      }

      final subscription = subscriptionData['data'][0];
      final isActive = subscription['status'] == 'active' ||
          subscription['status'] == 'trialing';

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(
          (subscription['current_period_end'] as int) * 1000);
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
