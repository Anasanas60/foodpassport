class AllergenChecker {
  // Common allergens mapping for different cuisines
  static final Map<String, List<String>> _cuisineAllergens = {
    'thai': ['peanuts', 'shellfish', 'fish', 'soy', 'gluten'],
    'italian': ['gluten', 'dairy', 'eggs', 'nuts'],
    'mexican': ['dairy', 'gluten', 'avocado'],
    'chinese': ['soy', 'shellfish', 'gluten', 'sesame'],
    'indian': ['dairy', 'nuts', 'gluten', 'mustard'],
    'japanese': ['fish', 'shellfish', 'soy', 'wheat'],
    'mediterranean': ['nuts', 'sesame', 'gluten'],
  };

  // Common ingredients that contain allergens
  static final Map<String, List<String>> _ingredientAllergens = {
    'peanut': ['peanuts'],
    'soy sauce': ['soy'],
    'wheat': ['gluten'],
    'milk': ['dairy'],
    'cheese': ['dairy'],
    'butter': ['dairy'],
    'shrimp': ['shellfish'],
    'prawn': ['shellfish'],
    'crab': ['shellfish'],
    'fish sauce': ['fish'],
    'egg': ['eggs'],
    'almond': ['nuts'],
    'walnut': ['nuts'],
    'cashew': ['nuts'],
    'sesame oil': ['sesame'],
  };

  // Detect allergens from food name, description, and cuisine type
  static List<String> detectAllergens({
    required String foodName,
    String? description,
    String? cuisineType,
    List<String>? ingredients,
  }) {
    final Set<String> allergens = <String>{};
    final lowerFoodName = foodName.toLowerCase();
    final lowerDescription = description?.toLowerCase() ?? '';
    final lowerCuisine = cuisineType?.toLowerCase();

    // Check cuisine-specific allergens
    if (lowerCuisine != null && _cuisineAllergens.containsKey(lowerCuisine)) {
      allergens.addAll(_cuisineAllergens[lowerCuisine]!);
    }

    // Check ingredient-based allergens
    final allText = '$lowerFoodName $lowerDescription ${ingredients?.join(' ') ?? ''}'.toLowerCase();
    
    _ingredientAllergens.forEach((ingredient, allergenList) {
      if (allText.contains(ingredient)) {
        allergens.addAll(allergenList);
      }
    });

    // Specific pattern matching
    if (allText.contains('nut') && !allText.contains('coconut')) {
      allergens.add('nuts');
    }
    if (allText.contains('gluten') || allText.contains('wheat') || allText.contains('flour')) {
      allergens.add('gluten');
    }
    if (allText.contains('dairy') || allText.contains('milk') || allText.contains('cheese')) {
      allergens.add('dairy');
    }
    if (allText.contains('seafood') || allText.contains('fish') || allText.contains('shrimp')) {
      allergens.addAll(['fish', 'shellfish']);
    }

    return allergens.toList();
  }

  // Check if food contains user's specific allergies
  static bool hasMatchingAllergens({
    required List<String> detectedAllergens,
    required List<String> userAllergies,
  }) {
    return detectedAllergens.any((allergen) => userAllergies.contains(allergen));
  }

  // Get emergency-level allergens (user's allergies that are detected)
  static List<String> getEmergencyAllergens({
    required List<String> detectedAllergens,
    required List<String> userAllergies,
  }) {
    return detectedAllergens.where((allergen) => userAllergies.contains(allergen)).toList();
  }
}
