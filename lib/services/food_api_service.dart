class FoodApiService {
  static Future<List<String>> checkAllergens(List<String> potentialAllergens) async {
    // Simple implementation - in real app, this would call an API
    return potentialAllergens.where((allergen) => 
        ['peanuts', 'nuts', 'dairy', 'gluten', 'soy', 'eggs', 'fish', 'shellfish']
        .contains(allergen.toLowerCase())).toList();
  }
}
