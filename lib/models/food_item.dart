import 'package:geolocator/geolocator.dart';

class FoodItem {
  final String id;
  final String name;
  final double confidenceScore;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? servingSize;
  final String? servingUnit;
  final String? recipe;
  final String? imageUrl;
  final String? category;
  final String? area; // Cultural origin
  final String source; // 'nutritionix', 'mealdb', 'fallback'
  final List<String> detectedAllergens;
  final String imagePath;
  final Position? position;
  final DateTime timestamp;

  FoodItem({
    required this.id,
    required this.name,
    required this.confidenceScore,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.servingSize,
    this.servingUnit,
    this.recipe,
    this.imageUrl,
    this.category,
    this.area,
    required this.source,
    required this.detectedAllergens,
    required this.imagePath,
    this.position,
    required this.timestamp,
  });

  // FIXED: Add proper constructor with all required parameters
  factory FoodItem.fromRecognitionMap(Map<String, dynamic> data, {
    required String imagePath,
    Position? position,
  }) {
    return FoodItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: data['foodName'] ?? 'Unknown Food',
      confidenceScore: (data['confidence'] ?? 0.0).toDouble(),
      calories: (data['calories'] ?? 0.0).toDouble(),
      protein: (data['protein'] ?? 0.0).toDouble(),
      carbs: (data['carbs'] ?? 0.0).toDouble(),
      fat: (data['fat'] ?? 0.0).toDouble(),
      servingSize: data['servingSize']?.toString(),
      servingUnit: data['servingUnit'],
      recipe: data['recipe'],
      imageUrl: data['imageUrl'],
      category: data['category'],
      area: data['area'],
      source: data['source'] ?? 'unknown',
      detectedAllergens: List<String>.from(data['detectedAllergens'] ?? []),
      imagePath: imagePath,
      position: position,
      timestamp: DateTime.now(),
    );
  }

  // Check if this food contains any of the user's allergies
  bool containsAllergens(List<String> userAllergies) {
    if (userAllergies.isEmpty || detectedAllergens.isEmpty) return false;
    return detectedAllergens.any((allergen) => userAllergies.contains(allergen));
  }

  // Get high-risk allergens for emergency alerts
  List<String> getHighRiskAllergens(List<String> userAllergies) {
    return detectedAllergens.where((allergen) => userAllergies.contains(allergen)).toList();
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'confidenceScore': confidenceScore,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'servingSize': servingSize,
      'servingUnit': servingUnit,
      'recipe': recipe,
      'imageUrl': imageUrl,
      'category': category,
      'area': area,
      'source': source,
      'detectedAllergens': detectedAllergens,
      'imagePath': imagePath,
      'position': position?.toJson(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  // FIXED: Add missing toJson method for Position compatibility
  Map<String, dynamic> toJson() => toMap();
}