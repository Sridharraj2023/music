import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'package:elevate/Controller/Subscription_Controller.dart';
import 'package:elevate/utlis/clear_false_payment_data.dart';
import 'package:elevate/utlis/subscription_flow_debug.dart';
import 'Payment_Method_Setup_Screen.dart';

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
  bool _autoDebit = false;
  bool _hasDefaultPaymentMethod = false;
  Map<String, dynamic>? _subscriptionStatus;
  bool _isSubscriptionActive = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }
  
  Future<void> _initializeData() async {
    // Clear any false payment data first
    await ClearFalsePaymentData.clearFalsePaymentData();
    
    // Then load the actual data
    _loadPaymentDate();
    _startCountdown();
    _loadBillingStatus();
    _loadSubscriptionStatus();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  Future<void> _loadBillingStatus() async {
    try {
      final status = await _subscriptionController.getBillingStatus();
      setState(() {
        _hasDefaultPaymentMethod = status['hasDefaultPaymentMethod'] ?? false;
        _autoDebit = status['autoDebit'] ?? false;
      });
    } catch (e) {
      // Silent fail to avoid blocking screen; can toast if needed
    }
  }

  Future<void> _loadSubscriptionStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userEmail = prefs.getString('email');
      
      print('Loading subscription status for email: $userEmail');
      
      if (userEmail != null) {
        // First try the enhanced checkSubscriptionStatus method
        final status = await _subscriptionController.checkSubscriptionStatus(userEmail);
        print('Enhanced status check result: $status');
        
        // If that doesn't work, try the getSubscriptionStatus method
        if (status == null || status['isActive'] != true) {
          print('Enhanced check failed, trying getSubscriptionStatus...');
          try {
            final fullStatus = await _subscriptionController.getSubscriptionStatus();
            print('Full subscription status: $fullStatus');
            
            if (fullStatus['subscription'] != null) {
              final subscription = fullStatus['subscription'];
              final isActive = subscription['isActive'] ?? false;
              print('Subscription isActive from backend: $isActive');
              
              setState(() {
                _subscriptionStatus = {'isActive': isActive};
                _isSubscriptionActive = isActive;
              });
              return;
            }
          } catch (e) {
            print('Error with getSubscriptionStatus: $e');
          }
        }
        
        setState(() {
          _subscriptionStatus = status;
          _isSubscriptionActive = status?['isActive'] ?? false;
        });
        
        print('Final subscription status: $_subscriptionStatus');
        print('Final isActive: $_isSubscriptionActive');
      }
    } catch (e) {
      print('Error loading subscription status: $e');
    }
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
        // If no payment date found, don't set any payment date
        // This means user hasn't made a payment yet
        paymentDate = null;
        expiryDate = null;
        remainingDays = 0;
        setState(() {});
      }
    } catch (e) {
      print('Error loading payment date: $e');
      // If error, don't set false payment date
      paymentDate = null;
      expiryDate = null;
      remainingDays = 0;
      setState(() {});
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
      // Reload subscription status
      await _loadSubscriptionStatus();
      
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

  Future<void> _fixSubscriptionStatus() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Try to fix the subscription status
      final result = await _subscriptionController.fixSubscriptionStatus();
      print('Fix subscription status result: $result');
      
      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Subscription status fixed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Reload the subscription status
        await _loadSubscriptionStatus();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to fix subscription status. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fixing subscription status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _clearFalsePaymentData() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Clear false payment data
      await ClearFalsePaymentData.forceClearPaymentData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('False payment data cleared successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Reload the payment date and subscription status
      await _loadPaymentDate();
      await _loadSubscriptionStatus();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error clearing false payment data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _debugSubscriptionFlow() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Debug the subscription flow
      await SubscriptionFlowDebug.debugSubscriptionStatus();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Check console for subscription flow debug info'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error debugging subscription flow: $e'),
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
          child: SingleChildScrollView(
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
                      Text(
                        _isSubscriptionActive ? 'Status: ACTIVE' : 'Status: ${_getStatusText()}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _isSubscriptionActive ? Colors.green : Colors.orange,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getStatusMessage(),
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
                            ? '${paymentDate!.day.toString().padLeft(2, '0')}/${paymentDate!.month.toString().padLeft(2, '0')}/${paymentDate!.year}'
                            : 'No payment made',
                        Icons.payment,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      // Expiry Date
                      _buildInfoRow(
                        'Expiry Date',
                        expiryDate != null 
                            ? '${expiryDate!.day.toString().padLeft(2, '0')}/${expiryDate!.month.toString().padLeft(2, '0')}/${expiryDate!.year}'
                            : 'No subscription',
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
                
                // Auto-debit Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
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
                              Icons.autorenew,
                              color: Color(0xFF6F41F3),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Auto-debit',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                          const Spacer(),
                          Switch(
                            value: _autoDebit,
                            onChanged: (value) async {
                              if (value) {
                                // Enabling: require default payment method
                                if (!_hasDefaultPaymentMethod) {
                                  // Navigate to dedicated payment method setup screen
                                  final result = await Navigator.push<bool>(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const PaymentMethodSetupScreen(),
                                    ),
                                  );
                                  
                                  if (result == true) {
                                    // Payment method setup successful, refresh billing status
                                    await _loadBillingStatus();
                                    // Show consent dialog for auto-debit
                                    final consent = await _showConsentDialog();
                                    if (!consent) return;
                                  } else {
                                    // User cancelled setup
                                    return;
                                  }
                                } else {
                                  final consent = await _showConsentDialog();
                                  if (!consent) return;
                                }
                              }

                              final saved = await _subscriptionController.setAutoDebit(value);
                              if (saved) {
                                setState(() {
                                  _autoDebit = value;
                                  _hasDefaultPaymentMethod = true; // by this point, ensured
                                });
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(value
                                          ? 'Auto-debit enabled. You can turn this off anytime.'
                                          : 'Auto-debit disabled.'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              } else {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to update auto-debit. Please try again.'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            activeColor: const Color(0xFF6F41F3),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _hasDefaultPaymentMethod
                            ? 'Default payment method is set.'
                            : 'No default payment method set. Required to enable auto-debit.',
                        style: TextStyle(
                          fontSize: 12,
                          color: _hasDefaultPaymentMethod ? Colors.green[700] : Colors.red[700],
                        ),
                      ),
                      if (_hasDefaultPaymentMethod) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () async {
                              final result = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const PaymentMethodSetupScreen(),
                                ),
                              );
                              if (result == true) {
                                await _loadBillingStatus();
                              }
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF6F41F3),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                            ),
                            child: const Text(
                              'Manage Payment Method',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Action Buttons
                if (!_isSubscriptionActive) ...[
                  // Show fix status button only if subscription is not active
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _fixSubscriptionStatus,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
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
                          : const Text('Fix Subscription Status'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Clear False Payment Data Button (for debugging)
                if (paymentDate != null && !_isSubscriptionActive) ...[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _clearFalsePaymentData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
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
                          : const Text('Clear False Payment Data'),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                
                // Debug Subscription Flow Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _debugSubscriptionFlow,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
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
                        : const Text('Debug Subscription Flow'),
                  ),
                ),
                const SizedBox(height: 12),
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


  Future<bool> _showConsentDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Enable Auto-debit?'),
            content: const Text(
              'I authorize Elevate to automatically charge my saved payment method for each renewal. '
              'You can turn this off anytime in Subscription settings.'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Agree & Continue'),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _getStatusText() {
    if (_subscriptionStatus == null) return 'UNKNOWN';
    return _subscriptionStatus!['isActive'] == true ? 'ACTIVE' : 'INCOMPLETE';
  }

  String _getStatusMessage() {
    if (_isSubscriptionActive) {
      // Check if this is due to recent payment override
      if (paymentDate != null) {
        try {
          DateTime now = DateTime.now();
          int daysSincePayment = now.difference(paymentDate!).inDays;
          
          if (daysSincePayment < 7) {
            return 'Your subscription is active. Payment confirmed and service restored.';
          }
        } catch (e) {
          // Fall through to default message
        }
      }
      
      return 'Your subscription is active and working properly.';
    } else {
      // Check if user has made a payment or not
      if (paymentDate == null) {
        return 'No payment made yet. Please subscribe to access the app.';
      } else {
        return 'Payment received. Finalizing activation...';
      }
    }
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
