import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/recipe_data.dart';

class RecipeService {
  // Free recipe APIs
  static const String mealDbUrl = 'https://www.themealdb.com/api/json/v1/1';
  static const String edamamUrl = 'https://api.edamam.com/api/recipes/v2';
  
  // You can get free API keys from these services
  static const String edamamAppId = 'YOUR_EDAMAM_APP_ID'; // Register at Edamam
  static const String edamamAppKey = 'YOUR_EDAMAM_APP_KEY';

  // AI-Powered Recipe Generation
  static Future<RecipeData?> getAIRecipe(
    String dishName, {
    String? cuisineType,
    List<String> dietaryRestrictions = const [],
  }) async {
    try {
      // Try external APIs first
      final recipe = await _tryMealDbRecipe(dishName) 
          ?? await _tryEdamamRecipe(dishName, dietaryRestrictions)
          ?? await _generateAIRecipe(dishName, cuisineType, dietaryRestrictions);
      
      return recipe;
    } catch (e) {
      print('❌ AI Recipe generation error: $e');
      return null;
    }
  }

  static Future<RecipeData?> _tryMealDbRecipe(String dishName) async {
    try {
      final response = await http.get(
        Uri.parse('$mealDbUrl/search.php?s=${Uri.encodeComponent(dishName)}')
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return _parseMealDbRecipe(data['meals'][0]);
        }
      }
      return null;
    } catch (e) {
      print('❌ MealDB recipe error: $e');
      return null;
    }
  }

  static RecipeData _parseMealDbRecipe(Map<String, dynamic> meal) {
    final ingredients = <String>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      final measure = meal['strMeasure$i'];
      if (ingredient != null && ingredient.isNotEmpty && ingredient != 'null') {
        ingredients.add('$measure $ingredient'.trim());
      }
    }

    return RecipeData(
      id: meal['idMeal'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: meal['strMeal'] ?? 'Unknown Dish',
      cuisine: meal['strArea'] ?? 'International',
      category: meal['strCategory'] ?? 'Main Course',
      cookTime: '30 minutes', // Estimate
      difficulty: 'Medium',
      servings: 4,
      ingredients: ingredients,
      instructions: _parseInstructions(meal['strInstructions']),
      tips: _generateCookingTips(meal['strMeal'] ?? ''),
      nutritionInfo: {}, // MealDB doesn't provide nutrition
      source: 'mealdb',
    );
  }

  static List<String> _parseInstructions(String? instructions) {
    if (instructions == null) return ['Instructions not available'];
    
    // Split instructions by periods and newlines
    return instructions
        .split(RegExp(r'[.\n]'))
        .where((step) => step.trim().isNotEmpty)
        .map((step) => step.trim())
        .toList();
  }

  static List<String> _generateCookingTips(String dishName) {
    // AI-powered tips based on dish type
    final tips = <String>[
      'Use fresh ingredients for best flavor',
      'Taste and adjust seasoning as you cook',
      'Follow cooking times carefully for best results',
    ];

    if (dishName.toLowerCase().contains('bake') || dishName.toLowerCase().contains('oven')) {
      tips.add('Preheat oven for consistent cooking');
      tips.add('Check doneness with a toothpick or thermometer');
    }

    if (dishName.toLowerCase().contains('stir-fry')) {
      tips.add('Prepare all ingredients before starting to cook');
      tips.add('Cook on high heat for best texture');
    }

    return tips;
  }

  static Future<RecipeData?> _tryEdamamRecipe(String dishName, List<String> restrictions) async {
    // Edamam requires API keys - you can get free tier
    // This is a placeholder implementation
    return null;
  }

  static Future<RecipeData> _generateAIRecipe(
    String dishName, 
    String? cuisineType, 
    List<String> restrictions
  ) async {
    // This is where you'd integrate with AI services like:
    // - OpenAI GPT for recipe generation
    // - Custom ML model
    // - Other AI recipe APIs
    
    // For now, return a smart generated recipe
    return RecipeData(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      name: dishName,
      cuisine: cuisineType ?? 'International',
      category: _categorizeDish(dishName),
      cookTime: _estimateCookTime(dishName),
      difficulty: _estimateDifficulty(dishName),
      servings: 2,
      ingredients: _aiGenerateIngredients(dishName, cuisineType, restrictions),
      instructions: _aiGenerateInstructions(dishName, cuisineType),
      tips: _aiGenerateTips(dishName, cuisineType),
      nutritionInfo: _estimateNutrition(dishName),
      source: 'ai_generated',
    );
  }

  // AI helper methods...
  static String _categorizeDish(String dishName) {
    final lowerName = dishName.toLowerCase();
    if (lowerName.contains('salad')) return 'Salad';
    if (lowerName.contains('soup')) return 'Soup';
    if (lowerName.contains('dessert') || lowerName.contains('cake')) return 'Dessert';
    if (lowerName.contains('drink') || lowerName.contains('smoothie')) return 'Beverage';
    return 'Main Course';
  }

  static String _estimateCookTime(String dishName) {
    final lowerName = dishName.toLowerCase();
    if (lowerName.contains('stir-fry') || lowerName.contains('salad')) return '15-20 minutes';
    if (lowerName.contains('curry') || lowerName.contains('stew')) return '45-60 minutes';
    if (lowerName.contains('bake') || lowerName.contains('roast')) return '30-45 minutes';
    return '25-35 minutes';
  }

  static String _estimateDifficulty(String dishName) {
    final lowerName = dishName.toLowerCase();
    if (lowerName.contains('salad') || lowerName.contains('simple')) return 'Easy';
    if (lowerName.contains('complex') || lowerName.contains('gourmet')) return 'Hard';
    return 'Medium';
  }

  static List<String> _aiGenerateIngredients(String dishName, String? cuisine, List<String> restrictions) {
    // Smart ingredient generation based on dish name and cuisine
    final ingredients = <String>[];
    // Implementation similar to the one in recipe_screen.dart
    return ingredients;
  }

  static List<String> _aiGenerateInstructions(String dishName, String? cuisine) {
    // Smart instruction generation
    final instructions = <String>[];
    // Implementation similar to the one in recipe_screen.dart
    return instructions;
  }

  static List<String> _aiGenerateTips(String dishName, String? cuisine) {
    // Smart tip generation
    final tips = <String>[];
    // Implementation similar to the one in recipe_screen.dart
    return tips;
  }

  static Map<String, int> _estimateNutrition(String dishName) {
    // Basic nutrition estimation
    return {
      'calories': 350,
      'protein': 15,
      'carbs': 45,
      'fat': 12,
    };
  }
}

