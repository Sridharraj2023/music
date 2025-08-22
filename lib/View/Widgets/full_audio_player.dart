// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:just_audio/just_audio.dart';
// import '../../Controller/BottomBar_Controller.dart';
// import '../widgets/gradient_container.dart';

// class FullAudioPlayerScreen extends StatelessWidget {
//   final bool isBinaural; // Determines if it's binaural or music
//   final String track;

//   FullAudioPlayerScreen(
//       {super.key, required this.isBinaural, required this.track});

//   final BottomBarController controller = Get.find(); // GetX Controller

//   String _formatDuration(Duration d) {
//     String minutes = d.inMinutes.toString().padLeft(2, '0');
//     String seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
//     return "$minutes:$seconds";
//   }

//   @override
//   Widget build(BuildContext context) {
//     final AudioPlayer player =
//         isBinaural ? controller.binauralPlayer : controller.musicPlayer;
//     final Rx<Duration> position = Duration.zero.obs;
//     final Rx<Duration> duration = Duration.zero.obs;
//     final RxBool isPlaying =
//         isBinaural ? controller.isBinauralPlaying : controller.isMusicPlaying;
//     final RxDouble volume =
//         isBinaural ? controller.binauralVolume : controller.musicVolume;
//     // Set the asset when the screen is built
//     player.setAsset(track);

//     // List of asset paths for songs (replace with your actual asset paths)
//     List<String> assetSongs = [
//       'assets/music/song1.mp3',
//       'assets/music/song2.mp3',
//       'assets/music/song3.mp3',
//       // Add more songs here
//     ];
//     RxInt currentSongIndex = RxInt(0); // Keeps track of the current song index

//     // Listen to position and duration changes
//     player.durationStream.listen((d) => duration.value = d ?? Duration.zero);
//     player.positionStream.listen((p) => position.value = p);

//     // MediaQuery for screen dimensions
//     double screenWidth = MediaQuery.of(context).size.width;
//     double screenHeight = MediaQuery.of(context).size.height;

//     // Method to play song at a given index from assets
//     void playSongAtIndex(int index) {
//       if (index >= 0 && index < assetSongs.length) {
//         currentSongIndex.value = index;
//         player.setAsset(assetSongs[index]);
//         player.play();
//         isPlaying.value = true;
//       }
//     }

//     return Scaffold(
//       body: GradientContainer(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           children: [
//             SizedBox(height: screenHeight * 0.03), // 3% of screen height
//             // Header with Back Button
//             Padding(
//               padding: EdgeInsets.symmetric(
//                   horizontal: screenWidth * 0.05), // 5% of screen width
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.arrow_back,
//                         color: Colors.white, size: 30),
//                     onPressed: () => Get.back(),
//                   ),
//                   Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         "ELEVATE",
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.08, // Scaled text size
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                           letterSpacing: 1.5,
//                         ),
//                       ),
//                       Text(
//                         "by Frequency Tuning",
//                         style: TextStyle(
//                           fontSize: screenWidth * 0.03, // Scaled text size
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ],
//                   ),
//                   GestureDetector(
//                     onTap: () {},
//                     child: Image.asset(
//                       'assets/images/Elevate Logo White.png',
//                       height: screenHeight * 0.08, // Scaled size
//                       width: screenWidth * 0.15, // Scaled size
//                     ),
//                   )
//                 ],
//               ),
//             ),

//             SizedBox(height: screenHeight * 0.05), // 5% of screen height

//             // Album Art
//             Container(
//               width: screenWidth * 0.6, // Scaled width
//               height: screenHeight * 0.3, // Scaled height
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(20),
//                 border: Border.all(color: Colors.white, width: 2),
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(20),
//                 child: const Icon(
//                   Icons.music_note_rounded,
//                   color: Colors.white,
//                   size: 50,
//                 ),
//               ),
//             ),

//             SizedBox(height: screenHeight * 0.04), // 4% of screen height

//             // Song Title
//             Text(
//               isBinaural ? "Binaural Beats" : "Music Track",
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: screenWidth * 0.06, // Scaled text size
//                 fontWeight: FontWeight.bold,
//               ),
//               textAlign: TextAlign.center,
//             ),

//             const Text(
//               "Frequency\nTuning",
//               style: TextStyle(color: Colors.white70, fontSize: 16),
//               textAlign: TextAlign.center,
//             ),

//             SizedBox(height: screenHeight * 0.04), // 4% of screen height

//             // Seek Bar + Time Display
//             Obx(
//               () => Padding(
//                 padding: EdgeInsets.symmetric(
//                     horizontal: screenWidth * 0.08), // 8% of screen width
//                 child: Column(
//                   children: [
//                     Slider(
//                       activeColor: Colors.white,
//                       inactiveColor: Colors.white30,
//                       min: 0,
//                       max: duration.value.inSeconds.toDouble(),
//                       value: position.value.inSeconds.toDouble(),
//                       onChanged: (value) {
//                         player.seek(Duration(seconds: value.toInt()));
//                       },
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(_formatDuration(position.value),
//                             style: const TextStyle(
//                                 color: Colors.white, fontSize: 14)),
//                         Text(_formatDuration(duration.value),
//                             style: const TextStyle(
//                                 color: Colors.white, fontSize: 14)),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             // Volume Control
//             SizedBox(height: screenHeight * 0.04 - 30), // 4% of screen height

//             const SizedBox(
//               height: 10,
//             ),
//             // Controls
//             Padding(
//               padding: EdgeInsets.symmetric(
//                   horizontal: screenWidth * 0.08), // 8% of screen width
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.skip_previous,
//                         color: Colors.white, size: 40),
//                     onPressed: () {
//                       int previousIndex = currentSongIndex.value - 1;
//                       if (previousIndex >= 0) {
//                         playSongAtIndex(previousIndex);
//                       }
//                     },
//                   ),
//                   IconButton(
//                     icon:
//                         const Icon(Icons.replay, color: Colors.white, size: 35),
//                     onPressed: () {
//                       player.seek(Duration.zero);
//                     },
//                   ),
//                   FloatingActionButton(
//                     backgroundColor: const Color(0xFF516ae4),
//                     onPressed: () {
//                       isPlaying.value = !isPlaying.value;
//                       isPlaying.value ? player.play() : player.pause();
//                     },
//                     child: Obx(() => Icon(
//                           isPlaying.value ? Icons.pause : Icons.play_arrow,
//                           size: screenWidth * 0.1, // Scaled size
//                         )),
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.favorite_border,
//                         color: Colors.white, size: 35),
//                     onPressed: () {},
//                   ),
//                   IconButton(
//                     icon: const Icon(Icons.skip_next,
//                         color: Colors.white, size: 40),
//                     onPressed: () {
//                       int nextIndex = currentSongIndex.value + 1;
//                       if (nextIndex < assetSongs.length) {
//                         playSongAtIndex(nextIndex);
//                       }
//                     },
//                   ),
//                 ],
//               ),
//             ),

//             SizedBox(height: screenHeight * 0.04), // 4% of screen height

//             // Indicator
//             Container(
//               width: screenWidth * 0.15, // Scaled width
//               height: 5,
//               decoration: BoxDecoration(
//                 color: Colors.white30,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:elevate/Model/music_item.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Controller/BottomBar_Controller.dart';
import '../widgets/gradient_container.dart';

class FullAudioPlayerScreen extends StatelessWidget {
  final bool isBinaural; // Determines if it's binaural or music
  final String track;
  final List<MusicItem> musics;

  FullAudioPlayerScreen(
      {super.key,
      required this.isBinaural,
      required this.track,
      required this.musics});

  final BottomBarController controller = Get.find(); // GetX Controller

  @override
  Widget build(BuildContext context) {
    // MediaQuery for screen dimensions
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Get the appropriate player and state based on type
    final isPlaying =
        isBinaural ? controller.isBinauralPlaying : controller.isMusicPlaying;

    final position =
        isBinaural ? controller.binauralPosition : controller.musicPosition;

    final duration =
        isBinaural ? controller.binauralDuration : controller.musicDuration;

    final volume =
        isBinaural ? controller.binauralVolume : controller.musicVolume;

    final playlist =
        isBinaural ? controller.binauralPlaylist : controller.musicPlaylist;

    final currentIndex = isBinaural
        ? controller.currentBinauralIndex
        : controller.currentMusicIndex;

    // Functions for player control
    void togglePlayPause() {
      if (isBinaural) {
        controller.toggleBinauralPlayback();
      } else {
        controller.toggleMusicPlayback();
      }
    }

    void nextTrack() {
      if (isBinaural) {
        controller.nextBinauralTrack();
      } else {
        controller.nextMusicTrack();
      }
    }

    void previousTrack() {
      if (isBinaural) {
        controller.previousBinauralTrack();
      } else {
        controller.previousMusicTrack();
      }
    }

    void seekTo(Duration position) {
      if (isBinaural) {
        controller.seekBinaural(position);
      } else {
        controller.seekMusic(position);
      }
    }

    void setVolumeLevel(double value) {
      if (isBinaural) {
        controller.setBinauralVolume(value);
      } else {
        controller.setMusicVolume(value);
      }
    }

    // Get track title

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
                  )
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.05), // 5% of screen height
            Obx(() {
              final currentTrack = isBinaural
                  ? controller
                      .binauralPlaylists[controller.currentBinauralIndex.value]
                  : controller
                      .musicPlaylists[controller.currentMusicIndex.value];

              return ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  currentTrack.imageUrl,
                  width: screenWidth * 0.6, // Scaled width
                  height: screenHeight * 0.3, // Scaled height
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: screenWidth * 0.6, // Scaled width
                      height: screenHeight * 0.3, // Scaled height
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: const Icon(
                          Icons.music_note_rounded,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    );
                  },
                ),
              );
            }),

            // Album Art
            // Container(
            //   width: screenWidth * 0.6, // Scaled width
            //   height: screenHeight * 0.3, // Scaled height
            //   decoration: BoxDecoration(
            //     borderRadius: BorderRadius.circular(20),
            //     border: Border.all(color: Colors.white, width: 2),
            //   ),
            //   child: ClipRRect(
            //     borderRadius: BorderRadius.circular(20),
            //     child: const Icon(
            //       Icons.music_note_rounded,
            //       color: Colors.white,
            //       size: 50,
            //     ),
            //   ),
            // ),

            SizedBox(height: screenHeight * 0.04), // 4% of screen height

            // Song Title
            // Text(
            //   trackTitle,
            //   style: TextStyle(
            //     color: Colors.white,
            //     fontSize: screenWidth * 0.06, // Scaled text size
            //     fontWeight: FontWeight.bold,
            //   ),
            //   textAlign: TextAlign.center,
            // ),
            Obx(() {
              final currentTrack = isBinaural
                  ? controller
                      .binauralPlaylists[controller.currentBinauralIndex.value]
                  : controller
                      .musicPlaylists[controller.currentMusicIndex.value];

              return Text(
                currentTrack.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: screenWidth * 0.06,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              );
            }),

            const Text(
              "Frequency\nTuning",
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: screenHeight * 0.04), // 4% of screen height

            // Seek Bar + Time Display
            Obx(
              () => Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.08), // 8% of screen width
                child: Column(
                  children: [
                    Slider(
                      activeColor: Colors.white,
                      inactiveColor: Colors.white30,
                      min: 0,
                      max: duration.value.inSeconds > 0
                          ? duration.value.inSeconds.toDouble()
                          : 1,
                      value: position.value.inSeconds.toDouble(),
                      onChanged: (value) {
                        seekTo(Duration(seconds: value.toInt()));
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(controller.formatDuration(position.value),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14)),
                        Text(controller.formatDuration(duration.value),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Volume Control
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                height: 25,
                width: 180,
                child: Obx(() => Row(
                      children: [
                        Icon(
                          volume.value == 0
                              ? Icons.volume_off
                              : Icons.volume_up,
                          color: Colors.white,
                          size: 24,
                        ),
                        Expanded(
                          child: Slider(
                            activeColor: Colors.white,
                            inactiveColor: Colors.white30,
                            min: 0,
                            max: 1,
                            value: volume.value,
                            onChanged: setVolumeLevel,
                          ),
                        ),
                      ],
                    )),
              ),
            ),
            SizedBox(
              height: 20,
            ),

            // Controls
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.08), // 8% of screen width
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    icon: const Icon(Icons.skip_previous,
                        color: Colors.white, size: 40),
                    onPressed: previousTrack,
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.replay, color: Colors.white, size: 35),
                    onPressed: () {
                      seekTo(Duration.zero);
                    },
                  ),
                  Obx(() => FloatingActionButton(
                        backgroundColor: const Color(0xFF516ae4),
                        onPressed: togglePlayPause,
                        child: Icon(
                          isPlaying.value ? Icons.pause : Icons.play_arrow,
                          size: screenWidth * 0.1, // Scaled size
                        ),
                      )),
                  IconButton(
                    icon: const Icon(Icons.favorite_border,
                        color: Colors.white, size: 35),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.skip_next,
                        color: Colors.white, size: 40),
                    onPressed: nextTrack,
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.04), // 4% of screen height

            // Playlist indicator
            Obx(() => Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    playlist.length,
                    (index) => Container(
                      width: 8,
                      height: 8,
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == currentIndex.value
                            ? Colors.white
                            : Colors.white30,
                      ),
                    ),
                  ),
                )),

            // Indicator
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
