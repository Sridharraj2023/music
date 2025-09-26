// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../Controller/BottomBar_Controller.dart';
// import 'full_audio_player.dart';

// class AudioPlayerWidget extends StatelessWidget {
//   final BottomBarController bottomBarController =
//       Get.put(BottomBarController());

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (!bottomBarController.isBinauralPlaying.value &&
//           !bottomBarController.isMusicPlaying.value) {
//         return SizedBox.shrink(); // Hide when nothing is playing
//       }

//       return Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF3A55F8), // Top blue
//               Color(0xFF6F41F3), // Middle purple
//               Color(0xFF8A2BE2), // Bottom violet
//             ],
//           ),
//         ),
//         child: Column(
//           mainAxisSize: MainAxisSize.min, // Keeps height minimal
//           children: [
//             if (bottomBarController.isMusicPlaying.value)
//               _buildPlayer(
//                 "music",
//                 Colors.blue.shade800,
//                 bottomBarController.musicVolume,
//                 bottomBarController.setMusicVolume,
//                 bottomBarController.stopMusic, // Updated Stop Music Function
//                 bottomBarController
//                     .musicTrack.value, // Pass the current music track path
//               ),
//             if (bottomBarController.isBinauralPlaying.value)
//               _buildPlayer(
//                 "binaural",
//                 Colors.purple.shade700,
//                 bottomBarController.binauralVolume,
//                 bottomBarController.setBinauralVolume,
//                 bottomBarController
//                     .stopBinaural, // Updated Stop Binaural Function
//                 bottomBarController.binauralTrack
//                     .value, // Pass the current binaural track path
//               ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildPlayer(
//     String label,
//     Color backgroundColor,
//     RxDouble volume,
//     Function(double) setVolume,
//     Function() stop,
//     String track, // Pass the track name or path from assets
//   ) {
//     // Check if track is null or empty
//     if (track == null || track.isEmpty) {
//       return Center(
//         child: Text(
//           "Track not available", // You can handle this however you'd like
//           style: TextStyle(color: Colors.white),
//         ),
//       );
//     }

//     return Stack(
//       children: [
//         Container(
//           margin: const EdgeInsets.symmetric(vertical: 1),
//           padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
//           decoration: BoxDecoration(
//             color: backgroundColor,
//             borderRadius: BorderRadius.circular(6),
//           ),
//           child: Row(
//             children: [
//               // Vertical Label & Image
//               Column(
//                 children: [
//                   RotatedBox(
//                     quarterTurns: -1,
//                     child: Text(
//                       label.toUpperCase(),
//                       style: const TextStyle(
//                         fontSize: 8,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(4),
//                     child: Image.asset(
//                       'assets/images/Elevate Logo White.png',
//                       height: 24,
//                       width: 24,
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(width: 4), // Reduced spacing

//               // Song details & Slider
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         const Text(
//                           "Song Title", // You can use actual track title if needed
//                           style: TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Text(
//                       "Artist Name", // Replace with artist name if needed
//                       style: TextStyle(
//                         fontSize: 12,
//                         color: Colors.white70,
//                       ),
//                     ),
//                     // SizedBox(
//                     //   height: 25,
//                     //   child: Slider(
//                     //     value: volume.value,
//                     //     onChanged: setVolume,
//                     //     min: 0,
//                     //     max: 1,
//                     //     activeColor: Colors.white,
//                     //   ),
//                     // ),
//                   ],
//                 ),
//               ),

//               // Playback Controls & Close Button
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       IconButton(
//                         icon: const Icon(Icons.skip_previous,
//                             color: Colors.white, size: 25),
//                         onPressed: () {},
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.play_arrow,
//                             color: Colors.white, size: 25),
//                         onPressed: () {
//                           if (track != null && track.isNotEmpty) {
//                             // You may pass track name here for playing specific track
//                             Get.to(() => FullAudioPlayerScreen(
//                                   isBinaural: label == 'binaural',
//                                   track: track, // Pass the track path or name
//                                 ));
//                           } else {
//                             print("Track is null or empty");
//                           }
//                         },
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.skip_next,
//                             color: Colors.white, size: 25),
//                         onPressed: () {},
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.close,
//                             color: Colors.red, size: 25),
//                         onPressed: stop,
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.fullscreen,
//                             color: Colors.white, size: 25),
//                         onPressed: () {
//                           if (track != null && track.isNotEmpty) {
//                             Get.to(() => FullAudioPlayerScreen(
//                                 isBinaural: label == 'binaural', track: track));
//                           } else {
//                             print("Track is null or empty");
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                   Row(
//                     children: [
//                       SizedBox(
//                         height: 25,
//                         child: Slider(
//                           value: volume.value,
//                           onChanged: setVolume,
//                           min: 0,
//                           max: 1,
//                           activeColor: Colors.white,
//                         ),
//                       ),
//                       GestureDetector(
//                         onTap: () {
//                           setVolume(volume.value > 0
//                               ? 0
//                               : 0.5); // Toggle between mute and full volume
//                         },
//                         child: Icon(
//                           volume.value == 0
//                               ? Icons.volume_off
//                               : Icons.volume_up,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// ////////////////// Above Currect and fix Code ///////////////////////////////////////

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

      return Container(
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

    return Stack(
      children: [
        Container(
          //margin: const EdgeInsets.symmetric(vertical: 1),
          //padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 1),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(6),
          ),
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
                flex: 3, // Increased flex for song details
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Text(
                    //   trackTitle,
                    //   style: const TextStyle(
                    //     fontSize: 14, // Further reduced
                    //     fontWeight: FontWeight.bold,
                    //     color: Colors.white,
                    //   ),
                    //   overflow: TextOverflow.ellipsis,
                    //   maxLines: 1,
                    // ),
                    Obx(() {
                      final currentTrack = label == 'binaural'
                          ? controller.binauralPlaylists[
                              controller.currentBinauralIndex.value]
                          : controller.musicPlaylists[
                              controller.currentMusicIndex.value];
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
                        fontSize: 9, // Further reduced
                        color: Colors.white70,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        Text(
                          positionText,
                          style: const TextStyle(
                            fontSize: 8, // Reduced font size
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
                            fontSize: 8, // Reduced font size
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
                flex: 2, // Controls column
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Your updated playback controls Row goes here
                    // (The one we modified above)
                    Row(
                      children: [
                        // Use a more compact layout with smaller icons and spacing
                        InkWell(
                          onTap: () => previous(),
                          child: const Icon(Icons.skip_previous,
                              color: Colors.white, size: 25),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => togglePlayPause(),
                          child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 18),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => next(),
                          child: const Icon(Icons.skip_next,
                              color: Colors.white, size: 25),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: stop,
                          child: const Icon(Icons.close,
                              color: Colors.red, size: 25),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () {
                            Get.to(() => FullAudioPlayerScreen(
                                  isBinaural: label == 'binaural',
                                  track: track,
                                ));
                          },
                          child: const Icon(Icons.fullscreen,
                              color: Colors.white, size: 25),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    // Your updated volume slider Row goes here
                    // (The one we modified above)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Smaller volume slider
                        Container(
                          height: 20,
                          width: 100, // Further reduced width
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
                            size: 16, // Even smaller icon
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
      ],
    );
  }
}
