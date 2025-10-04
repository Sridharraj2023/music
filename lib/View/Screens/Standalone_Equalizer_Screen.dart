import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/Equalizer_Controller.dart';
import '../widgets/gradient_container.dart';

class StandaloneEqualizerScreen extends StatelessWidget {
  const StandaloneEqualizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Always create a new instance to avoid dependency issues
    final EqualizerController controller = Get.put(EqualizerController(), tag: 'standalone_equalizer');
    
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: GradientContainer(
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              child: Column(
                children: [
              // Enhanced Header with User Empathy
              Padding(
                padding: EdgeInsets.all(screenWidth * 0.05),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button with haptic feedback
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
                        onPressed: () {
                          // Clean up controller when leaving
                          Get.delete<EqualizerController>(tag: 'standalone_equalizer');
                          Get.back();
                        },
                      ),
                    ),
                    // Title with subtitle for clarity
                    Column(
                      children: [
                        Text(
                          'Audio Equalizer',
                          style: TextStyle(
                            fontSize: screenWidth * 0.06,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        Obx(() => Text(
                          controller.isEqualizerEnabled.value 
                              ? 'Active' 
                              : 'Disabled',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w400,
                            color: controller.isEqualizerEnabled.value 
                                ? Colors.green.withOpacity(0.8)
                                : Colors.white.withOpacity(0.6),
                          ),
                        )),
                      ],
                    ),
                    // Enhanced toggle button with visual feedback
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(25),
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
                          color: controller.isEqualizerEnabled.value 
                              ? Colors.green 
                              : Colors.white,
                          size: 24,
                        ),
                        onPressed: () {
                          controller.toggleEqualizer();
                          // Show brief feedback
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
                              duration: const Duration(milliseconds: 1000),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                      )),
                    ),
                  ],
                ),
              ),

              // Enhanced Presets Section with User Empathy
              Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
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
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sound Presets',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Tap to apply',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Obx(() => Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: controller.getAvailablePresets().map((preset) {
                        final isSelected = controller.currentPreset.value == preset;
                        return GestureDetector(
                          onTap: () {
                            controller.applyPreset(preset);
                            // Show feedback for preset change
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
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Colors.white.withOpacity(0.25)
                                  : Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(25),
                              border: isSelected 
                                  ? Border.all(color: Colors.white.withOpacity(0.4), width: 1.5)
                                  : Border.all(color: Colors.white.withOpacity(0.1)),
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
                                fontSize: 14,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    )),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Enhanced Equalizer Bands with User Empathy - Fixed Height
              Container(
                margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
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
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Frequency Bands',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Drag to adjust',
                          style: TextStyle(
                            fontSize: screenWidth * 0.03,
                            fontWeight: FontWeight.w400,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: screenHeight * 0.2, // Smaller height to prevent overflow
                      child: Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(
                          EqualizerController.frequencyBands.length,
                          (index) => _buildEnhancedFrequencyBand(
                            controller,
                            index,
                            screenHeight * 0.15, // Much smaller height to fit
                            context,
                          ),
                        ),
                      )),
                    ),
                    const SizedBox(height: 20),
                    // Enhanced Reset Button with User Empathy
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.15),
                            Colors.white.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            controller.resetToFlat();
                            // Show feedback for reset
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
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.refresh,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 20,
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
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedFrequencyBand(
    EqualizerController controller,
    int index,
    double maxHeight,
    BuildContext context,
  ) {
    final gain = controller.getBandGain(index);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Enhanced gain value display with better visual feedback
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: _getBandColor(gain).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Text(
            '${gain.toStringAsFixed(0)}dB', // Integer to save space
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        
        // Enhanced frequency band slider with better visual feedback
        SizedBox(
          height: maxHeight,
          width: 25, // Much smaller width to fit all bands
          child: RotatedBox(
            quarterTurns: -1,
            child: SliderTheme(
              data: SliderTheme.of(Get.context!).copyWith(
                activeTrackColor: _getBandColor(gain),
                inactiveTrackColor: Colors.white.withOpacity(0.15),
                thumbColor: _getBandColor(gain),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5),
                trackHeight: 3,
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 10),
                overlayColor: _getBandColor(gain).withOpacity(0.2),
              ),
              child: Slider(
                value: gain,
                min: -12.0,
                max: 12.0,
                divisions: 48, // 0.5 dB steps
                onChanged: (value) {
                  controller.setBandGain(index, value);
                  // Show subtle feedback for fine adjustments
                  if ((value - gain).abs() > 1.0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${controller.getFrequencyLabel(index)}: ${value.toStringAsFixed(1)}dB',
                          style: const TextStyle(color: Colors.white),
                        ),
                        backgroundColor: _getBandColor(value).withOpacity(0.8),
                        duration: const Duration(milliseconds: 600),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 6),
        
        // Enhanced frequency label with better typography
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Text(
            controller.getFrequencyLabel(index),
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 9,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
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

