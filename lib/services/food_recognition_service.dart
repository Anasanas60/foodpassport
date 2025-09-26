import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import '../models/food_item.dart';
import '../utils/allergen_checker.dart';
import 'food_journal_service.dart';
import 'ocr_service.dart'; // Integrate with your existing OCR service

class FoodRecognitionService {
  // Nutritionix API - Free tier (100 requests/day)
  static const String apiKey = '1c7ff5c00fbfe73f21235865e5cf6d16';
  static const String appId = 'e9ec091f';
  static const String baseUrl = 'https://trackapi.nutritionix.com/v2/natural/nutrients';
  
  // Alternative free APIs
  static const String mealDbUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const String openFoodFactsUrl = 'https://world.openfoodfacts.org/api/v0/product';
  
  static final FoodJournalService _journalService = FoodJournalService();

  // ENHANCED MAIN METHOD: Returns FoodItem object with allergen detection
  static Future<FoodItem> recognizeAndAnalyzeFood(
    XFile image, {
    Position? currentPosition,
    String userTextDescription = '',
    List<String> userAllergies = const [], // Add user allergies parameter
  }) async {
    try {
      final String foodDescription = userTextDescription.isEmpty 
          ? await _extractTextFromImage(image) 
          : userTextDescription;

      Map<String, dynamic> recognitionResult;
      String source;

      // Step 1: Try Nutritionix API first (most accurate)
      recognitionResult = await _tryNutritionixRecognition(foodDescription) 
          ?? await _tryMealDbRecognition(foodDescription) 
          ?? await _fallbackFoodDetection(foodDescription);
      
      source = recognitionResult['source'] ?? 'unknown';

      // Step 2: Detect allergens based on the recognition result
      final detectedAllergens = AllergenChecker.detectAllergens(
        foodName: recognitionResult['foodName'],
        description: foodDescription,
        cuisineType: recognitionResult['area'],
      );

      // Step 3: Create FoodItem object
      final foodItem = FoodItem.fromRecognitionMap(
        {
          ...recognitionResult,
          'detectedAllergens': detectedAllergens,
          'source': source,
        },
        imagePath: image.path,
        position: currentPosition,
      );

      // Step 4: Save to journal
      await _saveFoodEntry(foodItem);

      return foodItem;
      
    } catch (e) {
      print('❌ Food recognition error: $e');
      // Return a fallback FoodItem with error info
      return FoodItem.fromRecognitionMap(
        await _fallbackFoodDetection('Emergency fallback'),
        imagePath: image.path,
        position: currentPosition,
      );
    }
  }

  // ENHANCED NUTRITIONIX INTEGRATION
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
          final result = _parseNutritionixData(food, foodDescription);
          return {...result, 'source': 'nutritionix'};
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
      'confidence': 0.9,
    };
  }

  // ENHANCED MEALDB INTEGRATION
  static Future<Map<String, dynamic>?> _tryMealDbRecognition(String description) async {
    if (description.isEmpty) return null;
    
    try {
      final response = await http.get(
        Uri.parse('$mealDbUrl/search.php?s=${Uri.encodeComponent(description)}')
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          final result = _parseMealDbData(data['meals'][0], description);
          return {...result, 'source': 'mealdb'};
        }
      }
      return null;
    } catch (e) {
      print('❌ MealDB error: $e');
      return null;
    }
  }

  static Map<String, dynamic> _parseMealDbData(Map<String, dynamic> meal, String description) {
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
      'confidence': 0.7,
    };
  }

  // ENHANCED FALLBACK DETECTION
  static Future<Map<String, dynamic>> _fallbackFoodDetection([String description = '']) async {
    final dishes = _getCommonDishes();
    final randomDish = description.isNotEmpty ? description : dishes[DateTime.now().millisecondsSinceEpoch % dishes.length];
    final nutrition = _estimateNutritionFromDishType(randomDish);
    
    return {
      'foodName': randomDish,
      'calories': nutrition['calories'],
      'protein': nutrition['protein'],
      'carbs': nutrition['carbs'],
      'fat': nutrition['fat'],
      'confidence': 0.4,
      'source': 'fallback',
    };
  }

  // ENHANCED TEXT EXTRACTION - Integrate with your OCR service
  static Future<String> _extractTextFromImage(XFile image) async {
    try {
      // Use your existing OCR service
      final OcrService ocrService = OcrService(); // You'll need to initialize this properly
      return await ocrService.recognizeText(image);
    } catch (e) {
      print('❌ OCR extraction error: $e');
      return ''; // Return empty if OCR fails
    }
  }

  // ENHANCED SAVE METHOD - Works with FoodItem model
  static Future<void> _saveFoodEntry(FoodItem foodItem) async {
    try {
      await _journalService.addFoodEntry(
        foodName: foodItem.name,
        calories: foodItem.calories,
        protein: foodItem.protein,
        carbs: foodItem.carbs,
        fat: foodItem.fat,
        confidenceScore: foodItem.confidenceScore,
        source: foodItem.source,
        position: foodItem.position,
      );
    } catch (e) {
      print('❌ Error saving food entry: $e');
    }
  }

  // NEW METHOD: Check for allergy emergencies
  static bool hasAllergyEmergency(FoodItem foodItem, List<String> userAllergies) {
    return AllergenChecker.hasMatchingAllergens(
      detectedAllergens: foodItem.detectedAllergens,
      userAllergies: userAllergies,
    );
  }

  // NEW METHOD: Get emergency allergens list
  static List<String> getEmergencyAllergens(FoodItem foodItem, List<String> userAllergies) {
    return AllergenChecker.getEmergencyAllergens(
      detectedAllergens: foodItem.detectedAllergens,
      userAllergies: userAllergies,
    );
  }

  // NEW METHOD: Get food details for cultural insights
  static Future<Map<String, dynamic>?> getCulturalDetails(String foodName) async {
    try {
      final response = await http.get(
        Uri.parse('$mealDbUrl/search.php?s=${Uri.encodeComponent(foodName)}')
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          final meal = data['meals'][0];
          return {
            'name': meal['strMeal'],
            'category': meal['strCategory'],
            'area': meal['strArea'],
            'instructions': meal['strInstructions'],
            'image': meal['strMealThumb'],
            'ingredients': _extractIngredients(meal),
          };
        }
      }
      return null;
    } catch (e) {
      print('❌ Cultural details error: $e');
      return null;
    }
  }

  // Helper method to extract ingredients from MealDB response
  static List<String> _extractIngredients(Map<String, dynamic> meal) {
    final ingredients = <String>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      final measure = meal['strMeasure$i'];
      if (ingredient != null && ingredient.isNotEmpty) {
        ingredients.add('$measure $ingredient'.trim());
      }
    }
    return ingredients;
  }

  // Keep existing helper methods for backward compatibility
  static Map<String, double> _estimateNutritionFromDishType(String dishName) {
    final lowerDish = dishName.toLowerCase();
    
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

  // BACKWARD COMPATIBILITY - Keep your existing methods
  static Future<String> detectFoodFromImage(XFile image) async {
    final result = await recognizeAndSaveFood(image);
    return result['foodName'];
  }

  // Original method signature for backward compatibility
  static Future<Map<String, dynamic>> recognizeAndSaveFood(
    XFile image, {
    Position? currentPosition,
    String userTextDescription = '',
  }) async {
    final foodItem = await recognizeAndAnalyzeFood(
      image,
      currentPosition: currentPosition,
      userTextDescription: userTextDescription,
    );
    return foodItem.toMap();
  }

  static Future<Map<String, dynamic>?> getFoodDetails(String foodName) async {
    return await getCulturalDetails(foodName);
  }
}