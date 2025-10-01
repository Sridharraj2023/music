import 'dart:developer';

import 'package:elevate/Model/music_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/BottomBar_Controller.dart';
import 'full_audio_player.dart';

class AudioPlayerWidget extends StatefulWidget {
  final List<MusicItem> musicList;
  final List<MusicItem> binauralList;

  const AudioPlayerWidget(
      {super.key, required this.musicList, required this.binauralList});

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final BottomBarController bottomBarController =
      Get.put(BottomBarController());

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    final BottomBarController bottomBarController =
        Get.put(BottomBarController());
    bottomBarController.setAllMusic(widget.musicList);
    bottomBarController.setAllBinaural(widget.binauralList);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!bottomBarController.isBinauralPlaying.value &&
          !bottomBarController.isMusicPlaying.value) {
        return const SizedBox.shrink(); // Hide when nothing is playing
      }

      // Debug: Log when audio player is visible
      log("AudioPlayerWidget: Building player widget with improved positioning");

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0), // Add margin
        constraints: const BoxConstraints(
          minHeight: 80.0, // Ensure minimum height
          maxHeight: 120.0, // Prevent excessive height
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF3A55F8), // Top blue
              Color(0xFF6F41F3), // Middle purple
              Color(0xFF8A2BE2), // Bottom violet
            ],
          ),
          borderRadius: BorderRadius.circular(12.0), // Add rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Keeps height minimal
          children: [
            if (bottomBarController.isMusicPlaying.value)
              _buildPlayer(
                "music",
                Colors.blue.shade800,
                bottomBarController.musicVolume,
                bottomBarController.setMusicVolume,
                bottomBarController.stopMusic,
                bottomBarController.musicTrack.value,
                bottomBarController.musicPosition.value,
                bottomBarController.musicDuration.value,
                () => bottomBarController.toggleMusicPlayback(),
                () => bottomBarController.previousMusicTrack(),
                () => bottomBarController.nextMusicTrack(),
                (position) => bottomBarController.seekMusic(position),
              ),
            if (bottomBarController.isBinauralPlaying.value)
              _buildPlayer(
                "binaural",
                Colors.purple.shade700,
                bottomBarController.binauralVolume,
                bottomBarController.setBinauralVolume,
                bottomBarController.stopBinaural,
                bottomBarController.binauralTrack.value,
                bottomBarController.binauralPosition.value,
                bottomBarController.binauralDuration.value,
                () => bottomBarController.toggleBinauralPlayback(),
                () => bottomBarController.previousBinauralTrack(),
                () => bottomBarController.nextBinauralTrack(),
                (position) => bottomBarController.seekBinaural(position),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildPlayer(
    String label,
    Color backgroundColor,
    RxDouble volume,
    Function(double) setVolume,
    Function() stop,
    String track,
    Duration position,
    Duration duration,
    Function() togglePlayPause,
    Function() previous,
    Function() next,
    Function(Duration) seek,
  ) {
    // Check if track is null or empty
    if (track.isEmpty) {
      return const Center(
        child: Text(
          "Track not available",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    // Get track title from controller
    final BottomBarController controller = Get.find();

    // Format current position and duration
    final positionText =
        Get.find<BottomBarController>().formatDuration(position);
    final durationText =
        Get.find<BottomBarController>().formatDuration(duration);

    // Check if track is playing
    final isPlaying = label == 'binaural'
        ? Get.find<BottomBarController>().isBinauralPlaying.value
        : Get.find<BottomBarController>().isMusicPlaying.value;

    return Container(
      margin: const EdgeInsets.all(8.0), // Add margin inside the main container
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Add padding
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRect(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Vertical Label & Image
            Expanded(
              flex: 1, // Reduced flex for label/image
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RotatedBox(
                    quarterTurns: -1,
                    child: Text(
                      label.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      'assets/images/Elevate Logo White.png',
                      height: 24,
                      width: 24,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),

            // Song details & Slider
            Expanded(
              flex: 5, // Increased flex for song details
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Obx(() {
                    final currentTrack = label == 'binaural'
                        ? controller.binauralPlaylists[
                            controller.currentBinauralIndex.value]
                        : controller.musicPlaylists[
                            controller.currentMusicIndex.value];
                    log("Current Track: ${currentTrack.title}");

                    return Flexible(
                      child: Text(
                        currentTrack.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    );
                  }),
                  const Text(
                    "Frequency Tuning",
                    style: TextStyle(
                      fontSize: 8, // Further reduced
                      color: Colors.white70,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        positionText,
                        style: const TextStyle(
                          fontSize: 7, // Reduced font size
                          color: Colors.white70,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: position.inSeconds.toDouble(),
                          min: 0,
                          max: duration.inSeconds > 0
                              ? duration.inSeconds.toDouble()
                              : 1,
                          onChanged: (value) {
                            seek(Duration(seconds: value.toInt()));
                          },
                          activeColor: Colors.white,
                          inactiveColor: Colors.white30,
                        ),
                      ),
                      Text(
                        durationText,
                        style: const TextStyle(
                          fontSize: 7, // Reduced font size
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Playback Controls & Close Button
            Flexible(
              flex: 1, // Reduced flex for controls
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Compact playback controls Row
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Essential controls only with minimal spacing
                      InkWell(
                        onTap: () => togglePlayPause(),
                        child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 14),
                      ),
                      const SizedBox(width: 1),
                      InkWell(
                        onTap: stop,
                        child: const Icon(Icons.close,
                            color: Colors.red, size: 14),
                      ),
                      const SizedBox(width: 1),
                      InkWell(
                        onTap: () {
                          Get.to(() => FullAudioPlayerScreen(
                                isBinaural: label == 'binaural',
                                track: track,
                              ));
                        },
                        child: const Icon(Icons.fullscreen,
                            color: Colors.white, size: 14),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  // Compact volume control
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Very compact volume slider
                      Expanded(
                        child: Slider(
                          value: volume.value,
                          onChanged: setVolume,
                          min: 0,
                          max: 1,
                          activeColor: Colors.white,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setVolume(volume.value > 0 ? 0 : 0.5);
                        },
                        child: Icon(
                          volume.value == 0
                              ? Icons.volume_off
                              : Icons.volume_up,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}