import 'dart:convert';
import 'package:http/http.dart' as http;

class FoodApiService {
  // FREE APIs - No API keys needed
  static const String mealDbBaseUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const String openFoodFactsUrl = 'https://world.openfoodfacts.org/api/v0/product';
  
  // Search for food/dish by name (using TheMealDB)
  static Future<Map<String, dynamic>?> searchDish(String dishName) async {
    try {
      final response = await http.get(
        Uri.parse('$mealDbBaseUrl/search.php?s=${Uri.encodeComponent(dishName)}')
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return data['meals'][0]; // Return first matching dish
        }
      }
      return null;
    } catch (e) {
      ('Dish search error: $e');
      return null;
    }
  }

  // Get recipe instructions
  static Future<String?> getRecipe(String dishName) async {
    try {
      final dishData = await searchDish(dishName);
      if (dishData != null) {
        return dishData['strInstructions'] ?? 'No recipe available.';
      }
      return null;
    } catch (e) {
      ('Recipe fetch error: $e');
      return null;
    }
  }

  // Get ingredients list
  static Future<List<String>> getIngredients(String dishName) async {
    try {
      final dishData = await searchDish(dishName);
      final ingredients = <String>[];
      
      if (dishData != null) {
        for (int i = 1; i <= 20; i++) {
          final ingredient = dishData['strIngredient$i'];
          final measure = dishData['strMeasure$i'];
          
          if (ingredient != null && ingredient.isNotEmpty) {
            ingredients.add('$measure $ingredient'.trim());
          }
        }
      }
      return ingredients;
    } catch (e) {
     ('Ingredients fetch error: $e');
      return [];
    }
  }

  // Get dish image URL
  static Future<String?> getDishImage(String dishName) async {
    try {
      final dishData = await searchDish(dishName);
      return dishData?['strMealThumb'];
    } catch (e) {
      ('Image fetch error: $e');
      return null;
    }
  }

  // Check for common allergens in ingredients
  static Future<List<String>> checkAllergens(List<String> ingredients) async {
    final allergenKeywords = [
      'peanut', 'nut', 'almond', 'walnut', 'cashew', 'hazelnut',
      'milk', 'cheese', 'dairy', 'butter', 'cream', 'yogurt',
      'wheat', 'gluten', 'barley', 'rye', 'bread', 'pasta',
      'egg', 'eggs',
      'fish', 'shellfish', 'shrimp', 'prawn', 'crab', 'lobster',
      'soy', 'soya', 'tofu',
      'sesame', 'mustard'
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
}
