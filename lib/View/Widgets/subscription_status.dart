import 'package:elevate/Controller/Subscription_Controller.dart';
import 'package:elevate/View/Screens/Login_Screen.dart';
import 'package:elevate/View/Screens/Subscription_Details_Screen.dart';
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
        final message = e.toString();
        final isSessionExpired = message.contains('Session expired');
        if (isSessionExpired) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired. Redirecting to login...')),
          );
          Get.offAll(() => LoginScreen());
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading subscription: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final raw = subscriptionStatus?['subscription'] ?? {};
    final String status = (raw['status'] ?? 'inactive') as String;
    final bool isActive = (raw['isActive'] ?? (status == 'active' || status == 'trialing')) as bool;
    final currentPeriodEnd = raw['currentPeriodEnd'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Subscription Status: ${(isActive ? 'ACTIVE' : status.toUpperCase())}'),
        const SizedBox(height: 8),
        if (isActive) ...[
          if (currentPeriodEnd != null)
            Text('Next Billing: ${DateTime.fromMillisecondsSinceEpoch((currentPeriodEnd as int) * 1000)}'),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SubscriptionDetailsScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6F41F3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Subscription Details'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _showCancelConfirmation(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
            ],
          ),
        ] else ...[
          if (status == 'incomplete') ...[
            const Text('Payment received. Finalizing activation...'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      await _controller.fixSubscriptionStatus();
                      await _loadSubscriptionStatus();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Refresh Status'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      await _controller.confirmPayment();
                      await _loadSubscriptionStatus();
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Force Confirm'),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SubscriptionDetailsScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6F41F3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Subscription Details'),
              ),
            )
          ] else ...[
            ElevatedButton(
              onPressed: () => _startSubscription(context),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Subscribe Now'),
            ),
          ],
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


