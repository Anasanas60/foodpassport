import 'package:geolocator/geolocator.dart';

class FoodItem {
  // PROPERTY DEFINITIONS - ADDED THESE
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
  final String? cuisineType;
  final List<String>? ingredients;
  final Map<String, dynamic>? nutritionInfo;
  final String? description;
  final bool? isVerified;
  final String? area;
  final Position? position;

  // CONSTRUCTOR - ADDED THIS
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
    this.cuisineType,
    this.ingredients,
    this.nutritionInfo,
    this.description,
    this.isVerified,
    this.area,
    this.position,
  });

  // Factory constructor for recognition from map (fallback)
  factory FoodItem.fromRecognitionMap(Map<String, dynamic> map, {required String imagePath}) {
    return FoodItem(
      id: map['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['foodName'] ?? 'Detected Food',
      confidenceScore: (map['confidence'] ?? 0.5).toDouble(),
      calories: (map['calories'] ?? 0.0).toDouble(),
      protein: (map['protein'] ?? 0.0).toDouble(),
      carbs: (map['carbs'] ?? 0.0).toDouble(),
      fat: (map['fat'] ?? 0.0).toDouble(),
      source: map['source'] ?? 'fallback',
      detectedAllergens: List<String>.from(map['detectedAllergens'] ?? []),
      imagePath: imagePath,
      timestamp: DateTime.now(),
      cuisineType: map['cuisineType'],
      ingredients: map['ingredients'] != null ? List<String>.from(map['ingredients']) : null,
      nutritionInfo: map['nutritionInfo'] != null ? Map<String, dynamic>.from(map['nutritionInfo']) : null,
      description: map['description'],
      isVerified: map['isVerified'] ?? false,
      area: map['area'],
      position: map['position'] != null ? Position(
        longitude: map['position']['longitude'] ?? 0,
        latitude: map['position']['latitude'] ?? 0,
        timestamp: DateTime.now(),
        accuracy: map['position']['accuracy'] ?? 0,
        altitude: map['position']['altitude'] ?? 0,
        heading: map['position']['heading'] ?? 0,
        speed: map['position']['speed'] ?? 0,
        speedAccuracy: map['position']['speedAccuracy'] ?? 0,
        altitudeAccuracy: map['position']['altitudeAccuracy'] ?? 0,
        headingAccuracy: map['position']['headingAccuracy'] ?? 0,
      ) : null,
    );
  }

  // Create from map (from storage)
  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      confidenceScore: (map['confidenceScore'] ?? 0.0).toDouble(),
      calories: (map['calories'] ?? 0.0).toDouble(),
      protein: (map['protein'] ?? 0.0).toDouble(),
      carbs: (map['carbs'] ?? 0.0).toDouble(),
      fat: (map['fat'] ?? 0.0).toDouble(),
      source: map['source'] ?? 'unknown',
      detectedAllergens: List<String>.from(map['detectedAllergens'] ?? []),
      imagePath: map['imagePath'] ?? '',
      timestamp: map['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'])
          : DateTime.now(),
      cuisineType: map['cuisineType'],
      ingredients: map['ingredients'] != null ? List<String>.from(map['ingredients']) : null,
      nutritionInfo: map['nutritionInfo'] != null ? Map<String, dynamic>.from(map['nutritionInfo']) : null,
      description: map['description'],
      isVerified: map['isVerified'] ?? false,
      area: map['area'],
      position: map['position'] != null ? Position(
        longitude: map['position']['longitude'] ?? 0,
        latitude: map['position']['latitude'] ?? 0,
        timestamp: DateTime.now(),
        accuracy: map['position']['accuracy'] ?? 0,
        altitude: map['position']['altitude'] ?? 0,
        heading: map['position']['heading'] ?? 0,
        speed: map['position']['speed'] ?? 0,
        speedAccuracy: map['position']['speedAccuracy'] ?? 0,
        altitudeAccuracy: map['position']['altitudeAccuracy'] ?? 0,
        headingAccuracy: map['position']['headingAccuracy'] ?? 0,
      ) : null,
    );
  }

  // Copy with method for updates
  FoodItem copyWith({
    String? id,
    String? name,
    double? confidenceScore,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    String? source,
    List<String>? detectedAllergens,
    String? imagePath,
    DateTime? timestamp,
    String? cuisineType,
    List<String>? ingredients,
    Map<String, dynamic>? nutritionInfo,
    String? description,
    bool? isVerified,
    String? area,
    Position? position,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
      source: source ?? this.source,
      detectedAllergens: detectedAllergens ?? this.detectedAllergens,
      imagePath: imagePath ?? this.imagePath,
      timestamp: timestamp ?? this.timestamp,
      cuisineType: cuisineType ?? this.cuisineType,
      ingredients: ingredients ?? this.ingredients,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      description: description ?? this.description,
      isVerified: isVerified ?? this.isVerified,
      area: area ?? this.area,
      position: position ?? this.position,
    );
  }

  // Get high-risk allergens that match user's allergies
  List<String> getHighRiskAllergens(List<String> userAllergies) {
    return detectedAllergens.where((allergen) => userAllergies.contains(allergen)).toList();
  }

  // Check if this food item has allergy risk for user
  bool hasAllergyRisk(List<String> userAllergies) {
    return getHighRiskAllergens(userAllergies).isNotEmpty;
  }

  // Method for map_screen.dart
  bool containsAllergens(List<String> userAllergies) {
    return detectedAllergens.any((allergen) => userAllergies.contains(allergen));
  }

  // Check if food is healthy based on nutrition
  bool get isHealthy {
    return calories < 400 && protein > 5 && fat < 15 && carbs < 50;
  }

  // Get nutrition summary
  String get nutritionSummary {
    return '${calories.round()} cal • ${protein.round()}g protein • ${carbs.round()}g carbs • ${fat.round()}g fat';
  }

  // Get confidence level as text
  String get confidenceLevel {
    if (confidenceScore >= 0.8) return 'High';
    if (confidenceScore >= 0.6) return 'Medium';
    if (confidenceScore >= 0.4) return 'Low';
    return 'Very Low';
  }

  // Get display color based on confidence
  int get confidenceColor {
    if (confidenceScore >= 0.8) return 0xFF4CAF50; // Green
    if (confidenceScore >= 0.6) return 0xFFFF9800; // Orange
    return 0xFFF44336; // Red
  }

  @override
  String toString() {
    return 'FoodItem(name: $name, confidence: $confidenceScore, allergens: $detectedAllergens)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoodItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}