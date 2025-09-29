import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/recipe_data.dart';
import '../utils/logger.dart';

class RecipeService {
  static Future<RecipeData> getAIRecipe(
    String dishName, {
    String? cuisineType,
    List<String> dietaryRestrictions = const [],
  }) async {
    try {
      // Try fetching from Spoonacular first
      final spoonacularRecipe = await _trySpoonacularRecipeSearch(dishName, cuisineType, dietaryRestrictions);
      if (spoonacularRecipe != null) {
        logger.info('Recipe found via Spoonacular: ${spoonacularRecipe.name}');
        return spoonacularRecipe;
      }

      // Fallback to TheMealDB
      final mealDbRecipe = await _tryMealDbRecipe(dishName);
      if (mealDbRecipe != null) {
        logger.info('Recipe found via TheMealDB: ${mealDbRecipe.name}');
        return mealDbRecipe;
      }

      // If all else fails, generate a fallback
      logger.warning('Could not find recipe online, generating fallback.');
      return _generateFallbackRecipe(dishName, cuisineType, dietaryRestrictions);
    } on SocketException {
      logger.severe('Network error: No internet connection.');
      return _generateFallbackRecipe(dishName, cuisineType, dietaryRestrictions, error: 'Network error');
    } on TimeoutException {
      logger.severe('Network error: Request timed out.');
      return _generateFallbackRecipe(dishName, cuisineType, dietaryRestrictions, error: 'Network timeout');
    } catch (e) {
      logger.severe('An unexpected error occurred in getAIRecipe: $e');
      return _generateFallbackRecipe(dishName, cuisineType, dietaryRestrictions, error: 'Unexpected error');
    }
  }

  // Spoonacular recipe search
  static Future<RecipeData?> _trySpoonacularRecipeSearch(
    String dishName,
    String? cuisineType,
    List<String> restrictions,
  ) async {
    if (!ApiConfig.isSpoonacularKeyValid) {
      logger.warning('Spoonacular API key is not valid. Skipping search.');
      return null;
    }

    final queryParameters = {
      'apiKey': ApiConfig.spoonacularApiKey,
      'query': dishName,
      'number': '1',
      'addRecipeInformation': 'true',
      'fillIngredients': 'true',
      'instructionsRequired': 'true',
      if (cuisineType != null && cuisineType.isNotEmpty) 'cuisine': cuisineType,
      if (restrictions.isNotEmpty) 'intolerances': restrictions.join(','),
    };

    try {
      final uri = Uri.https('api.spoonacular.com', '/recipes/complexSearch', queryParameters);
      final response = await http.get(uri).timeout(const Duration(seconds: ApiConfig.spoonacularRequestTimeout));

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['results'] != null && (data['results'] as List).isNotEmpty) {
            return _parseSpoonacularRecipe(data['results'][0]);
          }
        } catch (e) {
          logger.severe('JSON parsing error for Spoonacular response: $e');
          return null;
        }
      } else {
        logger.severe('Spoonacular search failed with status code: ${response.statusCode}, body: ${response.body}');
      }
      return null;
    } on SocketException {
      logger.severe('Network error: No internet connection for Spoonacular.');
      return null;
    } on TimeoutException {
      logger.severe('Timeout error: Spoonacular request timed out.');
      return null;
    } catch (e) {
      logger.severe('Unexpected error in Spoonacular search: $e');
      return null;
    }
  }

  // TheMealDB fallback
  static Future<RecipeData?> _tryMealDbRecipe(String dishName) async {
    try {
      final uri = Uri.https('www.themealdb.com', '/api/json/v1/1/search.php', {'s': dishName});
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        try {
          final data = jsonDecode(response.body);
          if (data['meals'] != null && (data['meals'] as List).isNotEmpty) {
            return _parseMealDbRecipe(data['meals'][0]);
          }
        } catch (e) {
          logger.severe('JSON parsing error for TheMealDB response: $e');
          return null;
        }
      } else {
        logger.severe('TheMealDB search failed with status code: ${response.statusCode}, body: ${response.body}');
      }
      return null;
    } on SocketException {
      logger.severe('Network error: No internet connection for TheMealDB.');
      return null;
    } on TimeoutException {
      logger.severe('Timeout error: TheMealDB request timed out.');
      return null;
    } catch (e) {
      logger.severe('Unexpected error in TheMealDB search: $e');
      return null;
    }
  }

  // Fallback recipe generation
  static Future<RecipeData> _generateFallbackRecipe(
    String dishName, 
    String? cuisineType, 
    List<String> restrictions, {
    String? error,
  }) async {
    return RecipeData(
      id: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
      name: dishName,
      cuisine: cuisineType ?? 'International',
      category: 'Main Course',
      cookTime: '30 minutes',
      difficulty: 'Medium',
      servings: 2,
      ingredients: ['Main ingredients for $dishName'],
      instructions: error != null
          ? ['Could not fetch recipe due to a $error. Please try again later.']
          : ['Prepare and cook $dishName according to your preference.'],
      tips: ['Use fresh ingredients for best results'],
      nutritionInfo: {},
      source: 'ai_fallback',
    );
  }

  // ... (parsing and helper methods remain the same)
  static RecipeData _parseSpoonacularRecipe(Map<String, dynamic> recipe) {
    final ingredients = <String>[];
    if (recipe['extendedIngredients'] != null) {
      for (final ingredient in recipe['extendedIngredients']) {
        final original = ingredient['original']?.toString() ?? '';
        if (original.isNotEmpty) {
          ingredients.add(original);
        } else {
          // Properly use the ingredient data
          final amount = ingredient['amount']?.toString() ?? '';
          final unit = ingredient['unit'] ?? '';
          final name = ingredient['name'] ?? '';
          ingredients.add('$amount $unit $name'.trim());
        }
      }
    }

    final instructions = <String>[];
    if (recipe['analyzedInstructions'] != null && recipe['analyzedInstructions'].isNotEmpty) {
      final steps = recipe['analyzedInstructions'][0]['steps'] ?? [];
      for (final step in steps) {
        instructions.add(step['step']?.toString() ?? '');
      }
    }

    return RecipeData(
      id: recipe['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: recipe['title'] ?? 'Unknown Recipe',
      cuisine: recipe['cuisines'] != null && recipe['cuisines'].isNotEmpty 
          ? recipe['cuisines'][0] 
          : 'International',
      category: recipe['dishTypes'] != null && recipe['dishTypes'].isNotEmpty 
          ? recipe['dishTypes'][0] 
          : 'Main Course',
      cookTime: '${recipe['readyInMinutes'] ?? 30} minutes',
      difficulty: _estimateDifficulty(recipe['readyInMinutes'] ?? 30),
      servings: recipe['servings'] ?? 2,
      ingredients: ingredients.isNotEmpty ? ingredients : ['Ingredients not available'],
      instructions: instructions.isNotEmpty ? instructions : ['Instructions not available'],
      tips: ['Use fresh ingredients for best results'],
      nutritionInfo: {},
      source: 'spoonacular',
      imageUrl: recipe['image'],
    );
  }

  static RecipeData _parseMealDbRecipe(Map<String, dynamic> meal) {
    final ingredients = <String>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = meal['strIngredient$i'];
      final measure = meal['strMeasure$i'];
      if (ingredient != null && ingredient.isNotEmpty && ingredient != 'null') {
        // FIXED: Properly use both variables
        ingredients.add('${measure?.trim() ?? ''} ${ingredient.trim()}'.trim());
      }
    }

    return RecipeData(
      id: meal['idMeal'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: meal['strMeal'] ?? 'Unknown Dish',
      cuisine: meal['strArea'] ?? 'International',
      category: meal['strCategory'] ?? 'Main Course',
      cookTime: '30 minutes',
      difficulty: 'Medium',
      servings: 4,
      ingredients: ingredients,
      instructions: _parseInstructions(meal['strInstructions']),
      tips: ['Enjoy your meal!'],
      nutritionInfo: {},
      source: 'mealdb',
      imageUrl: meal['strMealThumb'],
    );
  }

  static String _estimateDifficulty(int cookTime) {
    if (cookTime <= 15) return 'Easy';
    if (cookTime <= 45) return 'Medium';
    return 'Hard';
  }

  static List<String> _parseInstructions(String? instructions) {
    if (instructions == null) return ['Instructions not available'];
    return instructions
        .split(RegExp(r'[\r\n]+'))
        .where((step) => step.trim().isNotEmpty)
        .map((step) => step.trim())
        .toList();
  }
}
