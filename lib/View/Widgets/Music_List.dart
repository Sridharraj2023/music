// views/widgets/music_list.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../Controller/BottomBar_Controller.dart';
import '../../Model/music_item.dart';
import 'package:elevate/utlis/api_constants.dart';

class MusicList extends StatelessWidget {
  final List<MusicItem> items;
  final bool isBinaural; // New flag to differentiate

  MusicList({required this.items, this.isBinaural = false, super.key});
  final BottomBarController bottomBarController =
      Get.find<BottomBarController>();
  @override
  Widget build(BuildContext context) {
    String _resolveImageUrl(String url) {
      if (url.isEmpty) return url;
      try {
        if (url.startsWith('/uploads/')) {
          return ApiConstants.resolvedApiUrl.replaceAll('/api', '') + url;
        }
        final uri = Uri.parse(url);
        if (uri.host.startsWith('192.168.') || uri.host == 'localhost' || uri.host == '127.0.0.1' || uri.host.contains('local')) {
          final prod = ApiConstants.resolvedApiUrl.replaceAll('/api', '');
          final replaced = url.replaceAll(uri.host, Uri.parse(prod).host).replaceAll('http://', 'https://');
          return replaced.replaceAll(':${uri.port}', '');
        }
      } catch (_) {}
      return url;
    }
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
                        print("🎵 Music item tapped: ${item.title}");
                        print("🎵 File URL: ${item.fileUrl}");
                        print("🎵 Is Binaural: $isBinaural");
                        
                        if (isBinaural) {
                          // Play Binaural
                          print("🎧 Setting binaural playing state");
                          bottomBarController.isBinauralPlaying.value = true;
                        } else {
                          // Play Music
                          print("🎵 Setting music playing state");
                          bottomBarController.isMusicPlaying.value = true;
                        }
                        
                        log(item.fileUrl);
                        
                        if (isBinaural) {
                          print("🎧 Calling playBinaural with: ${item.fileUrl}");
                          // Test with a known working URL if the API URL fails
                          final testUrl = item.fileUrl.isNotEmpty 
                              ? item.fileUrl 
                              : "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav";
                          bottomBarController.playBinaural(testUrl);
                        } else {
                          print("🎵 Calling playMusic with: ${item.fileUrl}");
                          // Test with a known working URL if the API URL fails
                          final testUrl = item.fileUrl.isNotEmpty 
                              ? item.fileUrl 
                              : "https://www.soundjay.com/misc/sounds/bell-ringing-05.wav";
                          bottomBarController.playMusic(testUrl);
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
                          _resolveImageUrl(item.imageUrl),
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
                            print('Image URL: ${_resolveImageUrl(item.imageUrl)}');
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
