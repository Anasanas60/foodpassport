import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AdvancedFoodRecognition {
  // Multi-API configuration
  static const String mealDbUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const String openFoodFactsUrl = 'https://world.openfoodfacts.org/api/v0/product';
  
  // Location-based dish databases (Bangkok-focused)
  static final Map<String, List<String>> regionalDishes = {
    'thailand': [
      'Pad Thai', 'Green Curry', 'Tom Yum Goong', 'Massaman Curry', 'Som Tam',
      'Pad Kra Pao', 'Khao Soi', 'Tom Kha Gai', 'Laab', 'Satay', 'Mango Sticky Rice',
      'Panang Curry', 'Yellow Curry', 'Pad See Ew', 'Drunken Noodles', 'Spring Rolls'
    ],
    'international': [
      'Pizza', 'Burger', 'Sushi', 'Pasta', 'Tacos', 'Ramen', 'Fried Rice',
      'Noodles', 'Sandwich', 'Salad', 'Steak', 'Chicken Curry', 'Fish and Chips',
      'Dim Sum', 'Pho', 'Bibimbap', 'Paella', 'Tacos', 'Burrito'
    ]
  };

  // Detect food using multi-source approach
  static Future<Map<String, dynamic>> detectFood(XFile image, {String userLocation = 'Bangkok'}) async {
    try {
      // Step 1: Try OCR text extraction from image (if it's a menu)
      final String? extractedText = await _extractTextFromImage(image);
      
      // Step 2: Analyze text for dish names
      final List<String> possibleDishes = _analyzeTextForDishes(extractedText, userLocation);
      
      // Step 3: Get detailed information for top candidate
      final String topDish = possibleDishes.isNotEmpty ? possibleDishes.first : _getRandomDish(userLocation);
      
      // Step 4: Fetch comprehensive data from multiple APIs
      final Map<String, dynamic> dishData = await _getComprehensiveDishData(topDish);
      
      return {
        'dishName': topDish,
        'confidence': _calculateConfidence(extractedText, possibleDishes),
        'data': dishData,
        'ingredients': dishData['ingredients'] ?? [],
        'allergens': dishData['allergens'] ?? [],
        'recipe': dishData['recipe'] ?? '',
        'imageUrl': dishData['imageUrl'],
        'origin': dishData['origin'] ?? 'Unknown',
      };
    } catch (e) {
      ('Advanced food recognition error: $e');
      return _getFallbackData(userLocation);
    }
  }

  // Text extraction and analysis
  static Future<String?> _extractTextFromImage(XFile image) async {
    // For now, return null - we'll integrate OCR here later
    // This will use your existing OCR service
    return null;
  }

  static List<String> _analyzeTextForDishes(String? text, String location) {
    if (text == null || text.isEmpty) {
      return _getLocationBasedDishes(location);
    }
    
    final List<String> foundDishes = [];
    final allDishes = [...regionalDishes['thailand']!, ...regionalDishes['international']!];
    
    for (final dish in allDishes) {
      if (text.toLowerCase().contains(dish.toLowerCase())) {
        foundDishes.add(dish);
      }
    }
    
    return foundDishes.isNotEmpty ? foundDishes : _getLocationBasedDishes(location);
  }

  static List<String> _getLocationBasedDishes(String location) {
    if (location.toLowerCase().contains('bangkok') || location.toLowerCase().contains('thai')) {
      return regionalDishes['thailand']!;
    }
    return regionalDishes['international']!;
  }

  static String _getRandomDish(String location) {
    final dishes = _getLocationBasedDishes(location);
    return dishes[DateTime.now().millisecondsSinceEpoch % dishes.length];
  }

  // Multi-API data fetching
  static Future<Map<String, dynamic>> _getComprehensiveDishData(String dishName) async {
    try {
      // Try TheMealDB first
      final mealDbData = await _fetchFromMealDB(dishName);
      if (mealDbData != null) {
        return mealDbData;
      }
      
      // Fallback to OpenFoodFacts
      final openFoodData = await _fetchFromOpenFoodFacts(dishName);
      if (openFoodData != null) {
        return openFoodData;
      }
      
      return _createBasicDishData(dishName);
    } catch (e) {
      return _createBasicDishData(dishName);
    }
  }

  static Future<Map<String, dynamic>?> _fetchFromMealDB(String dishName) async {
    try {
      final response = await http.get(Uri.parse('$mealDbUrl/search.php?s=${Uri.encodeComponent(dishName)}'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          final meal = data['meals'][0];
          
          // Extract ingredients
          final ingredients = <String>[];
          for (int i = 1; i <= 20; i++) {
            final ingredient = meal['strIngredient$i'];
            final measure = meal['strMeasure$i'];
            if (ingredient != null && ingredient.isNotEmpty) {
              ingredients.add('$measure $ingredient'.trim());
            }
          }
          
          return {
            'ingredients': ingredients,
            'recipe': meal['strInstructions'] ?? 'Recipe not available.',
            'imageUrl': meal['strMealThumb'],
            'origin': meal['strArea'] ?? 'Unknown',
            'category': meal['strCategory'] ?? 'Unknown',
            'allergens': _detectAllergensFromIngredients(ingredients),
          };
        }
      }
    } catch (e) {
      ('MealDB fetch error: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> _fetchFromOpenFoodFacts(String dishName) async {
    try {
      final response = await http.get(Uri.parse('https://world.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(dishName)}&json=1'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['products'] != null && data['products'].isNotEmpty) {
          final product = data['products'][0];
          return {
            'ingredients': _parseOpenFoodFactsIngredients(product['ingredients_text'] ?? ''),
            'allergens': _parseOpenFoodFactsAllergens(product['allergens'] ?? ''),
            'imageUrl': product['image_url'],
            'origin': product['countries'] ?? 'Unknown',
          };
        }
      }
    } catch (e) {
      ('OpenFoodFacts fetch error: $e');
    }
    return null;
  }

  static List<String> _parseOpenFoodFactsIngredients(String ingredientsText) {
    return ingredientsText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  static List<String> _parseOpenFoodFactsAllergens(String allergensText) {
    return allergensText.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  static List<String> _detectAllergensFromIngredients(List<String> ingredients) {
    final allergenKeywords = [
      'peanut', 'nut', 'almond', 'walnut', 'cashew', 'hazelnut',
      'milk', 'cheese', 'dairy', 'butter', 'cream', 'yogurt',
      'wheat', 'gluten', 'barley', 'rye', 'bread', 'pasta',
      'egg', 'eggs', 'fish', 'shellfish', 'shrimp', 'prawn', 
      'crab', 'lobster', 'soy', 'soya', 'tofu', 'sesame', 'mustard'
    ];

    final foundAllergens = <String>[];
    for (final ingredient in ingredients) {
      for (final allergen in allergenKeywords) {
        if (ingredient.toLowerCase().contains(allergen)) {
          if (!foundAllergens.contains(allergen)) {
            foundAllergens.add(allergen);
          }
        }
      }
    }
    return foundAllergens;
  }

  static Map<String, dynamic> _createBasicDishData(String dishName) {
    // Fallback data for unknown dishes
    return {
      'dishName': dishName,
      'ingredients': ['Unknown ingredients'],
      'allergens': ['Unknown allergens - check manually'],
      'recipe': 'Recipe information not available for this dish.',
      'imageUrl': null,
      'origin': 'Unknown',
      'confidence': 0.3,
    };
  }

  static double _calculateConfidence(String? text, List<String> foundDishes) {
    if (text != null && foundDishes.isNotEmpty) {
      return 0.9; // High confidence if text analysis found dishes
    }
    if (foundDishes.isNotEmpty) {
      return 0.7; // Medium confidence for location-based prediction
    }
    return 0.3; // Low confidence for random fallback
  }

  static Map<String, dynamic> _getFallbackData(String location) {
    final randomDish = _getRandomDish(location);
    return _createBasicDishData(randomDish);
  }
}