// views/screens/subscription_tiers_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Controller/Subscription_Controller.dart';
import '../../Model/Subscription_Tiers.dart';
import '../widgets/gradient_container.dart';
import '../widgets/subscription_tier_card.dart';
import 'Homepage_Screen.dart';
import 'Login_Screen.dart';

class SubscriptionTiersScreen extends StatefulWidget {
  const SubscriptionTiersScreen({super.key});

  @override
  State<SubscriptionTiersScreen> createState() => _SubscriptionTiersScreenState();
}

class _SubscriptionTiersScreenState extends State<SubscriptionTiersScreen> {
  final SubscriptionController _subscriptionController =
      SubscriptionController();
  List<SubscriptionTier> tiers = [];
  bool isLoading = true;
  String? errorMessage;
  String selectedBillingPeriod = 'monthly'; // 'monthly' or 'yearly'

  @override
  void initState() {
    super.initState();
    _loadSubscriptionTiers();
  }

  Future<void> _loadSubscriptionTiers() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
      
      final loadedTiers = await _subscriptionController.loadSubscriptionTiers();
      
      setState(() {
        tiers = loadedTiers;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load subscription plans: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
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
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    if (errorMessage != null) {
      return Scaffold(
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
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.white,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadSubscriptionTiers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6F41F3),
                  ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
                children: [
                  const SizedBox(height: 20),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/Elevate Logo White.png',
                          height: 80, width: 80),
                      const Text(
                        "ELEVATE",
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const Text(
                        "by Frequency Tuning",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Subscription tiers",
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Billing Period Selection
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Billing Period',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedBillingPeriod = 'monthly';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: selectedBillingPeriod == 'monthly'
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Radio<String>(
                                        value: 'monthly',
                                        groupValue: selectedBillingPeriod,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedBillingPeriod = value!;
                                          });
                                        },
                                        activeColor: selectedBillingPeriod == 'monthly'
                                            ? const Color(0xFF6F41F3)
                                            : Colors.white,
                                        fillColor: MaterialStateProperty.resolveWith(
                                          (states) => selectedBillingPeriod == 'monthly'
                                              ? const Color(0xFF6F41F3)
                                              : Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Monthly',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: selectedBillingPeriod == 'monthly'
                                              ? const Color(0xFF6F41F3)
                                              : Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedBillingPeriod = 'yearly';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(
                                    color: selectedBillingPeriod == 'yearly'
                                        ? Colors.white
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Radio<String>(
                                        value: 'yearly',
                                        groupValue: selectedBillingPeriod,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedBillingPeriod = value!;
                                          });
                                        },
                                        activeColor: selectedBillingPeriod == 'yearly'
                                            ? const Color(0xFF6F41F3)
                                            : Colors.white,
                                        fillColor: MaterialStateProperty.resolveWith(
                                          (states) => selectedBillingPeriod == 'yearly'
                                              ? const Color(0xFF6F41F3)
                                              : Colors.white,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Yearly',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: selectedBillingPeriod == 'yearly'
                                                  ? const Color(0xFF6F41F3)
                                                  : Colors.white,
                                            ),
                                          ),
                                          Text(
                                            'Save 20%',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: selectedBillingPeriod == 'yearly'
                                                  ? const Color(0xFF6F41F3)
                                                  : Colors.white70,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ..._buildTierRows(tiers, context),
                  const SizedBox(height: 20),
                  // Payment Button
                  Container(
                    width: double.infinity,
                    height: 50,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (tiers.isNotEmpty) {
                          try {
                            // Use the correct price ID based on selected billing period
                            String priceId = selectedBillingPeriod == 'yearly'
                                ? tiers[0].yearlyPriceId
                                : tiers[0].monthlyPriceId;
                            
                            // Debug logging
                            print("Selected billing period: $selectedBillingPeriod");
                            print("Monthly Price ID: ${tiers[0].monthlyPriceId}");
                            print("Yearly Price ID: ${tiers[0].yearlyPriceId}");
                            print("Using Price ID: $priceId");
                            
                            await _subscriptionController.createSubscription(context, priceId);
                          } catch (e) {
                            print("Subscribe Now error: $e");
                            if (e.toString().contains('Session expired')) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Session expired. Redirecting to login...')),
                              );
                              Get.offAll(() => LoginScreen());
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF6F41F3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 5,
                      ),
                      child: const Text(
                        'Subscribe Now',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      '@ Elevate Audioworks LLC',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Add safe area padding for system navigation bar
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTierRows(
      List<SubscriptionTier> tiers, BuildContext context) {
    List<Widget> rows = [];
    for (int i = 0; i < tiers.length; i += 2) {
      rows.add(
        Row(
          children: [
            Expanded(
                child: GestureDetector(
              onTap: () {
                _onTapTier(tiers[i], context);
              },
              child: SubscriptionTierCard(
                tier: tiers[i],
                selectedBillingPeriod: selectedBillingPeriod,
              ),
            )),
            if (i + 1 < tiers.length) const SizedBox(width: 16),
            if (i + 1 < tiers.length)
              Expanded(
                  child: GestureDetector(
                      onTap: () {
                        _onTapTier(tiers[i + 1], context);
                      },
                      child: SubscriptionTierCard(
                        tier: tiers[i + 1],
                        selectedBillingPeriod: selectedBillingPeriod,
                      ))),
          ],
        ),
      );
      rows.add(const SizedBox(height: 16));
    }
    return rows;
  }

  void _onTapTier(SubscriptionTier tier, BuildContext context) async {
    // Handle the tap event for the tier
    // For example, navigate to a detailed view or show a dialog
    if (tier.title == 'Free') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const HomePage(),
        ),
      );
    } else {
      try {
        // Use the correct price ID based on selected billing period
        String priceId = selectedBillingPeriod == 'yearly'
            ? tier.yearlyPriceId
            : tier.monthlyPriceId;
        await _subscriptionController.createSubscription(context, priceId);
      } catch (e) {
        print("Tier tap error: $e");
        if (e.toString().contains('Session expired')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Session expired. Redirecting to login...')),
          );
          Get.offAll(() => LoginScreen());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')),
          );
        }
      }
    }
    print('Tapped on ${tier.title}');
  }
}
