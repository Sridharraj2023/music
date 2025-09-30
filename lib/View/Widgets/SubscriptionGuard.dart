import 'package:elevate/Controller/Subscription_Controller.dart';
import 'package:elevate/View/Screens/SubscriptionTier_Screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A widget that wraps content and checks subscription status
/// If user doesn't have valid subscription, redirects to subscription page
class SubscriptionGuard extends StatefulWidget {
  final Widget child;
  final String? customMessage;

  const SubscriptionGuard({
    super.key,
    required this.child,
    this.customMessage,
  });

  @override
  State<SubscriptionGuard> createState() => _SubscriptionGuardState();
}

class _SubscriptionGuardState extends State<SubscriptionGuard> {
  bool _isChecking = true;
  bool _hasAccess = false;

  @override
  void initState() {
    super.initState();
    _checkSubscriptionAccess();
  }

  Future<void> _checkSubscriptionAccess() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('email');
      
      if (userEmail != null) {
        final SubscriptionController _subscriptionController = SubscriptionController();
        final status = await _subscriptionController.checkSubscriptionStatus(userEmail);
        
        // Check if user has made a recent payment as a fallback
        String? paymentDateStr = prefs.getString('payment_date');
        bool hasRecentPayment = false;
        
        if (paymentDateStr != null) {
          try {
            DateTime paymentDate = DateTime.parse(paymentDateStr);
            DateTime now = DateTime.now();
            hasRecentPayment = now.difference(paymentDate).inDays < 7;
          } catch (e) {
            print("Error parsing payment date during guard check: $e");
          }
        }
        
        bool hasValidSubscription = (status != null && status['isActive'] == true) || hasRecentPayment;
        
        setState(() {
          _hasAccess = hasValidSubscription;
          _isChecking = false;
        });
        
        if (!hasValidSubscription) {
          print("SubscriptionGuard: User does not have valid subscription - redirecting");
          
          // Show a message and redirect to subscription page
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(widget.customMessage ?? 'Please subscribe to access this content'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
            
            // Redirect to subscription page after a short delay
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Get.off(() => SubscriptionTiersScreen());
              }
            });
          }
        }
      } else {
        // No user email, redirect to subscription page
        setState(() {
          _hasAccess = false;
          _isChecking = false;
        });
        
        if (mounted) {
          Get.off(() => SubscriptionTiersScreen());
        }
      }
    } catch (e) {
      print("SubscriptionGuard: Error checking subscription access: $e");
      // If there's an error, redirect to subscription page to be safe
      setState(() {
        _hasAccess = false;
        _isChecking = false;
      });
      
      if (mounted) {
        Get.off(() => SubscriptionTiersScreen());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    if (!_hasAccess) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Redirecting to subscription page...',
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }
    
    return widget.child;
  }
}
