import 'package:flutter_dotenv/flutter_dotenv.dart';

class NutritionixConfig {
  static String get appId {
    return dotenv.env['NUTRITIONIX_APP_ID'] ?? '';
  }

  static String get appKey {
    return dotenv.env['NUTRITIONIX_APP_KEY'] ?? '';
  }

  // Optionally add base URL or other constants if needed
  static const String baseUrl = 'https://trackapi.nutritionix.com/v2/natural/nutrients';
}