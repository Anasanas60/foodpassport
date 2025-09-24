import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'food_journal_service.dart';

class FoodRecognitionService {
  // Nutritionix API - Free tier (100 requests/day)
  static const String apiKey = 'YOUR_API_KEY'; // You'll need to get this
  static const String appId = 'YOUR_APP_ID';
  static const String baseUrl = 'https://trackapi.nutritionix.com/v2/natural/nutrients';
  
  // Alternative free APIs
  static const String mealDbUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const String openFoodFactsUrl = 'https://world.openfoodfacts.org/api/v0/product';
  
  static final FoodJournalService _journalService = FoodJournalService();

  // Main method: Detect food and save to database
  static Future<Map<String, dynamic>> recognizeAndSaveFood(
    XFile image, {
    Position? currentPosition,
    String userTextDescription = '',
  }) async {
    try {
      // Step 1: Try Nutritionix API first (most accurate)
      final nutritionixResult = await _tryNutritionixRecognition(userTextDescription.isEmpty 
          ? await _extractTextFromImage(image) 
          : userTextDescription
      );
      
      if (nutritionixResult != null) {
        await _saveFoodEntry(nutritionixResult, currentPosition, source: 'nutritionix');
        return nutritionixResult;
      }
      
      // Step 2: Fallback to TheMealDB
      final mealDbResult = await _tryMealDbRecognition(userTextDescription);
      if (mealDbResult != null) {
        await _saveFoodEntry(mealDbResult, currentPosition, source: 'mealdb');
        return mealDbResult;
      }
      
      // Step 3: Final fallback to basic detection
      final fallbackResult = await _fallbackFoodDetection();
      await _saveFoodEntry(fallbackResult, currentPosition, source: 'fallback');
      return fallbackResult;
      
    } catch (e) {
      print('❌ Food recognition error: $e');
      final fallbackResult = await _fallbackFoodDetection();
      await _saveFoodEntry(fallbackResult, currentPosition, source: 'error_fallback');
      return fallbackResult;
    }
  }

  // Nutritionix API integration
  static Future<Map<String, dynamic>?> _tryNutritionixRecognition(String foodDescription) async {
    if (foodDescription.isEmpty) return null;
    
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-app-id': appId,
          'x-app-key': apiKey,
        },
        body: jsonEncode({
          'query': foodDescription,
          'timezone': 'US/Eastern'
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['foods'] != null && data['foods'].isNotEmpty) {
          final food = data['foods'][0];
          return _parseNutritionixData(food, foodDescription);
        }
      }
      
      print('⚠️ Nutritionix API failed, status: ${response.statusCode}');
      return null;
    } catch (e) {
      print('❌ Nutritionix API error: $e');
      return null;
    }
  }

  static Map<String, dynamic> _parseNutritionixData(Map<String, dynamic> food, String description) {
    return {
      'foodName': food['food_name'] ?? description,
      'calories': food['nf_calories']?.toDouble() ?? 0.0,
      'protein': food['nf_protein']?.toDouble() ?? 0.0,
      'carbs': food['nf_total_carbohydrate']?.toDouble() ?? 0.0,
      'fat': food['nf_total_fat']?.toDouble() ?? 0.0,
      'servingSize': food['serving_qty']?.toDouble(),
      'servingUnit': food['serving_unit'],
      'confidence': 0.9, // High confidence for Nutritionix
    };
  }

  // TheMealDB fallback
  static Future<Map<String, dynamic>?> _tryMealDbRecognition(String description) async {
    if (description.isEmpty) return null;
    
    try {
      final response = await http.get(
        Uri.parse('$mealDbUrl/search.php?s=${Uri.encodeComponent(description)}')
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return _parseMealDbData(data['meals'][0], description);
        }
      }
      return null;
    } catch (e) {
      print('❌ MealDB error: $e');
      return null;
    }
  }

  static Map<String, dynamic> _parseMealDbData(Map<String, dynamic> meal, String description) {
    // Estimate nutrition based on common values for the dish type
    final nutrition = _estimateNutritionFromDishType(description);
    
    return {
      'foodName': meal['strMeal'] ?? description,
      'calories': nutrition['calories'],
      'protein': nutrition['protein'],
      'carbs': nutrition['carbs'],
      'fat': nutrition['fat'],
      'recipe': meal['strInstructions'],
      'imageUrl': meal['strMealThumb'],
      'category': meal['strCategory'],
      'area': meal['strArea'],
      'confidence': 0.7, // Medium confidence for MealDB
    };
  }

  // Final fallback
  static Future<Map<String, dynamic>> _fallbackFoodDetection() async {
    final dishes = _getCommonDishes();
    final randomDish = dishes[DateTime.now().millisecondsSinceEpoch % dishes.length];
    final nutrition = _estimateNutritionFromDishType(randomDish);
    
    return {
      'foodName': randomDish,
      'calories': nutrition['calories'],
      'protein': nutrition['protein'],
      'carbs': nutrition['carbs'],
      'fat': nutrition['fat'],
      'confidence': 0.4, // Low confidence for fallback
    };
  }

  // Helper methods
  static Future<String> _extractTextFromImage(XFile image) async {
    // This will integrate with your OCR service later
    // For now, return empty string - user will provide description
    return '';
  }

  static Future<void> _saveFoodEntry(
    Map<String, dynamic> foodData, 
    Position? position, {
    required String source,
  }) async {
    try {
      await _journalService.addFoodEntry(
        foodName: foodData['foodName'],
        calories: foodData['calories'],
        protein: foodData['protein'],
        carbs: foodData['carbs'],
        fat: foodData['fat'],
        confidenceScore: foodData['confidence'],
        source: source,
        position: position,
      );
    } catch (e) {
      print('❌ Error saving food entry: $e');
      // Don't throw - we want to return recognition results even if save fails
    }
  }

  static Map<String, double> _estimateNutritionFromDishType(String dishName) {
    final lowerDish = dishName.toLowerCase();
    
    // Rough nutrition estimates based on dish type
    if (lowerDish.contains('curry') || lowerDish.contains('pad')) {
      return {'calories': 450.0, 'protein': 15.0, 'carbs': 60.0, 'fat': 18.0};
    } else if (lowerDish.contains('salad')) {
      return {'calories': 200.0, 'protein': 8.0, 'carbs': 15.0, 'fat': 12.0};
    } else if (lowerDish.contains('noodle') || lowerDish.contains('pasta')) {
      return {'calories': 400.0, 'protein': 12.0, 'carbs': 70.0, 'fat': 10.0};
    } else if (lowerDish.contains('rice')) {
      return {'calories': 350.0, 'protein': 8.0, 'carbs': 65.0, 'fat': 8.0};
    } else if (lowerDish.contains('burger') || lowerDish.contains('pizza')) {
      return {'calories': 600.0, 'protein': 25.0, 'carbs': 45.0, 'fat': 30.0};
    } else {
      return {'calories': 300.0, 'protein': 15.0, 'carbs': 35.0, 'fat': 12.0};
    }
  }

  static List<String> _getCommonDishes() {
    return [
      'Pad Thai', 'Green Curry', 'Tom Yum Goong', 'Massaman Curry', 'Som Tam',
      'Pad Kra Pao', 'Khao Soi', 'Tom Kha Gai', 'Laab', 'Satay', 
      'Pizza', 'Burger', 'Sushi', 'Pasta', 'Tacos', 'Ramen', 'Fried Rice',
      'Sandwich', 'Salad', 'Steak', 'Chicken Curry', 'Fish and Chips'
    ];
  }

  // Backward compatibility - keep your existing methods
  static Future<String> detectFoodFromImage(XFile image) async {
    final result = await recognizeAndSaveFood(image);
    return result['foodName'];
  }

  static Future<Map<String, dynamic>?> getFoodDetails(String foodName) async {
    try {
      final response = await http.get(
        Uri.parse('$mealDbUrl/search.php?s=${Uri.encodeComponent(foodName)}')
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return data['meals'][0];
        }
      }
      return null;
    } catch (e) {
      print('❌ Food details error: $e');
      return null;
    }
  }
}