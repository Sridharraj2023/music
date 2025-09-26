// views/screens/subscription_tiers_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
          child: Container(
            height: MediaQuery.of(context).size.height,
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
                            await _subscriptionController.createSubscription(context, tiers[0].priceId);
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
                  const Spacer(),
                  const Center(
                    child: Text(
                      '@ Elevate Audioworks LLC',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 60), // Increased padding to clear bottom navigation
                ],
              ),
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
              ),
            )),
            if (i + 1 < tiers.length) const SizedBox(width: 16),
            if (i + 1 < tiers.length)
              Expanded(
                  child: GestureDetector(
                      onTap: () {
                        _onTapTier(tiers[i + 1], context);
                      },
                      child: SubscriptionTierCard(tier: tiers[i + 1]))),
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
        await _subscriptionController.createSubscription(context, tier.priceId);
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
