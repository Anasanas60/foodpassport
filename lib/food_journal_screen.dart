import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class FoodJournalScreen extends StatelessWidget {
  const FoodJournalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Replace below with your actual UI and logic
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Journal'),
      ),
      body: const Center(
        child: Text('Food Journal Screen Content'),
      ),
    );
  }
}

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

  // Newly added nullable fields
  final String? photoPath;
  final String? notes;
  final String? cuisineType;
  final List<String>? ingredients;
  final Map<String, dynamic>? nutritionInfo;
  final String? description;
  final bool? isVerified;

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
    this.photoPath,
    this.notes,
    this.cuisineType,
    this.ingredients,
    this.nutritionInfo,
    this.description,
    this.isVerified,
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
    String? photoPath,
    String? notes,
    String? cuisineType,
    List<String>? ingredients,
    Map<String, dynamic>? nutritionInfo,
    String? description,
    bool? isVerified,
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
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      cuisineType: cuisineType ?? this.cuisineType,
      ingredients: ingredients ?? this.ingredients,
      nutritionInfo: nutritionInfo ?? this.nutritionInfo,
      description: description ?? this.description,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
