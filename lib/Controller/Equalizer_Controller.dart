import 'package:get/get.dart';
import 'BottomBar_Controller.dart';

class EqualizerController extends GetxController {
  // Frequency bands (Hz)
  static const List<double> frequencyBands = [
    60,    // Sub-bass
    170,   // Bass
    310,   // Low-mid
    600,   // Mid
    1000,  // High-mid
    3000,  // Presence
    6000,  // Brilliance
    12000, // Air
    14000, // Ultra-high
    16000  // Super-high
  ];

  // Current equalizer settings (gain values from -12 to +12 dB)
  var equalizerGains = <double>[0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0].obs;
  
  // Current preset
  var currentPreset = 'Custom'.obs;
  
  // Equalizer enabled/disabled
  var isEqualizerEnabled = false.obs;

  // Preset definitions
  static const Map<String, List<double>> presets = {
    'Flat': [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0],
    'Pop': [2.0, 1.5, 0.5, -0.5, 0.0, 1.0, 2.0, 1.5, 1.0, 0.5],
    'Rock': [2.5, 1.0, -1.0, -0.5, 0.5, 1.5, 2.5, 2.0, 1.5, 1.0],
    'Jazz': [1.0, 1.5, 2.0, 1.5, 1.0, 0.5, 0.0, -0.5, -1.0, -1.5],
    'Classical': [0.5, 1.0, 1.5, 2.0, 1.5, 1.0, 0.5, 0.0, -0.5, -1.0],
    'Electronic': [3.0, 2.5, 1.0, 0.0, 1.0, 2.0, 3.0, 2.5, 2.0, 1.5],
    'Hip-Hop': [3.5, 3.0, 1.5, 0.5, 0.0, 0.5, 1.0, 1.5, 1.0, 0.5],
    'Country': [1.5, 2.0, 1.0, 0.5, 0.0, 0.5, 1.0, 1.5, 1.0, 0.5],
    'Blues': [1.0, 1.5, 2.0, 1.5, 1.0, 0.5, 0.0, 0.0, -0.5, -1.0],
    'Folk': [0.5, 1.0, 1.5, 2.0, 1.5, 1.0, 0.5, 0.0, -0.5, -1.0],
    'Reggae': [2.0, 2.5, 1.0, 0.0, 0.5, 1.0, 1.5, 1.0, 0.5, 0.0],
    'Metal': [2.0, 0.5, -1.0, -0.5, 1.0, 2.0, 3.0, 2.5, 2.0, 1.5],
  };

  @override
  void onInit() {
    super.onInit();
    // Initialize with flat preset
    applyPreset('Flat');
  }

  /// Apply a preset to the equalizer
  void applyPreset(String presetName) {
    if (presets.containsKey(presetName)) {
      equalizerGains.value = List.from(presets[presetName]!);
      currentPreset.value = presetName;
      _applyEqualizerToPlayer();
    }
  }

  /// Set gain for a specific frequency band
  void setBandGain(int bandIndex, double gain) {
    if (bandIndex >= 0 && bandIndex < equalizerGains.length) {
      equalizerGains[bandIndex] = gain.clamp(-12.0, 12.0);
      currentPreset.value = 'Custom';
      _applyEqualizerToPlayer();
    }
  }

  /// Reset all bands to flat (0 dB)
  void resetToFlat() {
    applyPreset('Flat');
  }

  /// Toggle equalizer on/off
  void toggleEqualizer() {
    isEqualizerEnabled.value = !isEqualizerEnabled.value;
    _applyEqualizerToPlayer();
  }

  /// Enable equalizer
  void enableEqualizer() {
    isEqualizerEnabled.value = true;
  }

  /// Disable equalizer
  void disableEqualizer() {
    isEqualizerEnabled.value = false;
  }

  /// Get current gain for a specific band
  double getBandGain(int bandIndex) {
    if (bandIndex >= 0 && bandIndex < equalizerGains.length) {
      return equalizerGains[bandIndex];
    }
    return 0.0;
  }

  /// Get frequency label for a band
  String getFrequencyLabel(int bandIndex) {
    if (bandIndex >= 0 && bandIndex < frequencyBands.length) {
      final freq = frequencyBands[bandIndex];
      if (freq >= 1000) {
        return '${(freq / 1000).toStringAsFixed(1)}k';
      }
      return freq.toStringAsFixed(0);
    }
    return '';
  }

  /// Get all available presets
  List<String> getAvailablePresets() {
    return presets.keys.toList();
  }

  /// Check if current settings match a preset
  bool isCurrentPreset(String presetName) {
    if (!presets.containsKey(presetName)) return false;
    final presetGains = presets[presetName]!;
    for (int i = 0; i < equalizerGains.length; i++) {
      if ((equalizerGains[i] - presetGains[i]).abs() > 0.1) {
        return false;
      }
    }
    return true;
  }

  /// Get equalizer settings as a map for audio processing
  Map<String, dynamic> getEqualizerSettings() {
    return {
      'enabled': isEqualizerEnabled.value,
      'gains': equalizerGains.toList(),
      'preset': currentPreset.value,
    };
  }

  /// Apply equalizer settings from a map
  void applyEqualizerSettings(Map<String, dynamic> settings) {
    if (settings.containsKey('enabled')) {
      isEqualizerEnabled.value = settings['enabled'] as bool;
    }
    if (settings.containsKey('gains')) {
      final gains = List<double>.from(settings['gains'] as List);
      if (gains.length == equalizerGains.length) {
        equalizerGains.value = gains;
      }
    }
    if (settings.containsKey('preset')) {
      currentPreset.value = settings['preset'] as String;
    }
    _applyEqualizerToPlayer();
  }

  /// Apply equalizer settings to the audio player
  void _applyEqualizerToPlayer() {
    try {
      // Try to get the BottomBarController and apply equalizer settings
      final bottomBarController = Get.find<BottomBarController>();
      bottomBarController.applyEqualizerSettings();
    } catch (e) {
      // BottomBarController not found, this is normal if no audio is playing
      // or if we're in standalone mode
      print('BottomBarController not found (standalone mode): $e');
    }
  }
}
