import 'package:geolocator/geolocator.dart';

class FoodItem {
  final String id;
  final String name;
  final double confidenceScore;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String source;
  final List<String> detectedAllergens;
  final String imagePath;
  final DateTime timestamp;

  // New optional fields for photo and notes support
  final String? photoPath;
  final String? notes;

  // Additional optional info fields
  final String? cuisineType;
  final List<String>? ingredients;
  final Map<String, dynamic>? nutritionInfo;
  final String? description;
  final bool? isVerified;
  final String? area;
  final Position? position;

  FoodItem({
    required this.id,
    required this.name,
    required this.confidenceScore,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.source,
    required this.detectedAllergens,
    required this.imagePath,
    required this.timestamp,
    this.photoPath,
    this.notes,
    this.cuisineType,
    this.ingredients,
    this.nutritionInfo,
    this.description,
    this.isVerified,
    this.area,
    this.position,
  });

  // Factory constructors and other methods remain unchanged
}
