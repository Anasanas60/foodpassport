import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/recipe_data.dart'; // ADDED: Import RecipeData

class RecipeService {
  static Future<RecipeData?> getAIRecipe(
    String dishName, {
    String? cuisineType,
    List<String> dietaryRestrictions = const [],
  }) async {
    try {
      print('🔍 Searching Spoonacular for recipe: $dishName');
      
      final recipe = await _trySpoonacularRecipeSearch(dishName, cuisineType, dietaryRestrictions) 
          ?? await _tryMealDbRecipe(dishName)
          ?? await _generateFallbackRecipe(dishName, cuisineType, dietaryRestrictions);
      
      print('✅ Recipe found: ${recipe.name}');
      return recipe;
    } catch (e) {
      print('❌ Recipe service error: $e');
      return await _generateFallbackRecipe(dishName, cuisineType, dietaryRestrictions);
    }
  }

  // Spoonacular recipe search
  static Future<RecipeData?> _trySpoonacularRecipeSearch(
    String dishName, 
    String? cuisineType, 
    List<String> restrictions
  ) async {
    try {
      var url = '${ApiConfig.spoonacularBaseUrl}/recipes/complexSearch'
        '?apiKey=${ApiConfig.spoonacularApiKey}'
        '&query=${Uri.encodeComponent(dishName)}'
        '&number=2'
        '&addRecipeInformation=true'
        '&fillIngredients=true'
        '&instructionsRequired=true';

      if (cuisineType != null && cuisineType.isNotEmpty) {
        url += '&cuisine=${Uri.encodeComponent(cuisineType)}';
      }

      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return _parseSpoonacularRecipe(data['results'][0]); // FIXED: Now this method exists
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Spoonacular search error: $e');
      return null;
    }
  }

  // FIXED: Complete implementation of _parseSpoonacularRecipe
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

  // MealDB fallback
  static Future<RecipeData?> _tryMealDbRecipe(String dishName) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.mealDbBaseUrl}/search.php?s=${Uri.encodeComponent(dishName)}')
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return _parseMealDbRecipe(data['meals'][0]); // FIXED: Now this method exists
        }
      }
      return null;
    } catch (e) {
      print('❌ MealDB recipe error: $e');
      return null;
    }
  }

  // FIXED: Complete implementation of _parseMealDbRecipe
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

  // Fallback recipe generation
  static Future<RecipeData> _generateFallbackRecipe(
    String dishName, 
    String? cuisineType, 
    List<String> restrictions
  ) async {
    return RecipeData(
      id: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
      name: dishName,
      cuisine: cuisineType ?? 'International',
      category: 'Main Course',
      cookTime: '30 minutes',
      difficulty: 'Medium',
      servings: 2,
      ingredients: ['Main ingredients for $dishName'],
      instructions: ['Prepare and cook $dishName according to your preference'],
      tips: ['Use fresh ingredients for best results'],
      nutritionInfo: {},
      source: 'ai_fallback',
    );
  }

  // Helper methods
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