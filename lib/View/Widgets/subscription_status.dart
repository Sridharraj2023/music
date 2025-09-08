import 'package:elevate/Controller/Subscription_Controller.dart';
import 'package:elevate/View/Screens/Login_Screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Lightweight, additive widget to display subscription status and allow
/// cancel/start actions without changing existing screens.
class SubscriptionStatus extends StatefulWidget {
  const SubscriptionStatus({super.key});

  @override
  State<SubscriptionStatus> createState() => _SubscriptionStatusState();
}

class _SubscriptionStatusState extends State<SubscriptionStatus> {
  final SubscriptionController _controller = SubscriptionController();
  Map<String, dynamic>? subscriptionStatus;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubscriptionStatus();
  }

  Future<void> _loadSubscriptionStatus() async {
    setState(() => isLoading = true);
    try {
      final status = await _controller.getSubscriptionStatus();
      setState(() {
        subscriptionStatus = status;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        // Check if it's a session expired error
        if (e.toString().contains('Session expired')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired. Redirecting to login...')),
          );
          // Redirect to login after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            Get.offAll(() => LoginScreen());
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading subscription: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final status = subscriptionStatus?['subscription']?['status'] ?? 'inactive';
    final currentPeriodEnd = subscriptionStatus?['subscription']?['currentPeriodEnd'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subscription Status: ${status.toString().toUpperCase()}'),
        const SizedBox(height: 8),
        if (status == 'active' || status == 'trialing') ...[
          if (currentPeriodEnd != null)
            Text('Next Billing: ${DateTime.fromMillisecondsSinceEpoch((currentPeriodEnd as int) * 1000)}'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => _showCancelConfirmation(context),
            child: const Text('Cancel Subscription'),
          ),
        ] else ...[
          ElevatedButton(
            onPressed: () => _startSubscription(context),
            child: const Text('Subscribe Now'),
          ),
        ],
      ],
    );
  }

  void _showCancelConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription'),
        content: const Text('Are you sure you want to cancel your subscription?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _controller.cancelSubscription();
                await _loadSubscriptionStatus();
              } catch (e) {
                if (e.toString().contains('Session expired')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Session expired. Redirecting to login...')),
                  );
                  Future.delayed(const Duration(seconds: 1), () {
                    Get.offAll(() => LoginScreen());
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error canceling subscription: $e')),
                  );
                }
              }
            },
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _startSubscription(BuildContext context) async {
    try {
      // Delegate to existing createSubscription flow using predefined priceId
      await _controller.createSubscription(context, _controller.getSubscriptionTiers().first.priceId);
      await _loadSubscriptionStatus();
    } catch (e) {
      if (e.toString().contains('Session expired')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Redirecting to login...')),
        );
        Future.delayed(const Duration(seconds: 1), () {
          Get.offAll(() => LoginScreen());
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error starting subscription: $e')),
        );
      }
    }
  }
}


