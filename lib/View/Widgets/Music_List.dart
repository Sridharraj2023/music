// views/widgets/music_list.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../Controller/BottomBar_Controller.dart';
import '../../Model/music_item.dart';

class MusicList extends StatelessWidget {
  final List<MusicItem> items;
  final bool isBinaural; // New flag to differentiate

  MusicList({required this.items, this.isBinaural = false, super.key});
  final BottomBarController bottomBarController =
      Get.find<BottomBarController>();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (isBinaural) {
                          // Play Binaural
                          bottomBarController.isBinauralPlaying.value = true;
                        } else {
                          // Play Music

                          bottomBarController.isMusicPlaying.value = true;
                        }
                        log(item.fileUrl);
                        if (isBinaural) {
                          bottomBarController.playBinaural(
                              item.fileUrl); // Ensure file exists!
                        } else {
                          bottomBarController
                              .playMusic(item.fileUrl); // Ensure file exists!
                        }
                        // if (isBinaural) {
                        //   bottomBarController.playBinaural(
                        //       'assets/audio/hybrid-epic-hollywood-trailer-247114.mp3'); // Ensure file exists!
                        // } else {
                        //   bottomBarController.playMusic(
                        //       'assets/audio/Lil Mama See Road Runner 128 Kbps.mp3'); // Ensure file exists!
                        // }
                      },
                      // child: Container(
                      //   width: 100,
                      //   height: 100,
                      //   margin: const EdgeInsets.only(right: 10),
                      //   decoration: BoxDecoration(
                      //     color: Colors.white,
                      //     borderRadius: BorderRadius.circular(12),
                      //   ),
                      //   child:
                      //       const Icon(Icons.image, size: 40, color: Colors.grey),
                      // ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          item.imageUrl,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            print('Image load error for ${item.title}: $error');
                            print('Image URL: ${item.imageUrl}');
                            return Container(
                              width: 100,
                              height: 100,
                              margin: const EdgeInsets.only(right: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.image,
                                  size: 40, color: Colors.grey),
                            );
                          },
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: SizedBox(
                        width: 100,
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.start,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        item.artist,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
