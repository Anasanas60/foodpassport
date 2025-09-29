import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/nutritionix_config.dart';

class NutritionixService {
  final String _appId = NutritionixConfig.appId;
  final String _appKey = NutritionixConfig.appKey;
  final String _baseUrl = NutritionixConfig.baseUrl;

  Future<Map<String, dynamic>> searchFood(String query) async {
    final url = Uri.parse(_baseUrl);
    final response = await http.post(
      url,
      headers: {
        'x-app-id': _appId,
        'x-app-key': _appKey,
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'query': query}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Nutritionix API call failed: ${response.statusCode}');
    }
  }
}
