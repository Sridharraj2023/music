// views/widgets/subscription_tier_card.dart
import 'package:flutter/material.dart';

import '../../Model/Subscription_Tiers.dart';
import 'Feature_Row.dart';

class SubscriptionTierCard extends StatelessWidget {
  final SubscriptionTier tier;
  final bool isAdmin;
  final String selectedBillingPeriod;

  const SubscriptionTierCard({
    required this.tier, 
    this.isAdmin = false, 
    this.selectedBillingPeriod = 'monthly',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              tier.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            FeatureRow(
              label: 'Monthly Cost: ', 
              value: tier.monthlyCost,
              isEmphasized: selectedBillingPeriod == 'monthly',
            ),
            FeatureRow(
              label: 'Annual Cost: ', 
              value: tier.annualCost,
              isEmphasized: selectedBillingPeriod == 'yearly',
            ),
            FeatureRow(label: 'Ad Supported:', value: tier.adSupported),
            FeatureRow(label: 'Audio File Type:', value: tier.audioFileType),
            FeatureRow(
                label: 'Offline Downloads:', value: tier.offlineDownloads),
            FeatureRow(label: 'Binaural Tracks:', value: tier.binauralTracks),
            FeatureRow(
                label: 'Soundscape Tracks:', value: tier.soundscapeTracks),
            if (isAdmin)
              FeatureRow(
                  label: 'Dynamic Audio Features:',
                  value: tier.dynamicAudioFeatures),
            FeatureRow(
                label: 'Custom Track Requests:',
                value: tier.customTrackRequests),
          ],
        ),
      ),
    );
  }
}
