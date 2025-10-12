import 'package:elevate/Model/music_item.dart';
import 'package:elevate/View/Screens/Binaural_Screen.dart';
import 'package:elevate/View/Widgets/SubscriptionGuard.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../Controller/Music_Controller.dart';
import '../../utils/responsive_helper.dart';
import '../Widgets/Recently_played_items.dart';

import '../widgets/section_title.dart';

import '../widgets/genre_button.dart';

class MusicPage extends StatelessWidget {
  MusicPage({super.key});
  final MusicController controller = MusicController();

  @override
  Widget build(BuildContext context) {
    final recentlyPlayed = controller.getRecentlyPlayed();
    // final genres = controller.getGenres();

    return SubscriptionGuard(
      customMessage: 'Please subscribe to access music content',
      child: Scaffold(
      backgroundColor: Colors.transparent,
      body: ResponsiveCenter(
        maxWidth: 800,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              // const SectionTitle(
              //     title: "Recommendations",
              //     subtitle: "Based on...",
              //     showIcon: true),
              // const SizedBox(height: 20),
              // const SectionTitle(title: "Recently Played"),
              // const SizedBox(height: 10),
              // SizedBox(
              //   height: 100,
              //   child: ListView.builder(
              //     scrollDirection: Axis.horizontal,
              //     itemCount: recentlyPlayed.length,
              //     itemBuilder: (context, index) {
              //       return RecentlyPlayedItem(song: recentlyPlayed[index]);
              //     },
              //   ),
              // ),
              const SizedBox(height: 20),
              const SectionTitle(title: "Music By Genre"),
              const SizedBox(height: 20),
              // Wrap(
              //   spacing: 15, // Space between buttons horizontally
              //   runSpacing: 10, // Space between rows
              //   children: [
              //     for (int i = 0; i < genres.length; i += 2)
              //       Row(
              //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //         children: [
              //           Expanded(child: GenreButton(label: genres[i])),
              //           if (i + 1 < genres.length) // Ensure second item exists
              //             const SizedBox(width: 15), // Space between two buttons
              //           if (i + 1 < genres.length)
              //             Expanded(child: GenreButton(label: genres[i + 1])),
              //         ],
              //       ),
              //   ],
              // ),
              FutureBuilder<List<Category>>(
                future: controller.fetchMusicCategory(),
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
                    return SizedBox(
                      height: 200,
                      child: GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 10,
                        childAspectRatio: 2.8,
                        children: types.map((type) {
                          return InkWell(
                            onTap: () {
                              Get.to(
                                BinauralSongsScreen(
                                  typeId: type.id,
                                  typeName: type.name,
                                ),
                              );
                            },
                            child: GenreButton(
                              label: type.name,
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  } else {
                    return const Center(
                        child: Text('No Music types available'));
                  }
                },
              ),
              // Add bottom padding to prevent content from being hidden behind audio player
              const SizedBox(height: 120), // Space for audio player
            ],
          ),
        ),
      ),
      ),
    );
  }
}
