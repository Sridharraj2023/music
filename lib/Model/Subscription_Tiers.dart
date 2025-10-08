// models/subscription_tier.dart
class SubscriptionTier {
  final String title;
  final String monthlyCost;
  final String annualCost;
  final String adSupported;
  final String audioFileType;
  final String offlineDownloads;
  final String binauralTracks;
  final String soundscapeTracks;
  final String dynamicAudioFeatures;
  final String customTrackRequests;
  final String priceId; // Keep for backward compatibility
  final String monthlyPriceId;
  final String yearlyPriceId;

  SubscriptionTier({
    required this.title,
    required this.monthlyCost,
    required this.annualCost,
    required this.adSupported,
    required this.audioFileType,
    required this.offlineDownloads,
    required this.binauralTracks,
    required this.soundscapeTracks,
    required this.dynamicAudioFeatures,
    required this.customTrackRequests,
    required this.priceId,
    required this.monthlyPriceId,
    required this.yearlyPriceId,
  });
}
