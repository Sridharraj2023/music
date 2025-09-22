import 'package:elevate/Model/music_item.dart';
import '../Model/Song.dart';
import '../utlis/api_constants.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MusicController {
  List<Song> getRecentlyPlayed() {
    return [
      Song(title: "Sail", artist: "Awolnation"),
      Song(title: "BOOM", artist: "X Ambassadors"),
      Song(title: "Hunger", artist: "TheFatRat"),
      Song(title: "Sacred Ri", artist: "Blackmill"),
    ];
  }

  List<String> getGenres() {
    return ["Rock", "EDM", "Pop", "Country"];
  }

  Future<List<Category>> fetchMusicCategory() async {
    final response =
        await http.get(Uri.parse('${ApiConstants.apiUrl}/categories'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final binaural = data.firstWhere(
        (cat) => cat['name'] == 'Music',
        orElse: () => null,
      );

      if (binaural != null && binaural['types'] != null) {
        final typesList = binaural['types'] as List<dynamic>;
        return typesList
            .map((typeJson) => Category.fromJson(typeJson))
            .toList();
      } else {
        return [];
      }
    } else {
      throw Exception('Failed to fetch binaural types');
    }
  }
}
