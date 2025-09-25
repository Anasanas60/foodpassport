import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/allergy.dart';

class AllergyService {
  static const String _baseUrl = 'https://api.foodallergydatabase.com/v1';
  static const String _fallbackApiUrl = 'https://my-json-server.typicode.com/foodallergy/db/allergies';
  
  // Fallback data for when API is unavailable
  static final List<Allergy> _fallbackAllergies = [
    Allergy(
      id: '1',
      name: 'nuts',
      category: 'tree_nut',
      description: 'Tree nuts and peanuts',
      severity: 'severe',
      isCommon: true,
    ),
    Allergy(
      id: '2',
      name: 'dairy',
      category: 'dairy',
      description: 'Milk and dairy products',
      severity: 'moderate',
      isCommon: true,
    ),
    Allergy(
      id: '3',
      name: 'gluten',
      category: 'grain',
      description: 'Wheat, barley, rye gluten',
      severity: 'moderate',
      isCommon: true,
    ),
    Allergy(
      id: '4',
      name: 'shellfish',
      category: 'seafood',
      description: 'Shrimp, crab, lobster',
      severity: 'severe',
      isCommon: true,
    ),
    Allergy(
      id: '5',
      name: 'eggs',
      category: 'egg',
      description: 'Chicken eggs and products',
      severity: 'moderate',
      isCommon: true,
    ),
    Allergy(
      id: '6',
      name: 'soy',
      category: 'legume',
      description: 'Soybeans and soy products',
      severity: 'mild',
      isCommon: true,
    ),
    Allergy(
      id: '7',
      name: 'fish',
      category: 'seafood',
      description: 'Fin fish',
      severity: 'severe',
      isCommon: true,
    ),
    Allergy(
      id: '8',
      name: 'sesame',
      category: 'seed',
      description: 'Sesame seeds and oil',
      severity: 'moderate',
      isCommon: true,
    ),
    Allergy(
      id: '9',
      name: 'mustard',
      category: 'spice',
      description: 'Mustard seeds and condiments',
      severity: 'moderate',
      isCommon: false,
    ),
    Allergy(
      id: '10',
      name: 'celery',
      category: 'vegetable',
      description: 'Celery and celeriac',
      severity: 'mild',
      isCommon: false,
    ),
  ];

  // Fetch allergies from API with fallback
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
        // If API fails, return fallback data
        return _getFilteredFallbackAllergies(searchQuery);
      }
    } catch (e) {
      print('❌ Allergy API error: $e');
      // Return filtered fallback data on error
      return _getFilteredFallbackAllergies(searchQuery);
    }
  }

  // Search allergies with intelligent matching
  Future<List<Allergy>> searchAllergies(String query) async {
    if (query.isEmpty) {
      return await getAllergies();
    }

    final allergies = await getAllergies();
    return allergies.where((allergy) {
      final nameMatch = allergy.name.toLowerCase().contains(query.toLowerCase());
      final categoryMatch = allergy.category.toLowerCase().contains(query.toLowerCase());
      final descriptionMatch = allergy.description.toLowerCase().contains(query.toLowerCase());
      
      return nameMatch || categoryMatch || descriptionMatch;
    }).toList();
  }

  // Get common allergies (for quick selection)
  Future<List<Allergy>> getCommonAllergies() async {
    final allergies = await getAllergies();
    return allergies.where((allergy) => allergy.isCommon).toList();
  }

  // Get allergies by category
  Future<Map<String, List<Allergy>>> getAllergiesByCategory() async {
    final allergies = await getAllergies();
    final Map<String, List<Allergy>> categorized = {};
    
    for (final allergy in allergies) {
      if (!categorized.containsKey(allergy.category)) {
        categorized[allergy.category] = [];
      }
      categorized[allergy.category]!.add(allergy);
    }
    
    return categorized;
  }

  // Validate if a custom allergy exists in database
  Future<bool> validateAllergy(String allergyName) async {
    if (allergyName.isEmpty) return false;
    
    final allergies = await getAllergies();
    return allergies.any((allergy) => 
        allergy.name.toLowerCase() == allergyName.toLowerCase());
  }

  // Add a custom allergy (simulate API call)
  Future<Allergy> addCustomAllergy(String name, {String category = 'other'}) async {
    // In a real app, this would POST to your API
    final newAllergy = Allergy(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name.toLowerCase(),
      category: category,
      description: 'Custom allergy: $name',
      severity: 'moderate',
      isCommon: false,
    );

    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    return newAllergy;
  }

  // Helper method to filter fallback allergies
  List<Allergy> _getFilteredFallbackAllergies(String searchQuery) {
    if (searchQuery.isEmpty) {
      return _fallbackAllergies;
    }
    
    return _fallbackAllergies.where((allergy) {
      return allergy.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
             allergy.category.toLowerCase().contains(searchQuery.toLowerCase()) ||
             allergy.description.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  // Get allergy severity information
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

  // Get allergy categories for UI
  List<String> getAllergyCategories() {
    return [
      'tree_nut', 'dairy', 'grain', 'seafood', 'egg', 
      'legume', 'seed', 'spice', 'vegetable', 'fruit', 'other'
    ];
  }

  // Get display name for category
  String getCategoryDisplayName(String category) {
    final Map<String, String> categoryNames = {
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
}