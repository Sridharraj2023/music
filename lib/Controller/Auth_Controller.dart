import 'dart:convert';
import 'dart:developer';
import 'package:elevate/Controller/Subscription_Controller.dart';
import 'package:elevate/Model/user.dart';
import 'package:elevate/View/Screens/Homepage_Screen.dart';
import 'package:elevate/View/Screens/Login_Screen.dart';
import 'package:elevate/View/Screens/SubscriptionTier_Screen.dart';
import 'package:elevate/utlis/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthController {
  Future<void> signUp(User user, BuildContext context) async {
    String baseUrl = "${ApiConstants.resolvedApiUrl}/users/";
    var headers = {'Content-Type': 'application/json'};

    log(user.password);
    log(user.email);

    var request = http.Request('POST', Uri.parse(baseUrl));
    request.body = json.encode({
      "name": user.username,
      "email": user.email,
      "password": user.password,
      "role": "user"
    });
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    log(response.statusCode.toString());

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Account created successfully! Please log in."),
          backgroundColor: Colors.green,
        ),
      );
      print(await response.stream.bytesToString());
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SubscriptionTiersScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Signup failed. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
      print(response.reasonPhrase);
    }
  }

  Future<void> login(
      String email, String password, BuildContext context) async {
    log("Email $email");
    log("Password $password");
    String baseUrl =
        "${ApiConstants.resolvedApiUrl}/users/auth"; // Adjust based on API route
    var headers = {'Content-Type': 'application/json'};

    try {
      var response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode({"email": email, "password": password}),
      );
      log(response.statusCode.toString());

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        log(responseData.toString());
        String token =
            responseData["token"]; // Assuming the API returns a JWT token
        String name = responseData["name"];
        String email = responseData["email"];
        String id = responseData["_id"];

        // Save token to local storage for future authenticated requests
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('name', name);
        await prefs.setString('email', email);
        await prefs.setString('id', id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Login Successfully "),
              backgroundColor: Colors.green),
        );
        // // Navigate to next screen
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => SubscriptionTiersScreen()),
        // );
        final SubscriptionController _subscriptionController =
            SubscriptionController();
        final status =
            await _subscriptionController.checkSubscriptionStatus(email);
        
        // Check if user has made a recent payment as a fallback
        String? paymentDateStr = prefs.getString('payment_date');
        bool hasRecentPayment = false;
        
        if (paymentDateStr != null) {
          try {
            DateTime paymentDate = DateTime.parse(paymentDateStr);
            DateTime now = DateTime.now();
            hasRecentPayment = now.difference(paymentDate).inDays < 7;
            print("Login check - Payment date: $paymentDateStr, Has recent payment: $hasRecentPayment");
          } catch (e) {
            print("Error parsing payment date during login: $e");
          }
        }
        
        // For new users, we need to be more strict about subscription access
        bool shouldAllowAccess = false;
        
        if (status != null && status['isActive'] == true) {
          // User has active subscription
          shouldAllowAccess = true;
          print("User has active subscription - allowing access");
        } else if (hasRecentPayment) {
          // User has made a recent payment (within 7 days)
          shouldAllowAccess = true;
          print("User has recent payment - allowing access");
        } else {
          // No active subscription and no recent payment
          shouldAllowAccess = false;
          print("No active subscription and no recent payment - redirecting to subscription page");
        }
        
        if (shouldAllowAccess) {
          Get.off(() => const HomePage());
        } else {
          Get.off(() => SubscriptionTiersScreen());
        }
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Invalid email or password"),
              backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print("Login error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("$e"), backgroundColor: Colors.red),
      );
    }
  }
}
