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
  final Map<String, int> nutritionInfo;
  final String source;

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
  });

  // Helper method to create a RecipeData from a map (useful for JSON deserialization)
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
      nutritionInfo: Map<String, int>.from(map['nutritionInfo'] ?? {}),
      source: map['source'] ?? 'ai_generated',
    );
  }

  // Convert a RecipeData instance to a map (useful for JSON serialization)
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
    };
  }
}