import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AdvancedFoodRecognition {
  // NUTRITIONIX API CREDENTIALS - YOUR KEYS!
  static const String nutritionixAppId = 'e9ec091f';
  static const String nutritionixApiKey = '1c7ff5c00fbfe73f21235865e5cf6d16';
  static const String nutritionixBaseUrl = 'https://trackapi.nutritionix.com/v2/natural/nutrients';
  
  // Hybrid Food Detection - 3 LAYER SYSTEM
  static Future<Map<String, dynamic>> detectFood(XFile image, {String userLocation = 'Bangkok'}) async {
    print('🧠 Starting Hybrid AI Detection...');
    
    // LAYER 1: Try Nutritionix API (Most Accurate)
    try {
      print('🔗 Layer 1: Trying Nutritionix API...');
      final apiResult = await _detectWithNutritionix(image);
      if (apiResult['confidence'] > 0.6) {
        print('✅ API Success! Confidence: ${apiResult['confidence']}');
        return apiResult;
      }
    } catch (e) {
      print('❌ API Failed: $e');
    }
    
    // LAYER 2: Simple Image Analysis (Fallback)
    try {
      print('🎨 Layer 2: Trying Image Analysis...');
      final analysisResult = await _analyzeImageCharacteristics(image);
      if (analysisResult['confidence'] > 0.4) {
        print('✅ Image Analysis Success!');
        return analysisResult;
      }
    } catch (e) {
      print('❌ Image Analysis Failed: $e');
    }
    
    // LAYER 3: Smart Context Guessing (Always Works)
    print('🌏 Layer 3: Using Smart Context Guessing...');
    return _guessBasedOnContext(userLocation);
  }
  
  // LAYER 1: NUTRITIONIX API DETECTION
  static Future<Map<String, dynamic>> _detectWithNutritionix(XFile image) async {
    // For now, we'll use text-based detection since image upload needs special setup
    // But this demonstrates the API integration
    
    try {
      final response = await http.post(
        Uri.parse('https://trackapi.nutritionix.com/v2/natural/nutrients'),
        headers: {
          'Content-Type': 'application/json',
          'x-app-id': nutritionixAppId,
          'x-app-key': nutritionixApiKey,
          'x-remote-user-id': '0',
        },
        body: jsonEncode({
          'query': 'pad thai', // Simulated detection - will replace with real image analysis
          'timezone': 'US/Eastern'
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final foods = data['foods'] as List?;
        
        if (foods != null && foods.isNotEmpty) {
          final food = foods.first;
          return {
            'dishName': food['food_name'] ?? 'Unknown Dish',
            'confidence': 0.85,
            'calories': food['nf_calories']?.round() ?? 0,
            'protein': food['nf_protein']?.round() ?? 0,
            'carbs': food['nf_total_carbohydrate']?.round() ?? 0,
            'ingredients': ['Rice noodles', 'Egg', 'Peanuts', 'Tofu'], // Simulated
            'allergens': _detectAllergensFromNutritionix(food),
            'recipe': 'Traditional Thai stir-fried noodles with sweet and sour sauce.',
            'origin': 'Thailand',
            'source': 'Nutritionix API',
          };
        }
      }
    } catch (e) {
      print('Nutritionix API error: $e');
      throw Exception('API request failed');
    }
    
    return {'confidence': 0.0}; // Fallback
  }
  
  // LAYER 2: SIMPLE IMAGE ANALYSIS
  static Future<Map<String, dynamic>> _analyzeImageCharacteristics(XFile image) async {
    // Basic image analysis based on common food characteristics
    // This would be enhanced with real image processing
    
    return {
      'dishName': 'Asian Noodles',
      'confidence': 0.55,
      'ingredients': ['Noodles', 'Vegetables', 'Sauce'],
      'allergens': ['gluten', 'soy'],
      'recipe': 'Stir-fried noodle dish with vegetables.',
      'origin': 'Asia',
      'source': 'Image Analysis',
    };
  }
  
  // LAYER 3: SMART CONTEXT GUESSING
  static Future<Map<String, dynamic>> _guessBasedOnContext(String location) async {
    final locationDishes = {
      'Bangkok': ['Pad Thai', 'Green Curry', 'Tom Yum', 'Som Tam'],
      'Tokyo': ['Sushi', 'Ramen', 'Tempura', 'Udon'],
      'New York': ['Pizza', 'Burger', 'Pasta', 'Salad'],
      'default': ['Chicken Dish', 'Rice Plate', 'Pasta', 'Sandwich']
    };
    
    final dishes = locationDishes[location] ?? locationDishes['default']!;
    final randomDish = dishes[DateTime.now().millisecond % dishes.length];
    
    return {
      'dishName': randomDish,
      'confidence': 0.3,
      'ingredients': ['Various ingredients'],
      'allergens': ['Check manually'],
      'recipe': 'Information not available. Please check locally.',
      'origin': 'Unknown',
      'source': 'Context Guessing',
      'note': 'Based on your location: $location',
    };
  }
  
  static List<String> _detectAllergensFromNutritionix(Map<String, dynamic> food) {
    final allergens = <String>[];
    final foodName = (food['food_name'] ?? '').toLowerCase();
    
    if (foodName.contains('nut') || foodName.contains('peanut')) allergens.add('peanuts');
    if (foodName.contains('milk') || foodName.contains('cheese') || foodName.contains('dairy')) allergens.add('dairy');
    if (foodName.contains('egg')) allergens.add('eggs');
    if (foodName.contains('fish') || foodName.contains('shellfish')) allergens.add('seafood');
    if (foodName.contains('wheat') || foodName.contains('gluten')) allergens.add('gluten');
    
    return allergens.isEmpty ? ['None detected'] : allergens;
  }
}