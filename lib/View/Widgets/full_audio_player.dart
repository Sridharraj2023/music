import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../../Controller/BottomBar_Controller.dart';
import '../widgets/gradient_container.dart';

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
    final Rx<Duration> position = Duration.zero.obs;
    final Rx<Duration> duration = Duration.zero.obs;
    final RxBool isPlaying =
        isBinaural ? controller.isBinauralPlaying : controller.isMusicPlaying;
    final RxDouble volume =
        isBinaural ? controller.binauralVolume : controller.musicVolume;
    
    // Set the asset when the screen is built
    player.setAsset(track);

    // Listen to position and duration changes
    player.durationStream.listen((d) => duration.value = d ?? Duration.zero);
    player.positionStream.listen((p) => position.value = p);

    // MediaQuery for screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Get current track info
    final currentTrack = isBinaural
        ? controller.binauralPlaylists[controller.currentBinauralIndex.value]
        : controller.musicPlaylists[controller.currentMusicIndex.value];

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.03), // 3% of screen height

            // Header with Back Button
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.05), // 5% of screen width
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 30),
                    onPressed: () => Get.back(),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "ELEVATE",
                        style: TextStyle(
                          fontSize: screenWidth * 0.08, // Scaled text size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        "by Frequency Tuning",
                        style: TextStyle(
                          fontSize: screenWidth * 0.03, // Scaled text size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {},
                    child: Image.asset(
                      'assets/images/Elevate Logo White.png',
                      height: screenHeight * 0.08, // Scaled size
                      width: screenWidth * 0.15, // Scaled size
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.04), // 4% of screen height

            // Album Art/Image
            Obx(() {
              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  currentTrack.imageUrl,
                  width: screenWidth * 0.6, // Scaled width
                  height: screenHeight * 0.3, // Scaled height
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.3,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print('Full player image load error: $error');
                    print('Image URL: ${currentTrack.imageUrl}');
                    return Container(
                      width: screenWidth * 0.6,
                      height: screenHeight * 0.3,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.music_note, size: 60, color: Colors.grey),
                    );
                  },
                ),
              );
            }),

            SizedBox(height: screenHeight * 0.04), // 4% of screen height

            // Track Title
            Obx(() {
              return Text(
                currentTrack.title,
                style: TextStyle(
                  fontSize: screenWidth * 0.06, // Scaled text size
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              );
            }),

            SizedBox(height: screenHeight * 0.02), // 2% of screen height

            // Artist Name
            const Text(
              "Frequency\nTuning",
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: screenHeight * 0.04), // 4% of screen height

            // Progress Bar
            Obx(() => Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.1), // 10% of screen width
              child: Column(
                children: [
                  Slider(
                    value: position.value.inSeconds.toDouble(),
                    max: duration.value.inSeconds.toDouble(),
                    onChanged: (value) {
                      player.seek(Duration(seconds: value.toInt()));
                    },
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(position.value),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      Text(
                        _formatDuration(duration.value),
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            )),

            SizedBox(height: screenHeight * 0.04), // 4% of screen height

            // Volume Control
            Obx(() => Row(
              children: [
                Icon(
                  volume.value == 0 ? Icons.volume_off : Icons.volume_up,
                  color: Colors.white70,
                ),
                Expanded(
                  child: Slider(
                    value: volume.value,
                    onChanged: setVolumeLevel,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                  ),
                ),
              ],
            )),

            SizedBox(height: screenHeight * 0.04), // 4% of screen height

            // Control Buttons
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08), // 8% of screen width
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: previousTrack,
                    icon: const Icon(Icons.skip_previous, color: Colors.white, size: 30),
                  ),
                  IconButton(
                    onPressed: () {
                      player.seek(Duration.zero);
                    },
                    icon: const Icon(Icons.replay, color: Colors.white, size: 30),
                  ),
                  Obx(() => FloatingActionButton(
                    onPressed: togglePlayPause,
                    backgroundColor: Colors.white,
                    child: Icon(
                      isPlaying.value ? Icons.pause : Icons.play_arrow,
                      color: Colors.black,
                      size: screenWidth * 0.1, // Scaled size
                    ),
                  )),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.shuffle, color: Colors.white, size: 30),
                  ),
                  IconButton(
                    onPressed: nextTrack,
                    icon: const Icon(Icons.skip_next, color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.04), // 4% of screen height

            // Progress Indicator
            Container(
              width: screenWidth * 0.15, // Scaled width
              height: 5,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}