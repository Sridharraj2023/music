import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../../Controller/BottomBar_Controller.dart';
import '../widgets/gradient_container.dart';
import '../Screens/Standalone_Equalizer_Screen.dart';

class FullAudioPlayerScreen extends StatelessWidget {
  final bool isBinaural; // Determines if it's binaural or music
  final String track;

  FullAudioPlayerScreen(
      {super.key, required this.isBinaural, required this.track});

  final BottomBarController controller = Get.find(); // GetX Controller

  String _formatDuration(Duration d) {
    String minutes = d.inMinutes.toString().padLeft(2, '0');
    String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final AudioPlayer player =
        isBinaural ? controller.binauralPlayer : controller.musicPlayer;
    
    // Set the asset when the screen is built
    player.setAsset(track);

    // MediaQuery for screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Navigation functions
    void previousTrack() {
      if (isBinaural) {
        controller.previousBinauralTrack();
      } else {
        controller.previousMusicTrack();
      }
    }

    void nextTrack() {
      if (isBinaural) {
        controller.nextBinauralTrack();
      } else {
        controller.nextMusicTrack();
      }
    }

    void togglePlayPause() {
      if (isBinaural) {
        controller.toggleBinauralPlayback();
      } else {
        controller.toggleMusicPlayback();
      }
    }

    void setVolumeLevel(double value) {
      if (isBinaural) {
        controller.setBinauralVolume(value);
      } else {
        controller.setMusicVolume(value);
      }
    }

    return Scaffold(
      body: GradientContainer(
        child: Obx(() {
          // Get current track info
          final currentTrack = isBinaural
              ? controller.binauralPlaylists[controller.currentBinauralIndex.value]
              : controller.musicPlaylists[controller.currentMusicIndex.value];
          
          // Get observable values
          final position = isBinaural ? controller.binauralPosition : controller.musicPosition;
          final duration = isBinaural ? controller.binauralDuration : controller.musicDuration;
          final isPlaying = isBinaural ? controller.isBinauralPlaying : controller.isMusicPlaying;
          final volume = isBinaural ? controller.binauralVolume : controller.musicVolume;

          return SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Section
                    Column(
                      children: [
                        SizedBox(height: screenHeight * 0.02),
                        
                        // Header with Back Button
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
                                  onPressed: () => Get.back(),
                                ),
                              ),
                              Column(
                                children: [
                                  Text(
                                    "ELEVATE",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.07,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: 2.0,
                                    ),
                                  ),
                                  Text(
                                    "by Frequency Tuning",
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Image.asset(
                                    'assets/images/Elevate Logo White.png',
                                    height: 32,
                                    width: 32,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.06),

                        // Album Art with Enhanced Design
                        Container(
                          width: screenWidth * 0.75,
                          height: screenWidth * 0.75,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Image.network(
                              currentTrack.imageUrl,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.1),
                                        Colors.white.withOpacity(0.05),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white.withOpacity(0.7)),
                                          strokeWidth: 3,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          "Loading...",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.7),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withOpacity(0.2),
                                        Colors.white.withOpacity(0.1),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.music_note,
                                        size: 80,
                                        color: Colors.white.withOpacity(0.6),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        "No Image Available",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.6),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.05),

                        // Track Information with Better Typography
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                          child: Column(
                            children: [
                              Text(
                                currentTrack.title,
                                style: TextStyle(
                                  fontSize: screenWidth * 0.055,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.3,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  "Frequency Tuning",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Bottom Section
                    Column(
                      children: [
                        SizedBox(height: screenHeight * 0.05),

                        // Enhanced Progress Bar
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.08),
                          child: Column(
                            children: [
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white.withOpacity(0.2),
                                  thumbColor: Colors.white,
                                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                  trackHeight: 4,
                                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                                ),
                                child: Slider(
                                  value: position.value.inSeconds.toDouble(),
                                  max: duration.value.inSeconds > 0 
                                      ? duration.value.inSeconds.toDouble() 
                                      : 1,
                                  onChanged: (value) {
                                    player.seek(Duration(seconds: value.toInt()));
                                  },
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(position.value),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(duration.value),
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.04),

                        // Enhanced Volume Control
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.12),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  volume.value == 0 
                                      ? Icons.volume_off 
                                      : volume.value < 0.5 
                                          ? Icons.volume_down 
                                          : Icons.volume_up,
                                  color: Colors.white.withOpacity(0.8),
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderTheme.of(context).copyWith(
                                    activeTrackColor: Colors.white,
                                    inactiveTrackColor: Colors.white.withOpacity(0.2),
                                    thumbColor: Colors.white,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                                    trackHeight: 3,
                                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                                  ),
                                  child: Slider(
                                    value: volume.value,
                                    onChanged: setVolumeLevel,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.05),

                        // Enhanced Control Buttons
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildControlButton(
                                icon: Icons.skip_previous,
                                onPressed: previousTrack,
                                size: 28,
                              ),
                              _buildControlButton(
                                icon: Icons.replay,
                                onPressed: () => player.seek(Duration.zero),
                                size: 24,
                              ),
                              _buildMainPlayButton(
                                isPlaying: isPlaying.value,
                                onPressed: togglePlayPause,
                                size: screenWidth * 0.18,
                              ),
                              _buildControlButton(
                                icon: Icons.shuffle,
                                onPressed: () {},
                                size: 24,
                              ),
                              _buildControlButton(
                                icon: Icons.skip_next,
                                onPressed: nextTrack,
                                size: 28,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Simple Equalizer Button - Navigate to Standalone Screen
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
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
                              onTap: () => Get.to(() => const StandaloneEqualizerScreen()),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.graphic_eq,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Equalizer',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      color: Colors.white.withOpacity(0.5),
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: screenHeight * 0.06),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onPressed,
    required double size,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(25),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: size),
        iconSize: size,
      ),
    );
  }

  Widget _buildMainPlayButton({
    required bool isPlaying,
    required VoidCallback onPressed,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size / 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(size / 2),
          onTap: onPressed,
          child: Center(
            child: Icon(
              isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.black,
              size: size * 0.4,
            ),
          ),
        ),
      ),
    );
  }
}