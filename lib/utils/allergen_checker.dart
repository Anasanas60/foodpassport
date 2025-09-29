import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'logger.dart';

class AllergenChecker {
  // Static maps to hold the loaded allergen data.
  static Map<String, List<String>> _ingredientAllergens = {};
  static Map<String, int> _severityRanking = {};

  // Loads allergen data from the JSON asset.
  // This should be called once at app startup.
  static Future<void> loadAllergenData() async {
    try {
      final String response = await rootBundle.loadString('assets/allergen_data.json');
      final data = json.decode(response) as Map<String, dynamic>;
      
      _ingredientAllergens = (data['ingredient_allergens'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, List<String>.from(value as List)),
      );
      
      _severityRanking = (data['severity_ranking'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, value as int),
      );
      logger.info('Allergen data loaded successfully.');
    } catch (e) {
      logger.severe('Failed to load allergen data: $e');
      // Handle error, maybe by using a hardcoded fallback
    }
  }

  // Detects allergens based on a list of ingredients from an API.
  // This is much more reliable than heuristic-based methods.
  static List<String> detectAllergens({required List<String> ingredients}) {
    if (_ingredientAllergens.isEmpty) {
      logger.warning('Allergen data not loaded. Detection will be inaccurate.');
      return [];
    }

    final Set<String> detected = <String>{};
    final String combinedIngredients = ingredients.join(' ').toLowerCase();

    _ingredientAllergens.forEach((keyword, allergenGroups) {
      if (_containsWord(combinedIngredients, keyword)) {
        detected.addAll(allergenGroups);
      }
    });

    return detected.toList();
  }

  // Get emergency-level allergens that match the user's profile.
  static List<String> getEmergencyAllergens({
    required List<String> detectedAllergens,
    required List<String> userAllergies,
  }) {
    final emergencyAllergens = detectedAllergens
        .where((allergen) => userAllergies.contains(allergen))
        .toList();

    // Sort by severity (highest first) using loaded data
    emergencyAllergens.sort((a, b) {
      final severityA = _severityRanking[a] ?? 0;
      final severityB = _severityRanking[b] ?? 0;
      return severityB.compareTo(severityA);
    });

    return emergencyAllergens;
  }

  // Helper function to check for whole word matches.
  static bool _containsWord(String text, String word) {
    final pattern = RegExp('\b$word\b', caseSensitive: false);
    return pattern.hasMatch(text);
  }

  // ... (The other helper methods like getAllergenRiskLevel, generateAllergenWarnings, etc. can remain as they are, as they operate on the detected allergens list)

  static String getAllergenRiskLevel(List<String> emergencyAllergens) {
    if (emergencyAllergens.isEmpty) return 'none';
    
    final highRiskAllergens = emergencyAllergens.where((allergen) =>
        ['peanuts', 'shellfish', 'fish', 'nuts'].contains(allergen));
    
    if (highRiskAllergens.isNotEmpty) return 'high';
    if (emergencyAllergens.length > 2) return 'medium';
    return 'low';
  }

  static List<String> generateAllergenWarnings(List<String> emergencyAllergens) {
    if (emergencyAllergens.isEmpty) return [];

    final warnings = <String>[];
    
    if (emergencyAllergens.contains('peanuts')) {
      warnings.add('⚠️ Contains peanuts - High allergy risk!');
    }
    if (emergencyAllergens.contains('shellfish')) {
      warnings.add('⚠️ Contains shellfish - Severe allergy risk!');
    }
    if (emergencyAllergens.contains('nuts')) {
      warnings.add('⚠️ Contains tree nuts - High allergy risk!');
    }

    final otherAllergens = emergencyAllergens.where((allergen) =>
        !['peanuts', 'shellfish', 'nuts'].contains(allergen));
    
    if (otherAllergens.isNotEmpty) {
      warnings.add('Contains: ${otherAllergens.join(', ')}');
    }

    return warnings;
  }
}
