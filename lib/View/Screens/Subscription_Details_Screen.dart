import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:elevate/Controller/Subscription_Controller.dart';

class SubscriptionDetailsScreen extends StatefulWidget {
  const SubscriptionDetailsScreen({super.key});

  @override
  State<SubscriptionDetailsScreen> createState() => _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends State<SubscriptionDetailsScreen> {
  DateTime? paymentDate;
  DateTime? expiryDate;
  int remainingDays = 0;
  Timer? _timer;
  final SubscriptionController _subscriptionController = SubscriptionController();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPaymentDate();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadPaymentDate() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? paymentDateString = prefs.getString('payment_date');
      
      if (paymentDateString != null) {
        paymentDate = DateTime.parse(paymentDateString);
        expiryDate = paymentDate!.add(const Duration(days: 30));
        _updateRemainingDays();
      } else {
        // If no payment date found, set current date as payment date
        paymentDate = DateTime.now();
        expiryDate = paymentDate!.add(const Duration(days: 30));
        await prefs.setString('payment_date', paymentDate!.toIso8601String());
        _updateRemainingDays();
      }
    } catch (e) {
      print('Error loading payment date: $e');
      // Fallback to current date
      paymentDate = DateTime.now();
      expiryDate = paymentDate!.add(const Duration(days: 30));
      _updateRemainingDays();
    }
  }

  void _updateRemainingDays() {
    if (expiryDate != null) {
      final now = DateTime.now();
      final difference = expiryDate!.difference(now);
      remainingDays = difference.inDays;
      
      if (remainingDays < 0) {
        remainingDays = 0;
      }
      
      setState(() {});
    }
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(hours: 1), (timer) {
      _updateRemainingDays();
    });
  }

  Future<void> _refreshSubscriptionDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Get user email from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('email');
      
      if (userEmail != null) {
        // Fetch latest subscription status from backend
        final status = await _subscriptionController.checkSubscriptionStatus(userEmail);
        
        if (status != null && status['isActive'] == true) {
          // If subscription is now active, show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription is now active!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
      
      // Reload payment date and recalculate countdown
      await _loadPaymentDate();
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error refreshing subscription: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription Details'),
        backgroundColor: const Color(0xFF6F41F3),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3A55F8), // Top blue
              Color(0xFF6F41F3), // Middle purple
              Color(0xFF8A2BE2), // Bottom violet
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6F41F3).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.subscriptions,
                              color: Color(0xFF6F41F3),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Subscription Status',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Status: INCOMPLETE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Payment received. Finalizing activation...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Validity Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.schedule,
                              color: Colors.red,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Subscription Validity',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // Remaining Days
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6F41F3).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF6F41F3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$remainingDays',
                              style: const TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6F41F3),
                              ),
                            ),
                            Text(
                              remainingDays == 1 ? 'Day Remaining' : 'Days Remaining',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6F41F3),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Payment Date
                      _buildInfoRow(
                        'Payment Date',
                        paymentDate != null 
                            ? '${paymentDate!.day}/${paymentDate!.month}/${paymentDate!.year}'
                            : 'Not available',
                        Icons.payment,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Expiry Date
                      _buildInfoRow(
                        'Expiry Date',
                        expiryDate != null 
                            ? '${expiryDate!.day}/${expiryDate!.month}/${expiryDate!.year}'
                            : 'Not available',
                        Icons.event,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Validity Period
                      _buildInfoRow(
                        'Validity Period',
                        '30 Days',
                        Icons.calendar_today,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _refreshSubscriptionDetails,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: isLoading 
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text('Refresh'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF666666),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF666666),
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
