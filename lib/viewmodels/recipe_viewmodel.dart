import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe_data.dart';
import '../services/recipe_service.dart';
import '../services/user_profile_service.dart';
import '../utils/allergen_checker.dart';

class RecipeViewModel extends ChangeNotifier {
  final BuildContext context;
  final String dishName;

  RecipeData? recipeData;
  bool isLoading = true;
  bool hasError = false;
  List<String> detectedAllergens = [];
  List<String> emergencyAllergens = [];

  RecipeViewModel(this.context, this.dishName) {
    loadRecipeData();
  }

  Future<void> loadRecipeData() async {
    isLoading = true;
    hasError = false;
    notifyListeners();

    try {
      final userProfileService = Provider.of<UserProfileService>(context, listen: false);
      final userProfile = userProfileService.userProfile;

      final recipe = await RecipeService.getAIRecipe(
        dishName,
        dietaryRestrictions: userProfile?.allergies ?? [],
      );

      recipeData = recipe;
      if (userProfile != null) {
        detectedAllergens = AllergenChecker.detectAllergens(
          ingredients: recipe.ingredients,
        );
        emergencyAllergens = AllergenChecker.getEmergencyAllergens(
          detectedAllergens: detectedAllergens,
          userAllergies: userProfile.allergies,
        );
      }
    } catch (e) {
      hasError = true;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
