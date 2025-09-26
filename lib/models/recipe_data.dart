
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
}
