import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../config/nutritionix_config.dart';
import '../utils/logger.dart';

class NutritionixService {
  Future<Map<String, dynamic>> searchFood(String query) async {
    if (NutritionixConfig.appId.isEmpty || NutritionixConfig.appKey.isEmpty) {
      logger.severe('Nutritionix App ID or Key is not set in .env file.');
      throw Exception('API credentials not configured.');
    }

    final uri = Uri.parse(NutritionixConfig.baseUrl);
    final headers = {
      'x-app-id': NutritionixConfig.appId,
      'x-app-key': NutritionixConfig.appKey,
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({'query': query});

    try {
      final response = await http.post(
        uri,
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        try {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          logger.severe('JSON parsing error for Nutritionix response: $e');
          throw Exception('Invalid response format from Nutritionix.');
        }
      } else {
        logger.severe('Nutritionix API call failed with status code: ${response.statusCode}, body: ${response.body}');
        throw Exception('Failed to fetch data from Nutritionix (Status: ${response.statusCode}).');
      }
    } on SocketException {
      logger.severe('Network error: No internet connection for Nutritionix call.');
      throw Exception('Network connection error.');
    } on TimeoutException {
      logger.severe('Network error: Nutritionix request timed out.');
      throw Exception('Request timed out.');
    } catch (e) {
      logger.severe('An unexpected error occurred in NutritionixService: $e');
      throw Exception('An unexpected error occurred.');
    }
  }
}