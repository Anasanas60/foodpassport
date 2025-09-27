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
    this.cuisineType,
    this.ingredients,
    this.nutritionInfo,
    this.description,
    this.isVerified,
    this.area,
    this.position,
  });

  // ADDED: Missing fromSpoonacular factory constructor
  factory FoodItem.fromSpoonacular(Map<String, dynamic> data, {
    required String imagePath,
    Map<String, dynamic>? nutritionInfo,
    List<String>? detectedAllergens,
  }) {
    // Extract basic food information
    String foodName = 'Unknown Food';
    if (data['name'] != null) {
      foodName = data['name'];
    } else if (data['title'] != null) {
      foodName = data['title'];
    } else if (data['category'] != null && data['category']['name'] != null) {
      foodName = data['category']['name'];
    }

    // Extract confidence score
    double confidence = data['confidence']?.toDouble() ?? 
                       data['score']?.toDouble() ?? 
                       data['probability']?.toDouble() ?? 
                       0.7;

    // Extract nutrition information
    final nutrition = nutritionInfo ?? _extractNutritionFromSpoonacular(data);

    // Extract cuisine type
    String? cuisine;
    if (data['cuisine'] != null) {
      cuisine = data['cuisine'];
    } else if (data['cuisines'] != null && data['cuisines'].isNotEmpty) {
      cuisine = data['cuisines'][0];
    }

    // Extract ingredients
    List<String>? ingredients;
    if (data['ingredients'] != null) {
      ingredients = List<String>.from(data['ingredients'].map((ing) => ing['name'] ?? ''));
    } else if (data['extendedIngredients'] != null) {
      ingredients = List<String>.from(data['extendedIngredients'].map((ing) => ing['name'] ?? ''));
    }

    // Extract description
    String? description;
    if (data['description'] != null) {
      description = data['description'];
    } else if (data['summary'] != null) {
      description = data['summary']!.replaceAll(RegExp(r'<[^>]*>'), '');
    }

    return FoodItem(
      id: data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: foodName,
      confidenceScore: confidence.clamp(0.0, 1.0),
      calories: nutrition['calories']?.toDouble() ?? 0.0,
      protein: nutrition['protein']?.toDouble() ?? 0.0,
      carbs: nutrition['carbs']?.toDouble() ?? 0.0,
      fat: nutrition['fat']?.toDouble() ?? 0.0,
      source: 'spoonacular',
      detectedAllergens: detectedAllergens ?? FoodItem._extractAllergensFromSpoonacular(data),
      imagePath: imagePath,
      timestamp: DateTime.now(),
      cuisineType: cuisine,
      ingredients: ingredients,
      nutritionInfo: nutrition,
      description: description,
      isVerified: confidence > 0.6,
      area: data['area'] ?? data['country'] ?? data['region'],
    );
  }

  // Helper method to extract nutrition from Spoonacular response
  static Map<String, dynamic> _extractNutritionFromSpoonacular(Map<String, dynamic> data) {
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
      }
    }

    // Fallback to basic estimation if no nutrition data
    if (nutrition.isEmpty) {
      nutrition.addAll({
        'calories': 250.0,
        'protein': 10.0,
        'carbs': 30.0,
        'fat': 8.0,
      });
    }

    return nutrition;
  }

  // Helper method to extract allergens from Spoonacular response
  static List<String> _extractAllergensFromSpoonacular(Map<String, dynamic> data) {
    final allergens = <String>[];

    // Check dish type and category for common allergens
    if (data['dishType'] != null) {
      final dishType = data['dishType'].toString().toLowerCase();
      if (dishType.contains('nut') || dishType.contains('peanut')) allergens.add('peanuts');
      if (dishType.contains('dairy') || dishType.contains('cheese')) allergens.add('dairy');
      if (dishType.contains('seafood') || dishType.contains('fish')) allergens.addAll(['fish', 'shellfish']);
    }

    // Check category name
    if (data['category'] != null && data['category']['name'] != null) {
      final category = data['category']['name'].toString().toLowerCase();
      if (category.contains('nut') || category.contains('peanut')) allergens.add('peanuts');
      if (category.contains('dairy')) allergens.add('dairy');
      if (category.contains('seafood')) allergens.addAll(['fish', 'shellfish']);
    }

    return allergens.toList().toSet().toList(); // Remove duplicates
  }

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
      'source': source,
      'detectedAllergens': detectedAllergens,
      'imagePath': imagePath,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'cuisineType': cuisineType,
      'ingredients': ingredients,
      'nutritionInfo': nutritionInfo,
      'description': description,
      'isVerified': isVerified,
      'area': area,
      'position': position != null ? {
        'longitude': position!.longitude,
        'latitude': position!.latitude,
        'accuracy': position!.accuracy,
        'altitude': position!.altitude,
        'heading': position!.heading,
        'speed': position!.speed,
        'speedAccuracy': position!.speedAccuracy,
        'altitudeAccuracy': position!.altitudeAccuracy,
        'headingAccuracy': position!.headingAccuracy,
      } : null,
    };
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