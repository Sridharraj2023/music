import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

/// Centralized error handler for subscription and payment flows.
class SubscriptionErrorHandler {
  static void showError(BuildContext context, dynamic error) {
    String message = 'An error occurred';

    if (error is SocketException) {
      message = 'No internet connection';
    } else if (error is TimeoutException) {
      message = 'Request timed out';
    } else if (error is http.ClientException) {
      message = 'Network error: ${error.message}';
    } else if (error is StripeException) {
      message = 'Payment error: ${error.error.localizedMessage}';
    } else if (error is FormatException) {
      message = 'Invalid server response';
    } else if (error is PlatformException) {
      message = 'Platform error: ${error.message}';
    } else if (error is Exception) {
      message = error.toString();
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    debugPrint('Subscription Error: $error');
  }
}


