import 'dart:convert';
import 'package:elevate/Model/music_item.dart';
import '../utlis/api_constants.dart';
import 'package:http/http.dart' as http;

class BinauralController {
  Future<List<Category>> fetchBinauralCategory() async {
    final response =
        await http.get(Uri.parse('${ApiConstants.apiUrl}/categories'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      final binaural = data.firstWhere(
        (cat) => cat['name'] == 'Binaural',
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
