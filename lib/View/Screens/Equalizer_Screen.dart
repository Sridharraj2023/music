import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../Controller/Equalizer_Controller.dart';
import '../widgets/gradient_container.dart';

class EqualizerScreen extends StatelessWidget {
  const EqualizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller with proper error handling
    EqualizerController controller;
    try {
      controller = Get.find<EqualizerController>();
    } catch (e) {
      controller = Get.put(EqualizerController());
    }
    
    // Ensure controller is properly initialized
    if (controller == null) {
      controller = Get.put(EqualizerController());
    }
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      body: GradientContainer(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
          child: Column(
            children: [
                    // Top spacing
                    SizedBox(height: screenHeight * 0.02),
                  // Header Section - Centered like music player
                  Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                      // Back button
                    Container(
                        width: 48,
                        height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
                        onPressed: () {
                            HapticFeedback.lightImpact();
                          Get.back();
                        },
                      ),
                    ),
                      
                      // Centered Title
                    Column(
                        mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                            'EQUALIZER',
                          style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Obx(() => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: controller.isEqualizerEnabled.value 
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: controller.isEqualizerEnabled.value 
                                    ? Colors.green.withOpacity(0.5)
                                    : Colors.grey.withOpacity(0.5),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  controller.isEqualizerEnabled.value 
                                      ? Icons.check_circle 
                                      : Icons.pause_circle,
                                  color: controller.isEqualizerEnabled.value 
                                      ? Colors.green 
                                      : Colors.grey,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                          controller.isEqualizerEnabled.value 
                              ? 'Active' 
                              : 'Disabled',
                          style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                            color: controller.isEqualizerEnabled.value 
                                        ? Colors.green 
                                        : Colors.grey,
                                  ),
                                ),
                              ],
                          ),
                        )),
                      ],
                    ),
                      
                      // Toggle button
                    Container(
                        width: 48,
                        height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Obx(() => IconButton(
                        icon: Icon(
                          controller.isEqualizerEnabled.value 
                              ? Icons.graphic_eq 
                              : Icons.graphic_eq_outlined,
                            color: controller.isEqualizerEnabled.valueS 
                              ? Colors.green 
                              : Colors.white,
                            size: 20,
                        ),
                        onPressed: () {
                            HapticFeedback.mediumImpact();
                          controller.toggleEqualizer();
                            _showStatusFeedback(context, controller);
                          },
                        )),
                      ),
                    ],
                  ),

                  SizedBox(height: screenHeight * 0.03),
                  
                  // Presets Section
                  _buildPresetsSection(controller, screenWidth, isSmallScreen),
                  
                  SizedBox(height: screenHeight * 0.03),

                  // Equalizer Section
                  _buildEqualizerSection(controller, screenWidth, screenHeight, isSmallScreen),
                  
                  SizedBox(height: screenHeight * 0.03),
                  
                  // Reset Button
                  _buildResetButton(controller, screenWidth),
                  
                  // Bottom spacing
                  SizedBox(height: screenHeight * 0.05),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }


  // Helper method to show status feedback
  void _showStatusFeedback(BuildContext context, EqualizerController controller) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                controller.isEqualizerEnabled.value 
                                    ? 'Equalizer Enabled' 
                                    : 'Equalizer Disabled',
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: controller.isEqualizerEnabled.value 
                                  ? Colors.green 
                                  : Colors.grey,
        duration: const Duration(milliseconds: 1200),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // Helper method to build presets section
  Widget _buildPresetsSection(EqualizerController controller, double screenWidth, bool isSmallScreen) {
    return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
                  color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.tune,
                          color: Colors.white.withOpacity(0.8),
                size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sound Presets',
                          style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                          'Tap to apply',
                          style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.7),
                  ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(() => Wrap(
            spacing: 8,
            runSpacing: 8,
                      children: controller.getAvailablePresets().map((preset) {
                        final isSelected = controller.currentPreset.value == preset;
                        return GestureDetector(
                          onTap: () {
                  HapticFeedback.lightImpact();
                            controller.applyPreset(preset);
                  _showPresetFeedback(Get.context!, preset);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                    gradient: isSelected 
                        ? LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.25),
                              Colors.white.withOpacity(0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                              color: isSelected 
                          ? Colors.white.withOpacity(0.4) 
                          : Colors.white.withOpacity(0.1),
                      width: isSelected ? 1.5 : 1,
                    ),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ] : null,
                            ),
                            child: Text(
                              preset,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                      fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )),
                  ],
                ),
    );
  }

  // Helper method to build main equalizer section
  Widget _buildEqualizerSection(
    EqualizerController controller, 
    double screenWidth, 
    double screenHeight, 
    bool isSmallScreen
  ) {
    return Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
                    color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.equalizer,
                            color: Colors.white.withOpacity(0.8),
                size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Frequency Bands',
                            style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                            'Drag to adjust',
                            style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.7),
                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
          
          // Equalizer Bands - Ultra-compact to fit within screen
          SizedBox(
            height: isSmallScreen ? 150 : 170,
            child: Obx(() => _buildEqualizerBands(controller, screenWidth, isSmallScreen)),
          ),
        ],
      ),
    );
  }

  // Ultra-compact equalizer bands method
  Widget _buildCompactEqualizerBands(EqualizerController controller, double screenWidth, bool isSmallScreen) {
    final availableWidth = screenWidth - 120; // Much more padding to prevent overflow
    final bandWidth = availableWidth / EqualizerController.frequencyBands.length;
    final sliderWidth = bandWidth.clamp(18.0, 24.0); // Much smaller width
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        EqualizerController.frequencyBands.length,
        (index) => _buildUltraCompactBand(
          controller,
          index,
          sliderWidth,
          isSmallScreen,
        ),
      ),
    );
  }

  // Scrollable equalizer bands method to prevent horizontal overflow
  Widget _buildScrollableEqualizerBands(EqualizerController controller, double screenWidth, bool isSmallScreen) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(
            EqualizerController.frequencyBands.length,
            (index) => Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? 0 : 6,
                right: index == EqualizerController.frequencyBands.length - 1 ? 0 : 6,
              ),
              child: _buildCompactFrequencyBand(
                controller,
                index,
                28.0, // Smaller width to fit properly
                isSmallScreen,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build equalizer bands that fit within screen width
  Widget _buildEqualizerBands(EqualizerController controller, double screenWidth, bool isSmallScreen) {
    final availableWidth = screenWidth - 120; // Much more padding to prevent overflow
    final bandWidth = availableWidth / EqualizerController.frequencyBands.length;
    final sliderWidth = bandWidth.clamp(15.0, 20.0); // Much smaller width to fit all bands
    
    return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(
                            EqualizerController.frequencyBands.length,
        (index) => _buildCompactFrequencyBand(
                              controller,
                              index,
          sliderWidth,
          isSmallScreen,
        ),
      ),
    );
  }

  // Ultra-compact frequency band widget with fixed height
  Widget _buildUltraCompactBand(
    EqualizerController controller,
    int index,
    double width,
    bool isSmallScreen,
  ) {
    final gain = controller.getBandGain(index);
    final maxHeight = isSmallScreen ? 70.0 : 80.0;
    
    return SizedBox(
      height: maxHeight,
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gain value display - minimal
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              '${gain.toStringAsFixed(0)}dB',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 6 : 7,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Fixed height slider - no Expanded widget
          SizedBox(
            height: maxHeight * 0.7, // Use 70% of available height for slider
            width: width,
            child: RotatedBox(
              quarterTurns: -1,
              child: SliderTheme(
                data: SliderTheme.of(Get.context!).copyWith(
                  activeTrackColor: _getBandColor(gain),
                  inactiveTrackColor: Colors.white.withOpacity(0.15),
                  thumbColor: _getBandColor(gain),
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: isSmallScreen ? 2 : 3),
                  trackHeight: isSmallScreen ? 1 : 1.5,
                  overlayShape: RoundSliderOverlayShape(overlayRadius: isSmallScreen ? 4 : 6),
                  overlayColor: _getBandColor(gain).withOpacity(0.2),
                  trackShape: const RoundedRectSliderTrackShape(),
                ),
                child: Slider(
                  value: gain,
                  min: -12.0,
                  max: 12.0,
                  divisions: 48,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    controller.setBandGain(index, value);
                  },
                ),
              ),
            ),
          ),
          
          // Frequency label - minimal
          Text(
            controller.getFrequencyLabel(index),
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isSmallScreen ? 7 : 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Ultra-compact frequency band widget that fits within screen
  Widget _buildCompactFrequencyBand(
    EqualizerController controller,
    int index,
    double width,
    bool isSmallScreen,
  ) {
    final gain = controller.getBandGain(index);
    final maxHeight = isSmallScreen ? 140.0 : 160.0;
    
    return SizedBox(
      height: maxHeight,
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ultra-compact gain value display
          Container(
            width: width - 1, // Ensure it fits within the container
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              '${gain.toStringAsFixed(0)}dB',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 6 : 7,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          
          // Slider with fixed height
          SizedBox(
            height: maxHeight * 0.75, // Use 75% of height for slider
            width: width,
            child: RotatedBox(
              quarterTurns: -1,
              child: SliderTheme(
                data: SliderTheme.of(Get.context!).copyWith(
                  activeTrackColor: _getBandColor(gain),
                  inactiveTrackColor: Colors.white.withOpacity(0.15),
                  thumbColor: _getBandColor(gain),
                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: isSmallScreen ? 2 : 3),
                  trackHeight: isSmallScreen ? 1.5 : 2,
                  overlayShape: RoundSliderOverlayShape(overlayRadius: isSmallScreen ? 4 : 6),
                  overlayColor: _getBandColor(gain).withOpacity(0.2),
                  trackShape: const RoundedRectSliderTrackShape(),
                ),
                child: Slider(
                  value: gain,
                  min: -12.0,
                  max: 12.0,
                  divisions: 48,
                  onChanged: (value) {
                    HapticFeedback.selectionClick();
                    controller.setBandGain(index, value);
                  },
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 2),
          
          // Ultra-compact frequency label
          Container(
            width: width - 1, // Ensure it fits within the container
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Text(
              controller.getFrequencyLabel(index),
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: isSmallScreen ? 6 : 7,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Improved frequency band widget with normal sizing for scrollable layout
  Widget _buildFrequencyBand(
    EqualizerController controller,
    int index,
    double width,
    bool isSmallScreen,
  ) {
    final gain = controller.getBandGain(index);
    final maxHeight = isSmallScreen ? 180.0 : 200.0;
    
    return SizedBox(
      height: maxHeight,
      width: width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Gain value display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getBandColor(gain).withOpacity(0.4),
                width: 1,
              ),
            ),
            child: Text(
              '${gain.toStringAsFixed(1)}dB',
              style: TextStyle(
                color: Colors.white,
                fontSize: isSmallScreen ? 9 : 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Slider with flexible height
          Expanded(
            child: SizedBox(
              width: width,
              child: RotatedBox(
                quarterTurns: -1,
                child: SliderTheme(
                  data: SliderTheme.of(Get.context!).copyWith(
                    activeTrackColor: _getBandColor(gain),
                    inactiveTrackColor: Colors.white.withOpacity(0.15),
                    thumbColor: _getBandColor(gain),
                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: isSmallScreen ? 6 : 8),
                    trackHeight: isSmallScreen ? 4 : 6,
                    overlayShape: RoundSliderOverlayShape(overlayRadius: isSmallScreen ? 12 : 16),
                    overlayColor: _getBandColor(gain).withOpacity(0.2),
                    trackShape: const RoundedRectSliderTrackShape(),
                  ),
                  child: Slider(
                    value: gain,
                    min: -12.0,
                    max: 12.0,
                    divisions: 48,
                    onChanged: (value) {
                      HapticFeedback.selectionClick();
                      controller.setBandGain(index, value);
                    },
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Frequency label
                      Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              controller.getFrequencyLabel(index),
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: isSmallScreen ? 10 : 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to build reset button
  Widget _buildResetButton(EqualizerController controller, double screenWidth) {
    return Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withOpacity(0.15),
            Colors.white.withOpacity(0.08),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
        borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
          borderRadius: BorderRadius.circular(16),
                            onTap: () {
            HapticFeedback.mediumImpact();
                              controller.resetToFlat();
            _showResetFeedback(Get.context!);
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.refresh,
                                    color: Colors.white.withOpacity(0.8),
                  size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Reset to Flat',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
          ),
        ),
      ),
    );
  }

  // Helper methods for feedback
  void _showPresetFeedback(BuildContext context, String preset) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
          'Applied $preset preset',
                          style: const TextStyle(color: Colors.white),
                        ),
        backgroundColor: Colors.blue.withOpacity(0.8),
        duration: const Duration(milliseconds: 800),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
                        ),
        margin: const EdgeInsets.all(16),
                      ),
                    );
                  }

  void _showResetFeedback(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Reset to Flat Response',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange.withOpacity(0.8),
        duration: const Duration(milliseconds: 1000),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Color _getBandColor(double gain) {
    if (gain > 0) {
      // Positive gain - green to yellow
      return Color.lerp(Colors.green, Colors.yellow, gain / 12.0) ?? Colors.green;
    } else if (gain < 0) {
      // Negative gain - blue to purple
      return Color.lerp(Colors.blue, Colors.purple, gain.abs() / 12.0) ?? Colors.blue;
    } else {
      // Flat - white
      return Colors.white;
    }
  }
}

