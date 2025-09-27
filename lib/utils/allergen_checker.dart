class AllergenChecker {
  // Enhanced allergens mapping for different cuisines
  static final Map<String, List<String>> _cuisineAllergens = {
    'thai': ['peanuts', 'shellfish', 'fish', 'soy', 'gluten', 'sesame', 'eggs'],
    'italian': ['gluten', 'dairy', 'eggs', 'nuts', 'shellfish'],
    'mexican': ['dairy', 'gluten', 'avocado', 'corn', 'beans'],
    'chinese': ['soy', 'shellfish', 'gluten', 'sesame', 'peanuts', 'eggs'],
    'indian': ['dairy', 'nuts', 'gluten', 'mustard', 'sesame', 'legumes'],
    'japanese': ['fish', 'shellfish', 'soy', 'wheat', 'eggs', 'buckwheat'],
    'mediterranean': ['nuts', 'sesame', 'gluten', 'dairy', 'shellfish'],
    'french': ['dairy', 'gluten', 'eggs', 'nuts'],
    'korean': ['soy', 'sesame', 'shellfish', 'gluten', 'peanuts'],
    'vietnamese': ['fish', 'shellfish', 'soy', 'peanuts', 'gluten'],
  };

  // Enhanced ingredient allergen mapping
  static final Map<String, List<String>> _ingredientAllergens = {
    // Nuts & Seeds
    'peanut': ['peanuts'],
    'almond': ['nuts'],
    'walnut': ['nuts'],
    'cashew': ['nuts'],
    'pistachio': ['nuts'],
    'hazelnut': ['nuts'],
    'pecan': ['nuts'],
    'macadamia': ['nuts'],
    'sesame': ['sesame'],
    'sunflower seed': ['seeds'],
    'pumpkin seed': ['seeds'],
    
    // Dairy
    'milk': ['dairy'],
    'cheese': ['dairy'],
    'butter': ['dairy'],
    'cream': ['dairy'],
    'yogurt': ['dairy'],
    'whey': ['dairy'],
    'casein': ['dairy'],
    
    // Gluten
    'wheat': ['gluten'],
    'flour': ['gluten'],
    'bread': ['gluten'],
    'pasta': ['gluten'],
    'barley': ['gluten'],
    'rye': ['gluten'],
    'oats': ['gluten'], // Often cross-contaminated
    
    // Seafood
    'fish': ['fish'],
    'salmon': ['fish'],
    'tuna': ['fish'],
    'cod': ['fish'],
    'shrimp': ['shellfish'],
    'prawn': ['shellfish'],
    'crab': ['shellfish'],
    'lobster': ['shellfish'],
    'scallop': ['shellfish'],
    'clam': ['shellfish'],
    'mussel': ['shellfish'],
    'oyster': ['shellfish'],
    
    // Other common allergens
    'egg': ['eggs'],
    'soy': ['soy'],
    'soybean': ['soy'],
    'tofu': ['soy'],
    'mustard': ['mustard'],
    'celery': ['celery'],
    'lupin': ['lupin'],
    'mollusk': ['shellfish'],
    'crustacean': ['shellfish'],
  };

  // Advanced allergen detection with multiple strategies
  static List<String> detectAllergens({
    required String foodName,
    String? description,
    String? cuisineType,
    List<String>? ingredients,
    Map<String, dynamic>? nutritionInfo,
  }) {
    final Set<String> allergens = <String>{};
    final lowerFoodName = foodName.toLowerCase();
    final lowerDescription = description?.toLowerCase() ?? '';
    final lowerCuisine = cuisineType?.toLowerCase();
    final allIngredients = ingredients?.join(' ').toLowerCase() ?? '';

    // Strategy 1: Cuisine-based allergen patterns
    _detectCuisineAllergens(lowerCuisine, allergens);

    // Strategy 2: Ingredient-based detection
    _detectIngredientAllergens('$lowerFoodName $lowerDescription $allIngredients', allergens);

    // Strategy 3: Pattern matching for complex dishes
    _detectPatternBasedAllergens(lowerFoodName, lowerDescription, allergens);

    // Strategy 4: Nutrition-based inference (if available)
    if (nutritionInfo != null) {
      _detectNutritionBasedAllergens(nutritionInfo, allergens);
    }

    return allergens.toList();
  }

  // Cuisine-based allergen detection
  static void _detectCuisineAllergens(String? cuisine, Set<String> allergens) {
    if (cuisine != null && _cuisineAllergens.containsKey(cuisine)) {
      allergens.addAll(_cuisineAllergens[cuisine]!);
    }
  }

  // Ingredient-based allergen detection
  static void _detectIngredientAllergens(String text, Set<String> allergens) {
    _ingredientAllergens.forEach((ingredient, allergenList) {
      if (_containsWord(text, ingredient)) {
        allergens.addAll(allergenList);
      }
    });

    // Special cases and patterns
    if (_containsWord(text, 'nut') && !text.contains('coconut')) {
      allergens.add('nuts');
    }
    if (_containsWord(text, 'seafood') || _containsWord(text, 'marine')) {
      allergens.addAll(['fish', 'shellfish']);
    }
    if (_containsWord(text, 'gluten') || _containsWord(text, 'wheat') || _containsWord(text, 'flour')) {
      allergens.add('gluten');
    }
    if (_containsWord(text, 'dairy') || _containsWord(text, 'milk') || _containsWord(text, 'cheese')) {
      allergens.add('dairy');
    }
  }

  // Pattern-based detection for complex dishes
  static void _detectPatternBasedAllergens(String foodName, String description, Set<String> allergens) {
    final combinedText = '$foodName $description'.toLowerCase();

    // Common dish patterns
    if (combinedText.contains('pad thai') || combinedText.contains('thai noodle')) {
      allergens.addAll(['peanuts', 'shellfish', 'eggs', 'gluten']);
    }
    if (combinedText.contains('curry') || combinedText.contains('masala')) {
      allergens.addAll(['dairy', 'nuts', 'gluten']);
    }
    if (combinedText.contains('sushi') || combinedText.contains('sashimi')) {
      allergens.addAll(['fish', 'shellfish', 'soy']);
    }
    if (combinedText.contains('pasta') || combinedText.contains('spaghetti')) {
      allergens.addAll(['gluten', 'dairy', 'eggs']);
    }
    if (combinedText.contains('cake') || combinedText.contains('pastry')) {
      allergens.addAll(['gluten', 'dairy', 'eggs', 'nuts']);
    }
    if (combinedText.contains('stir fry') || combinedText.contains('wok')) {
      allergens.addAll(['soy', 'shellfish', 'gluten', 'sesame']);
    }
  }

  // Nutrition-based allergen inference
  static void _detectNutritionBasedAllergens(Map<String, dynamic> nutrition, Set<String> allergens) {
    // High protein might indicate dairy, eggs, or seafood
    final protein = nutrition['protein'] ?? 0.0;
    if (protein > 20) {
      allergens.addAll(['dairy', 'eggs', 'fish', 'shellfish']);
    }

    // High calcium often indicates dairy
    final calcium = nutrition['calcium'] ?? 0.0;
    if (calcium > 100) {
      allergens.add('dairy');
    }

    // Specific nutrient patterns
    if (nutrition.containsKey('lactose') && nutrition['lactose'] > 0) {
      allergens.add('dairy');
    }
    if (nutrition.containsKey('gluten') && nutrition['gluten'] > 0) {
      allergens.add('gluten');
    }
  }

  // Check if text contains a whole word (not just substring)
  static bool _containsWord(String text, String word) {
    final pattern = RegExp('\\b$word\\b', caseSensitive: false);
    return pattern.hasMatch(text);
  }

  // Enhanced allergy matching with confidence scoring
  static bool hasMatchingAllergens({
    required List<String> detectedAllergens,
    required List<String> userAllergies,
    double confidenceThreshold = 0.7,
  }) {
    if (userAllergies.isEmpty) return false;

    final matches = detectedAllergens.where((allergen) => userAllergies.contains(allergen));
    return matches.isNotEmpty;
  }

  // Get emergency-level allergens with severity ranking
  static List<String> getEmergencyAllergens({
    required List<String> detectedAllergens,
    required List<String> userAllergies,
  }) {
    // Rank allergens by potential severity
    const severityRanking = {
      'peanuts': 10,
      'shellfish': 9,
      'fish': 8,
      'nuts': 7,
      'eggs': 6,
      'dairy': 5,
      'soy': 4,
      'gluten': 3,
      'sesame': 2,
      'mustard': 1,
    };

    final emergencyAllergens = detectedAllergens
        .where((allergen) => userAllergies.contains(allergen))
        .toList();

    // Sort by severity (highest first)
    emergencyAllergens.sort((a, b) {
      final severityA = severityRanking[a] ?? 0;
      final severityB = severityRanking[b] ?? 0;
      return severityB.compareTo(severityA);
    });

    return emergencyAllergens;
  }

  // Get allergen risk level for UI display
  static String getAllergenRiskLevel(List<String> emergencyAllergens) {
    if (emergencyAllergens.isEmpty) return 'none';
    
    final highRiskAllergens = emergencyAllergens.where((allergen) =>
        ['peanuts', 'shellfish', 'fish', 'nuts'].contains(allergen));
    
    if (highRiskAllergens.isNotEmpty) return 'high';
    if (emergencyAllergens.length > 2) return 'medium';
    return 'low';
  }

  // Generate allergen warnings for display
  static List<String> generateAllergenWarnings(List<String> emergencyAllergens) {
    if (emergencyAllergens.isEmpty) return [];

    final warnings = <String>[];
    
    if (emergencyAllergens.contains('peanuts')) {
      warnings.add('⚠️ Contains peanuts - High allergy risk!');
    }
    if (emergencyAllergens.contains('shellfish')) {
      warnings.add('⚠️ Contains shellfish - Severe allergy risk!');
    }
    if (emergencyAllergens.contains('nuts')) {
      warnings.add('⚠️ Contains tree nuts - High allergy risk!');
    }

    // Add general warnings for other allergens
    final otherAllergens = emergencyAllergens.where((allergen) =>
        !['peanuts', 'shellfish', 'nuts'].contains(allergen));
    
    if (otherAllergens.isNotEmpty) {
      warnings.add('Contains: ${otherAllergens.join(', ')}');
    }

    return warnings;
  }

  // Check for cross-contamination risks
  static List<String> checkCrossContaminationRisks(String cuisineType, List<String> detectedAllergens) {
    final risks = <String>[];
    final lowerCuisine = cuisineType.toLowerCase();

    // Cuisine-specific cross-contamination risks
    if (lowerCuisine.contains('thai') && detectedAllergens.contains('peanuts')) {
      risks.add('High risk of peanut cross-contamination in Thai cuisine');
    }
    if (lowerCuisine.contains('chinese') && detectedAllergens.contains('soy')) {
      risks.add('Soy sauce used extensively in Chinese cooking');
    }
    if (lowerCuisine.contains('japanese') && detectedAllergens.contains('fish')) {
      risks.add('Fish products commonly used in Japanese cuisine');
    }
    if (detectedAllergens.contains('gluten')) {
      risks.add('Possible gluten cross-contamination in shared cooking areas');
    }

    return risks;
  }
}