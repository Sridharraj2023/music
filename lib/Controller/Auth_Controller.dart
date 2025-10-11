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
          content: Text("Account created successfully! Please subscribe to continue."),
          backgroundColor: Colors.green,
        ),
      );
      print(await response.stream.bytesToString());
      
      // Auto-login the user after successful signup
      try {
        await login(user.email, user.password, context);
      } catch (e) {
        print("Auto-login failed after signup: $e");
        // If auto-login fails, redirect to login screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
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
        
        // Show login success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Login Successful"),
              backgroundColor: Colors.green),
        );
        
        // Now check subscription status to determine where to redirect
        final SubscriptionController _subscriptionController = SubscriptionController();
        final status = await _subscriptionController.checkSubscriptionStatus(email);
        
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
        
        // Check subscription status from backend response first
        bool backendSubscriptionActive = false;
        if (responseData["subscription"] != null) {
          var subscriptionData = responseData["subscription"];
          backendSubscriptionActive = subscriptionData["isActive"] ?? false;
          log("Backend login response - subscription active: $backendSubscriptionActive");
        }
        
        // Debug logging for new users
        print("=== LOGIN DEBUG INFO ===");
        print("Backend subscription active: $backendSubscriptionActive");
        print("Frontend subscription status: $status");
        print("Has recent payment: $hasRecentPayment");
        
        // Determine if user should have access
        bool shouldAllowAccess = false;
        
        // Only allow access if user has an ACTIVE subscription (not just recent payment)
        if (backendSubscriptionActive || (status != null && status['isActive'] == true)) {
          // User has active subscription from backend or frontend check
          shouldAllowAccess = true;
          print("Login: User has active subscription - allowing access to homepage");
        } else {
          // No active subscription - MUST subscribe (including new users)
          shouldAllowAccess = false;
          print("Login: No active subscription - redirecting to subscription page");
        }
        
        // Redirect based on subscription status
        if (shouldAllowAccess) {
          Get.off(() => const HomePage());
        } else {
          // User needs to subscribe - redirect to subscription tier screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Please subscribe to access the app"),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 3),
            ),
          );
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

  // @desc    Request password reset
  // @route   POST /api/users/forgot-password
  // @access  Public
  Future<void> requestPasswordReset(String email, BuildContext context) async {
    String baseUrl = "${ApiConstants.resolvedApiUrl}/users/forgot-password";
    var headers = {'Content-Type': 'application/json'};

    try {
      log("Requesting password reset for email: $email");
      
      var response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode({"email": email}),
      );
      
      log("Password reset request status: ${response.statusCode}");

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        log(responseData.toString());

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData["message"] ?? 
              "If an account with that email exists, a password reset link has been sent."
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );

        // Navigate back to login screen after short delay
        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) {
          Navigator.pop(context);
        }
      } else {
        var errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData["message"] ?? "Failed to send reset email. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log("Password reset request error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: Unable to send reset email. Please check your connection."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // @desc    Reset password with token
  // @route   POST /api/users/reset-password/:token
  // @access  Public
  Future<void> resetPassword(String token, String newPassword, BuildContext context) async {
    String baseUrl = "${ApiConstants.resolvedApiUrl}/users/reset-password/$token";
    var headers = {'Content-Type': 'application/json'};

    try {
      log("Resetting password with token");
      
      var response = await http.post(
        Uri.parse(baseUrl),
        headers: headers,
        body: jsonEncode({"password": newPassword}),
      );
      
      log("Password reset status: ${response.statusCode}");

      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        log(responseData.toString());

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData["message"] ?? 
              "Password reset successful. You can now log in with your new password."
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );

        // Navigate to login screen after short delay
        await Future.delayed(const Duration(seconds: 2));
        if (context.mounted) {
          // Navigate to login screen using Get
          Get.off(() => LoginScreen());
        }
      } else {
        var errorData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorData["message"] ?? "Failed to reset password. The link may have expired."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      log("Password reset error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: Unable to reset password. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
