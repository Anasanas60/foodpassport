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

  final Position? position;
  final String? area;

  // other fields like photoPath, notes, etc. omitted for brevity

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
    this.position,
    this.area,
  });

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
    Position? position,
    String? area,
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
      position: position ?? this.position,
      area: area ?? this.area,
    );
  }

  // Factory constructor to create a FoodItem from a map
  factory FoodItem.fromRecognitionMap(Map<String, dynamic> map, {String? imagePath}) {
    return FoodItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: map['foodName'] ?? 'Unknown',
      confidenceScore: (map['confidence'] ?? 0).toDouble(),
      calories: (map['calories'] ?? 0).toDouble(),
      protein: (map['protein'] ?? 0).toDouble(),
      carbs: (map['carbs'] ?? 0).toDouble(),
      fat: (map['fat'] ?? 0).toDouble(),
      source: map['source'] ?? '',
      detectedAllergens: List<String>.from(map['detectedAllergens'] ?? []),
      imagePath: imagePath ?? '',
      timestamp: DateTime.now(),
      position: null,
      area: null,
    );
  }
}
