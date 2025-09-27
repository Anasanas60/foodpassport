class RecipeData {
  final String id;
  final String name;
  final String cuisine;
  final String category;
  final String cookTime;
  final String difficulty;
  final int servings;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> tips;
  final Map<String, dynamic> nutritionInfo;
  final String source; // 'spoonacular', 'mealdb', 'ai_fallback'
  final String? imageUrl;
  final String? summary;
  final List<String>? dietaryInfo;
  final double? spoonacularScore;
  final double? healthScore;
  final DateTime? timestamp;
  final List<String>? detectedAllergens;
  final bool? isVegetarian;
  final bool? isVegan;
  final bool? isGlutenFree;
  final bool? isDairyFree;

  RecipeData({
    required this.id,
    required this.name,
    required this.cuisine,
    required this.category,
    required this.cookTime,
    required this.difficulty,
    required this.servings,
    required this.ingredients,
    required this.instructions,
    required this.tips,
    required this.nutritionInfo,
    required this.source,
    this.imageUrl,
    this.summary,
    this.dietaryInfo,
    this.spoonacularScore,
    this.healthScore,
    this.timestamp,
    this.detectedAllergens,
    this.isVegetarian,
    this.isVegan,
    this.isGlutenFree,
    this.isDairyFree,
  });

  // Enhanced factory constructor for Spoonacular API response
  factory RecipeData.fromSpoonacular(Map<String, dynamic> data, {String? imagePath}) {
    // Extract nutrition information with fallbacks
    final nutrition = <String, dynamic>{};
    if (data['nutrition'] != null && data['nutrition']['nutrients'] != null) {
      for (final nutrient in data['nutrition']['nutrients']) {
        final name = nutrient['name']?.toString().toLowerCase() ?? '';
        nutrition[name] = nutrient['amount']?.toDouble() ?? 0.0;
        
        // Map to standard names
        if (name.contains('calorie')) nutrition['calories'] = nutrient['amount']?.toDouble() ?? 0.0;
        if (name.contains('protein')) nutrition['protein'] = nutrient['amount']?.toDouble() ?? 0.0;
        if (name.contains('carbohydrate')) nutrition['carbs'] = nutrient['amount']?.toDouble() ?? 0.0;
        if (name.contains('fat')) nutrition['fat'] = nutrient['amount']?.toDouble() ?? 0.0;
        if (name.contains('sugar')) nutrition['sugar'] = nutrient['amount']?.toDouble() ?? 0.0;
        if (name.contains('fiber')) nutrition['fiber'] = nutrient['amount']?.toDouble() ?? 0.0;
      }
    }

    // Extract ingredients
    final ingredients = <String>[];
    if (data['extendedIngredients'] != null) {
      for (final ingredient in data['extendedIngredients']) {
        final original = ingredient['original']?.toString() ?? '';
        if (original.isNotEmpty) {
          ingredients.add(original);
        } else {
          final amount = ingredient['amount']?.toString() ?? '';
          final unit = ingredient['unit'] ?? '';
          final name = ingredient['name'] ?? '';
          ingredients.add('$amount $unit $name'.trim());
        }
      }
    }

    // Extract instructions
    final instructions = <String>[];
    if (data['analyzedInstructions'] != null && data['analyzedInstructions'].isNotEmpty) {
      final steps = data['analyzedInstructions'][0]['steps'] ?? [];
      for (final step in steps) {
        instructions.add(step['step']?.toString() ?? '');
      }
    }

    // Extract dietary information
    final dietaryInfo = <String>[];
    if (data['vegetarian'] == true) dietaryInfo.add('Vegetarian');
    if (data['vegan'] == true) dietaryInfo.add('Vegan');
    if (data['glutenFree'] == true) dietaryInfo.add('Gluten-Free');
    if (data['dairyFree'] == true) dietaryInfo.add('Dairy-Free');

    // Detect allergens from ingredients
    final detectedAllergens = _extractAllergensFromIngredients(ingredients);

    return RecipeData(
      id: data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: data['title'] ?? data['name'] ?? 'Unknown Recipe',
      cuisine: data['cuisines'] != null && data['cuisines'].isNotEmpty 
          ? data['cuisines'][0] 
          : data['dishTypes'] != null && data['dishTypes'].isNotEmpty
            ? data['dishTypes'][0]
            : 'International',
      category: data['dishTypes'] != null && data['dishTypes'].isNotEmpty 
          ? data['dishTypes'][0] 
          : 'Main Course',
      cookTime: '${data['readyInMinutes'] ?? 30} minutes',
      difficulty: _estimateDifficulty(data['readyInMinutes'] ?? 30),
      servings: data['servings'] ?? 2,
      ingredients: ingredients,
      instructions: instructions.isNotEmpty ? instructions : _generateFallbackInstructions(data['title'] ?? ''),
      tips: _generateSmartTips(data['title'] ?? '', data['readyInMinutes'] ?? 30, dietaryInfo),
      nutritionInfo: nutrition,
      source: 'spoonacular',
      imageUrl: data['image'],
      summary: data['summary'] != null 
          ? data['summary']!.replaceAll(RegExp(r'<[^>]*>'), '').substring(0, 200) + '...'
          : null,
      dietaryInfo: dietaryInfo,
      spoonacularScore: data['spoonacularScore']?.toDouble(),
      healthScore: data['healthScore']?.toDouble(),
      timestamp: DateTime.now(),
      detectedAllergens: detectedAllergens,
      isVegetarian: data['vegetarian'] ?? false,
      isVegan: data['vegan'] ?? false,
      isGlutenFree: data['glutenFree'] ?? false,
      isDairyFree: data['dairyFree'] ?? false,
    );
  }

  // Factory constructor for MealDB API response
  factory RecipeData.fromMealDb(Map<String, dynamic> data) {
    final ingredients = <String>[];
    for (int i = 1; i <= 20; i++) {
      final ingredient = data['strIngredient$i'];
      final measure = data['strMeasure$i'];
      if (ingredient != null && ingredient.isNotEmpty && ingredient != 'null') {
        ingredients.add('${measure?.trim() ?? ''} ${ingredient.trim()}'.trim());
      }
    }

    final instructions = _parseInstructions(data['strInstructions']);

    return RecipeData(
      id: data['idMeal'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: data['strMeal'] ?? 'Unknown Dish',
      cuisine: data['strArea'] ?? 'International',
      category: data['strCategory'] ?? 'Main Course',
      cookTime: '30 minutes',
      difficulty: 'Medium',
      servings: 4,
      ingredients: ingredients,
      instructions: instructions,
      tips: _generateSmartTips(data['strMeal'] ?? '', 30, []),
      nutritionInfo: _estimateNutrition(data['strMeal'] ?? ''),
      source: 'mealdb',
      imageUrl: data['strMealThumb'],
      timestamp: DateTime.now(),
    );
  }

  // Helper method to extract allergens from ingredients
  static List<String> _extractAllergensFromIngredients(List<String> ingredients) {
    final allergens = <String>{};
    final allergenKeywords = {
      'nut': 'nuts',
      'peanut': 'peanuts',
      'almond': 'nuts',
      'walnut': 'nuts',
      'cashew': 'nuts',
      'dairy': 'dairy',
      'milk': 'dairy',
      'cheese': 'dairy',
      'butter': 'dairy',
      'gluten': 'gluten',
      'wheat': 'gluten',
      'flour': 'gluten',
      'soy': 'soy',
      'tofu': 'soy',
      'fish': 'fish',
      'salmon': 'fish',
      'tuna': 'fish',
      'shrimp': 'shellfish',
      'prawn': 'shellfish',
      'crab': 'shellfish',
      'lobster': 'shellfish',
      'egg': 'eggs',
      'sesame': 'sesame',
    };

    final ingredientsText = ingredients.join(' ').toLowerCase();
    
    allergenKeywords.forEach((keyword, allergen) {
      if (ingredientsText.contains(keyword)) {
        allergens.add(allergen);
      }
    });

    return allergens.toList();
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

  static List<String> _generateFallbackInstructions(String dishName) {
    return [
      'Prepare all ingredients by washing, chopping, and measuring them.',
      'Heat oil in a pan over medium heat and sauté aromatics until fragrant.',
      'Add main ingredients and cook until properly done.',
      'Add sauces and seasonings, then simmer to combine flavors.',
      'Taste and adjust seasoning throughout the cooking process.',
      'Plate attractively and garnish before serving.',
      'Enjoy your delicious $dishName!'
    ];
  }

  static List<String> _generateSmartTips(String dishName, int cookTime, List<String> dietaryInfo) {
    final tips = <String>[
      'Use fresh, high-quality ingredients for the best flavor',
      'Taste and adjust seasoning as you cook',
      'Prepare all ingredients before starting to cook (mise en place)'
    ];

    final lowerName = dishName.toLowerCase();
    
    if (cookTime < 20) {
      tips.add('Work quickly and have everything ready for fast cooking');
    }
    
    if (lowerName.contains('bake') || lowerName.contains('oven')) {
      tips.add('Preheat your oven properly for consistent results');
    }
    
    if (lowerName.contains('meat') || lowerName.contains('chicken')) {
      tips.add('Let meat rest for a few minutes after cooking for juicier results');
    }

    if (dietaryInfo.contains('Gluten-Free')) {
      tips.add('Use gluten-free alternatives for flour-based ingredients');
    }

    if (dietaryInfo.contains('Dairy-Free')) {
      tips.add('Substitute dairy with plant-based alternatives like almond or oat milk');
    }

    return tips;
  }

  static Map<String, dynamic> _estimateNutrition(String dishName) {
    final lowerName = dishName.toLowerCase();
    
    if (lowerName.contains('salad')) {
      return {'calories': 150, 'protein': 5, 'carbs': 20, 'fat': 6};
    } else if (lowerName.contains('pasta')) {
      return {'calories': 400, 'protein': 15, 'carbs': 60, 'fat': 12};
    } else if (lowerName.contains('curry')) {
      return {'calories': 350, 'protein': 20, 'carbs': 25, 'fat': 18};
    } else if (lowerName.contains('grilled') || lowerName.contains('steak')) {
      return {'calories': 450, 'protein': 35, 'carbs': 5, 'fat': 30};
    }
    
    return {'calories': 300, 'protein': 15, 'carbs': 35, 'fat': 12};
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cuisine': cuisine,
      'category': category,
      'cookTime': cookTime,
      'difficulty': difficulty,
      'servings': servings,
      'ingredients': ingredients,
      'instructions': instructions,
      'tips': tips,
      'nutritionInfo': nutritionInfo,
      'source': source,
      'imageUrl': imageUrl,
      'summary': summary,
      'dietaryInfo': dietaryInfo,
      'spoonacularScore': spoonacularScore,
      'healthScore': healthScore,
      'timestamp': timestamp?.millisecondsSinceEpoch,
      'detectedAllergens': detectedAllergens,
      'isVegetarian': isVegetarian,
      'isVegan': isVegan,
      'isGlutenFree': isGlutenFree,
      'isDairyFree': isDairyFree,
    };
  }

  // Create from map (from storage)
  factory RecipeData.fromMap(Map<String, dynamic> map) {
    return RecipeData(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      cuisine: map['cuisine'] ?? 'International',
      category: map['category'] ?? 'Main Course',
      cookTime: map['cookTime'] ?? '30 minutes',
      difficulty: map['difficulty'] ?? 'Medium',
      servings: map['servings'] ?? 2,
      ingredients: List<String>.from(map['ingredients'] ?? []),
      instructions: List<String>.from(map['instructions'] ?? []),
      tips: List<String>.from(map['tips'] ?? []),
      nutritionInfo: Map<String, dynamic>.from(map['nutritionInfo'] ?? {}),
      source: map['source'] ?? 'unknown',
      imageUrl: map['imageUrl'],
      summary: map['summary'],
      dietaryInfo: map['dietaryInfo'] != null ? List<String>.from(map['dietaryInfo']) : null,
      spoonacularScore: map['spoonacularScore']?.toDouble(),
      healthScore: map['healthScore']?.toDouble(),
      timestamp: map['timestamp'] != null ? DateTime.fromMillisecondsSinceEpoch(map['timestamp']) : null,
      detectedAllergens: map['detectedAllergens'] != null ? List<String>.from(map['detectedAllergens']) : null,
      isVegetarian: map['isVegetarian'],
      isVegan: map['isVegan'],
      isGlutenFree: map['isGlutenFree'],
      isDairyFree: map['isDairyFree'],
    );
  }

  // Copy with method for updates
  RecipeData copyWith({
    String? id,
    String? name,
    String? cuisine,
    String? category,
    String? cookTime,
    String? difficulty,
    int? servings,
    List<String>? ingredients,
    List<String>? instructions,
    List<String>? tips,
    Map<String, dynamic>? nutritionInfo,
    String? source,
    String? imageUrl,
    String? summary,
    List<String>? dietaryInfo,
    double? spoonacularScore,
    double? healthScore,
    DateTime? timestamp,
    List<String>? detectedAllergens,
    bool? isVegetarian,
    bool? isVegan,
    bool? isGlutenFree,
    bool? isDairyFree,
  }) {
    return RecipeData(
      id: id ?? this.id,
      name: name ?? this.name,
      cuisine: cuisine ?? this.cuisine,
      category: category ?? this.category,
      cookTime: cookTime ?? this.cookTime,
      difficulty: difficulty ?? this.difficulty,
      servings: servings ?? this.servings,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
      tips: tips ?? this.tips,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      source: source ?? this.source,
      imageUrl: imageUrl ?? this.imageUrl,
      summary: summary ?? this.summary,
      dietaryInfo: dietaryInfo ?? this.dietaryInfo,
      spoonacularScore: spoonacularScore ?? this.spoonacularScore,
      healthScore: healthScore ?? this.healthScore,
      timestamp: timestamp ?? this.timestamp,
      detectedAllergens: detectedAllergens ?? this.detectedAllergens,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      isVegan: isVegan ?? this.isVegan,
      isGlutenFree: isGlutenFree ?? this.isGlutenFree,
      isDairyFree: isDairyFree ?? this.isDairyFree,
    );
  }

  // Get nutrition value with fallback
  double getNutritionValue(String key) {
    return nutritionInfo[key]?.toDouble() ?? 0.0;
  }

  // Check if recipe matches dietary restrictions
  bool matchesDietaryRestrictions(List<String> restrictions) {
    if (restrictions.isEmpty) return true;

    for (final restriction in restrictions) {
      final lowerRestriction = restriction.toLowerCase();
      
      if (lowerRestriction.contains('vegetarian') && isVegetarian != true) return false;
      if (lowerRestriction.contains('vegan') && isVegan != true) return false;
      if (lowerRestriction.contains('gluten') && isGlutenFree != true) return false;
      if (lowerRestriction.contains('dairy') && isDairyFree != true) return false;
    }

    return true;
  }

  // Get estimated calories per serving
  double get caloriesPerServing {
    final totalCalories = getNutritionValue('calories');
    return servings > 0 ? totalCalories / servings : totalCalories;
  }

  // Check if recipe is healthy based on nutrition
  bool get isHealthy {
    final calories = getNutritionValue('calories');
    final protein = getNutritionValue('protein');
    final sugar = getNutritionValue('sugar');
    final fat = getNutritionValue('fat');

    return calories < 500 && protein > 10 && sugar < 20 && fat < 20;
  }

  @override
  String toString() {
    return 'RecipeData(name: $name, cuisine: $cuisine, source: $source)';
  }
}