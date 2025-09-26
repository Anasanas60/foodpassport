import 'package:image_picker/image_picker.dart';
import '../models/food_item.dart';
import 'food_journal_service.dart';

class FoodRecognitionService {
  static const String apiKey = '1c7ff5c00fbfe73f21235865e5cf6d16';
  static const String appId = 'e9ec091f';
  static const String baseUrl = 'https://trackapi.nutritionix.com/v2/natural/nutrients';
  static const String mealDbUrl = 'https://www.themealdb.com/api/json/v1/1';
  // _journalService removed for now

  static Future<FoodItem> recognizeAndAnalyzeFood(XFile image, {List<String> userAllergies = const []}) async {
    return FoodItem.fromRecognitionMap(
      await _fallbackFoodDetection('Detected Food'),
      imagePath: image.path,
      position: null,
    );
  }

  static bool hasAllergyEmergency(FoodItem foodItem, List<String> userAllergies) {
    return foodItem.detectedAllergens.any((allergen) => userAllergies.contains(allergen));
  }

  static Future<Map<String, dynamic>> recognizeAndSaveFood(XFile image) async {
    final foodItem = await recognizeAndAnalyzeFood(image);
    return foodItem.toMap();
  }

  

  static Future<Map<String, dynamic>> _fallbackFoodDetection([String description = '']) async {
    final dishes = ['Pad Thai', 'Pizza', 'Burger', 'Sushi', 'Salad'];
    final randomDish = dishes[DateTime.now().millisecondsSinceEpoch % dishes.length];
    
    return {
      'foodName': randomDish,
      'calories': 300.0,
      'protein': 15.0,
      'carbs': 35.0,
      'fat': 12.0,
      'confidence': 0.4,
      'source': 'fallback',
    };
  }
}



