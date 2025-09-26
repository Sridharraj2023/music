// // views/screens/binaural_page.dart
// import 'package:flutter/material.dart';

// import '../../Controller/Binaural_controller.dart';
// import '../../Model/Binaural_category.dart';

// import '../Widgets/Gradient_Container.dart';
// import '../Widgets/Round_option_button.dart';

// class BinauralPage extends StatelessWidget {
//   final BinauralController _binauralController = BinauralController();

//   @override
//   Widget build(BuildContext context) {
//     final List<List<BinauralCategory>> categories =
//         _binauralController.getBinauralCategories();

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: GradientContainer(
//         child: SingleChildScrollView(
//           child: Container(
//             padding: const EdgeInsets.only(top: 10),
//             child: Center(
//               child: Column(
//                 children: categories
//                     .map(
//                       (row) => Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: row
//                             .map(
//                               (category) => RoundedOptionButton(
//                                 label: category.name,
//                                 onTap: () {},
//                               ),
//                             )
//                             .toList(),
//                       ),
//                     )
//                     .toList(),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'dart:convert';
import 'dart:developer';

import 'package:elevate/Controller/BottomBar_Controller.dart';
import 'package:elevate/Model/music_item.dart';
import 'package:elevate/utlis/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Controller/Binaural_controller.dart';
import '../Widgets/Gradient_Container.dart';
import '../Widgets/Round_option_button.dart';
import 'package:http/http.dart' as http;

class BinauralPage extends StatelessWidget {
  final BinauralController _binauralController = BinauralController();

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: FutureBuilder<List<Category>>(
        future: _binauralController.fetchBinauralCategory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(
              color: Colors.white,
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final types = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                children: [
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 10,
                      childAspectRatio: 2.8,
                      children: types.map((type) {
                        return RoundedOptionButton(
                          label: type.name,
                          onTap: () {
                            // Handle tap on each binaural type
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => BinauralSongsScreen(
                            //       typeId: type.id,
                            //       typeName: type.name,
                            //     ),
                            //   ),
                            // );
                            Get.to(
                              BinauralSongsScreen(
                                typeId: type.id,
                                typeName: type.name,
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No binaural types available'));
          }
        },
      ),
    );
  }
}

class BinauralSongsScreen extends StatelessWidget {
  final String typeId;
  final String typeName;

  BinauralSongsScreen({
    super.key,
    required this.typeId,
    required this.typeName,
  });

  final BottomBarController bottomBarController =
      Get.find<BottomBarController>();

  Future<List<MusicItem>> fetchSongsByType(String id) async {
    return await ApiService.fetchAllMusic(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: const Icon(Icons.arrow_back_ios_new,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 46),
                  Expanded(
                    child: Text(
                      typeName,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: FutureBuilder<List<MusicItem>>(
                future: fetchSongsByType(typeId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        'No songs found for "$typeName"',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    );
                  }

                  final songs = snapshot.data!;
                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: songs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final song = songs[index];
                      return GestureDetector(
                        onTap: () {
                          Get.back();
                          log(song.fileUrl);
                          bottomBarController.isBinauralPlaying.value = true;
                          bottomBarController.playBinaural(song.fileUrl);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(16),
                                        bottomLeft: Radius.circular(16)),
                                    child: Image.asset(
                                      'assets/images/music_bg.jpg', // Replace with dynamic image if available
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              const Icon(Icons.music_note,
                                                  color: Colors.white,
                                                  size: 80),
                                    ),
                                  ),
                                  // const Positioned.fill(
                                  //   child: Center(
                                  //     child: Icon(Icons.play_circle_fill,
                                  //         color: Colors.white, size: 36),
                                  //   ),
                                  // ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        song.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        song.artist,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Icon(Icons.play_circle_fill,
                                  size: 36, color: Colors.white70),
                              const SizedBox(
                                width: 10,
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// class BinauralSongsScreen extends StatelessWidget {
//   final String typeId;
//   final String typeName;

//   BinauralSongsScreen(
//       {super.key, required this.typeId, required this.typeName});
//   final BottomBarController bottomBarController =
//       Get.find<BottomBarController>();

//   Future<List<MusicItem>> fetchSongsByType(String id) async {
//     return await ApiService.fetchAllMusic(id);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: Colors.transparent,
//       body: GradientContainer(
//         child: Column(
//           children: [
//             const SizedBox(height: 50),
//             Row(
//               children: [
//                 const SizedBox(width: 20),
//                 const Icon(Icons.arrow_back, color: Colors.white),
//                 const SizedBox(width: 50),
//                 Text(
//                   typeName,
//                   style: const TextStyle(
//                     fontSize: 25,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                     letterSpacing: 1.5,
//                   ),
//                 ),
//               ],
//             ),
//             Expanded(
//               child: FutureBuilder<List<MusicItem>>(
//                 future: fetchSongsByType(typeId),
//                 builder: (context, snapshot) {
//                   if (snapshot.connectionState == ConnectionState.waiting) {
//                     return const Center(child: CircularProgressIndicator());
//                   } else if (snapshot.hasError) {
//                     return Center(child: Text('Error: ${snapshot.error}'));
//                   } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                     return Center(
//                         child: Text('No songs found for "$typeName"'));
//                   }

//                   final songs = snapshot.data!;
//                   return ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: songs.length,
//                     itemBuilder: (context, index) {
//                       final song = songs[index];
//                       return ListTile(
//                         leading:
//                             const Icon(Icons.music_note, color: Colors.white),
//                         title: Text(song.title,
//                             style: const TextStyle(color: Colors.white)),
//                         subtitle: Text(song.artist,
//                             style: const TextStyle(color: Colors.white70)),
//                         onTap: () {
//                           // Handle play or navigate to full player
//                           // Play Binaural
//                           Get.back();
//                           log(song.fileUrl);
//                           bottomBarController.isBinauralPlaying.value = true;

//                           bottomBarController.playBinaural(
//                               song.fileUrl); // Ensure file exists!
//                         },
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class ApiService {
  // static Future<List<MusicItem>> fetchSongsByType(String typeId) async {
  //   final response = await http
  //       .get(Uri.parse('http://69.62.68.79:5000/api/songs/type/$typeId'));
  //   if (response.statusCode == 200) {
  //     final List<dynamic> data = jsonDecode(response.body);
  //     return data.map((json) => MusicItem.fromJson(json)).toList();
  //   } else {
  //     throw Exception('Failed to load songs');
  //   }
  // }

  static Future<List<MusicItem>> fetchAllMusic(String typeId) async {
    final String baseUrl = "${ApiConstants.apiUrl}/music";

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('auth_token');

      if (token == null)
        throw Exception("User not authenticated. No token found.");

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final response = await http.get(Uri.parse(baseUrl), headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = jsonDecode(response.body);
        final cachedAllMusic =
            jsonResponse.map((data) => MusicItem.fromJson(data)).toList();
        return cachedAllMusic
            .where((item) => item.categoryType.id == typeId)
            .toList();
      } else {
        throw Exception("Failed to load music: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching music: $e");
      return [];
    }
  }
}
