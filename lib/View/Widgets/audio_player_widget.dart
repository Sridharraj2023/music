import 'dart:developer';

import 'package:elevate/Model/music_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/BottomBar_Controller.dart';
import '../../utils/responsive_helper.dart';
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

      const double _miniPlayerHeight = 96;
      if (bottomBarController.isBinauralPlaying.value) {
        return SizedBox(
          height: _miniPlayerHeight,
          child: _buildPlayer(
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
        );
      }

      return SizedBox(
        height: _miniPlayerHeight,
        child: _buildPlayer(
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
    if (track.isEmpty) {
      return const Center(
        child: Text(
          "Track not available",
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    final BottomBarController controller = Get.find();
    final positionText =
        Get.find<BottomBarController>().formatDuration(position);
    final durationText =
        Get.find<BottomBarController>().formatDuration(duration);
    final isPlaying = label == 'binaural'
        ? Get.find<BottomBarController>().isBinauralPlaying.value
        : Get.find<BottomBarController>().isMusicPlaying.value;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ResponsiveCenter(
        maxWidth: 800,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
          // Vertical Label & Image
          Expanded(
            flex: 1,
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
                    height: 16,
                    width: 16,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),

          // Song details & Slider
          Expanded(
            flex: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() {
                  final currentTrack = label == 'binaural'
                      ? controller.binauralPlaylists[
                          controller.currentBinauralIndex.value]
                      : controller
                          .musicPlaylists[controller.currentMusicIndex.value];
                  log("Current Track: ${currentTrack.title}");

                  return Text(
                    currentTrack.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  );
                }),
                const Text(
                  "Frequency Tuning",
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.white70,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      positionText,
                      style: const TextStyle(
                        fontSize: 7,
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
                        fontSize: 7,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Playback Controls & Close Button
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => previous(),
                      child: const Icon(Icons.skip_previous,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 2),
                    InkWell(
                      onTap: () => togglePlayPause(),
                      child: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                          color: Colors.white,
                          size: 18),
                    ),
                    const SizedBox(width: 2),
                    InkWell(
                      onTap: () => next(),
                      child: const Icon(Icons.skip_next,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 2),
                    InkWell(
                      onTap: stop,
                      child: const Icon(Icons.close,
                          color: Colors.red, size: 20),
                    ),
                    const SizedBox(width: 2),
                    InkWell(
                      onTap: () {
                        Get.to(() => FullAudioPlayerScreen(
                              isBinaural: label == 'binaural',
                              track: track,
                            ));
                      },
                      child: const Icon(Icons.fullscreen,
                          color: Colors.white, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 16,
                      width: 80,
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
                        size: 16,
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