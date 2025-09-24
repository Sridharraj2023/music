// import 'dart:convert';
// import 'package:elevate/utlis/api_constants.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import '../Model/music_item.dart';

// class HomeController {
//   final String baseUrl = "${ApiConstants.apiUrl}/music";

//   // Fetch music from API
//   Future<List<MusicItem>> fetchMusic() async {
//     try {
//       // Retrieve token from SharedPreferences
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString('auth_token');

//       if (token == null) {
//         throw Exception("User not authenticated. No token found.");
//       }

//       var headers = {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       };

//       final response = await http.get(Uri.parse(baseUrl), headers: headers);

//       if (response.statusCode == 200) {
//         List<dynamic> jsonResponse = jsonDecode(response.body);
//         return jsonResponse.map((data) => MusicItem.fromJson(data)).toList();
//       } else {
//         throw Exception("Failed to load music: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching music: $e");
//       return [];
//     }
//   }

//   // Fetch binaural music from API
//   Future<List<MusicItem>> fetchBinauralMusic() async {
//     try {
//       // Retrieve token from SharedPreferences
//       SharedPreferences prefs = await SharedPreferences.getInstance();
//       String? token = prefs.getString('auth_token');
//       if (token == null) {
//         throw Exception("User not authenticated. No token found.");
//       }
//       var headers = {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       };
//       final response = await http.get(Uri.parse(baseUrl), headers: headers);

//       if (response.statusCode == 200) {
//         List<dynamic> jsonResponse = jsonDecode(response.body);
//         List<MusicItem> binauralMusic = jsonResponse
//             .map((data) => MusicItem.fromJson(data))
//             .where((item) => item.category.name == "Binaural")
//             .toList();
//         return binauralMusic;
//       } else {
//         throw Exception("Failed to load music: ${response.statusCode}");
//       }
//     } catch (e) {
//       print("Error fetching binaural music: $e");
//       return [];
//     }
//   }

// }

import 'dart:convert';
import 'package:elevate/utlis/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/music_item.dart';

class HomeController {
  //final String baseUrl = "http://elevateintune.com/api/music";
  final String baseUrl = "${ApiConstants.apiUrl}/music";

  List<MusicItem>? _cachedAllMusic;
  List<MusicItem>? _cachedNonBinaural;
  List<MusicItem>? _cachedBinaural;

  // Fetch all music only once
  Future<List<MusicItem>> _fetchAllMusic() async {
    if (_cachedAllMusic != null) return _cachedAllMusic!;

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
        _cachedAllMusic =
            jsonResponse.map((data) => MusicItem.fromJson(data)).toList();
        return _cachedAllMusic!;
      } else {
        throw Exception("Failed to load music: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching music: $e");
      return [];
    }
  }

  // Only non-binaural music
  Future<List<MusicItem>> fetchMusic() async {
    if (_cachedNonBinaural != null) return _cachedNonBinaural!;
    List<MusicItem> allMusic = await _fetchAllMusic();
    _cachedNonBinaural =
        allMusic.where((item) => item.category.name != "Binaural").toList();
    return _cachedNonBinaural!;
  }

  // Only binaural music
  Future<List<MusicItem>> fetchBinauralMusic() async {
    if (_cachedBinaural != null) return _cachedBinaural!;
    List<MusicItem> allMusic = await _fetchAllMusic();
    _cachedBinaural =
        allMusic.where((item) => item.category.name == "Binaural").toList();
    return _cachedBinaural!;
  }
}
