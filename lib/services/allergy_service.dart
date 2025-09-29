import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/allergy.dart';
import '../utils/logger.dart';

class AllergyService {
  static const String _fallbackApiUrl = 'https://my-json-server.typicode.com/foodallergy/db/allergies';

  static final List<Allergy> _fallbackAllergies = [
    Allergy(id: '1', name: 'nuts', category: 'tree_nut', description: 'Tree nuts and peanuts', severity: AllergySeverity.severe, isCommon: true),
    Allergy(id: '2', name: 'dairy', category: 'dairy', description: 'Milk and dairy products', severity: AllergySeverity.moderate, isCommon: true),
    Allergy(id: '3', name: 'gluten', category: 'grain', description: 'Wheat, barley, rye gluten', severity: AllergySeverity.moderate, isCommon: true),
    Allergy(id: '4', name: 'shellfish', category: 'seafood', description: 'Shrimp, crab, lobster', severity: AllergySeverity.severe, isCommon: true),
    Allergy(id: '5', name: 'eggs', category: 'egg', description: 'Chicken eggs and products', severity: AllergySeverity.moderate, isCommon: true),
    Allergy(id: '6', name: 'soy', category: 'legume', description: 'Soybeans and soy products', severity: AllergySeverity.mild, isCommon: true),
    Allergy(id: '7', name: 'fish', category: 'seafood', description: 'Fin fish', severity: AllergySeverity.severe, isCommon: true),
    Allergy(id: '8', name: 'sesame', category: 'seed', description: 'Sesame seeds and oil', severity: AllergySeverity.moderate, isCommon: true),
    Allergy(id: '9', name: 'mustard', category: 'spice', description: 'Mustard seeds and condiments', severity: AllergySeverity.moderate, isCommon: false),
    Allergy(id: '10', name: 'celery', category: 'vegetable', description: 'Celery and celeriac', severity: AllergySeverity.mild, isCommon: false),
  ];

  Future<List<Allergy>> getAllergies({String searchQuery = ''}) async {
    try {
      final response = await http.get(
        Uri.parse('$_fallbackApiUrl?q=$searchQuery'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Allergy.fromJson(item)).toList();
      } else {
        return _getFilteredFallbackAllergies(searchQuery);
      }
    } catch (e) {
      logger.severe('Allergy API error: $e');
      return _getFilteredFallbackAllergies(searchQuery);
    }
  }

  Future<List<Allergy>> searchAllergies(String query) async {
    if (query.isEmpty) return await getAllergies();

    final allergies = await getAllergies();
    final lowerQuery = query.toLowerCase();
    return allergies.where((allergy) {
      return allergy.name.toLowerCase().contains(lowerQuery) ||
          allergy.category.toLowerCase().contains(lowerQuery) ||
          allergy.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  Future<List<Allergy>> getCommonAllergies() async {
    final allergies = await getAllergies();
    return allergies.where((allergy) => allergy.isCommon).toList();
  }

  Future<Map<String, List<Allergy>>> getAllergiesByCategory() async {
    final allergies = await getAllergies();
    final Map<String, List<Allergy>> categorized = {};

    for (final allergy in allergies) {
      categorized.putIfAbsent(allergy.category, () => []);
      categorized[allergy.category]!.add(allergy);
    }

    return categorized;
  }

  Future<bool> validateAllergy(String allergyName) async {
    if (allergyName.isEmpty) return false;

    final allergies = await getAllergies();
    return allergies.any(
        (allergy) => allergy.name.toLowerCase() == allergyName.toLowerCase());
  }

  Future<Allergy> addCustomAllergy(String name, {String category = 'other'}) async {
    final newAllergy = Allergy(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.toLowerCase(),
      category: category,
      description: 'Custom allergy: $name',
      severity: AllergySeverity.moderate,
      isCommon: false,
    );

    await Future.delayed(const Duration(milliseconds: 500));
    return newAllergy;
  }

  List<Allergy> _getFilteredFallbackAllergies(String searchQuery) {
    if (searchQuery.isEmpty) return _fallbackAllergies;

    final lowerQuery = searchQuery.toLowerCase();
    return _fallbackAllergies.where((allergy) {
      return allergy.name.toLowerCase().contains(lowerQuery) ||
          allergy.category.toLowerCase().contains(lowerQuery) ||
          allergy.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  String getSeverityDescription(String severity) {
    switch (severity.toLowerCase()) {
      case 'severe':
        return 'Life-threatening reaction possible';
      case 'moderate':
        return 'Significant discomfort or reaction';
      case 'mild':
        return 'Minor discomfort or reaction';
      default:
        return 'Reaction severity unknown';
    }
  }

  List<String> getAllergyCategories() {
    return [
      'tree_nut', 'dairy', 'grain', 'seafood', 'egg',
      'legume', 'seed', 'spice', 'vegetable', 'fruit', 'other'
    ];
  }

  String getCategoryDisplayName(String category) {
    final categoryNames = {
      'tree_nut': 'Nuts',
      'dairy': 'Dairy',
      'grain': 'Grains',
      'seafood': 'Seafood',
      'egg': 'Eggs',
      'legume': 'Legumes',
      'seed': 'Seeds',
      'spice': 'Spices',
      'vegetable': 'Vegetables',
      'fruit': 'Fruits',
      'other': 'Other',
    };
    return categoryNames[category] ?? 'Other';
  }

  List<Allergy> filterAllergyAlerts(List<Allergy> detectedAllergies, dynamic userProfileService) {
    final String sensitivity = (userProfileService.allergyAlertSensitivity ?? 'moderate+').toLowerCase();

    if (sensitivity == 'all') {
      return detectedAllergies;
    } else if (sensitivity == 'moderate+') {
      return detectedAllergies.where((a) =>
          a.severity == AllergySeverity.severe || a.severity == AllergySeverity.moderate).toList();
    } else if (sensitivity == 'severe+') {
      return detectedAllergies.where((a) => a.severity == AllergySeverity.severe).toList();
    } else {
      return detectedAllergies.where((a) =>
          a.severity == AllergySeverity.severe || a.severity == AllergySeverity.moderate).toList();
    }
  }
}
