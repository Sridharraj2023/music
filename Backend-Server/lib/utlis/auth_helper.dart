import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../View/Screens/Login_Screen.dart';

/// Helper class for handling authentication-related operations
class AuthHelper {
  /// Handles session expired errors by showing a message and redirecting to login
  static void handleSessionExpired(BuildContext context, String error) {
    if (error.contains('Session expired')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session expired. Redirecting to login...')),
      );
      // Redirect to login after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        Get.offAll(() => LoginScreen());
      });
    }
  }

  /// Shows error message for non-session-expired errors
  static void showError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error)),
    );
  }
}
