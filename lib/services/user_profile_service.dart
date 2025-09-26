import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'database_service.dart';
import '../models/user_profile.dart'; // Import the UserProfile model

class UserProfileService with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService();
  
  String? _name;
  int? _age;
  List<String> _allergies = [];
  String? _dietaryPreference;
  String? _country;
  String? _language;

  // Getters
  String? get name => _name;
  int? get age => _age;
  List<String> get allergies => _allergies;
  String? get dietaryPreference => _dietaryPreference;
  String? get country => _country;
  String? get language => _language;

  // NEW: Getter that returns a complete UserProfile object
  UserProfile? get userProfile {
    if (_name == null && _age == null) return null;
    
    return UserProfile(
      name: _name,
      age: _age,
      allergies: _allergies,
      dietaryPreference: _dietaryPreference,
      country: _country,
      language: _language,
    );
  }

  // Load user profile from database
  Future<void> loadUserProfile() async {
    try {
      final profile = await _dbService.getUserProfile();
      if (profile != null) {
        _name = profile['name'];
        _age = profile['age'];
        
        // Parse allergies from JSON string
        if (profile['allergies'] != null) {
          final allergiesJson = json.decode(profile['allergies']);
          _allergies = List<String>.from(allergiesJson);
        }
        
        _dietaryPreference = profile['dietary_preference'];
        _country = profile['country'];
        _language = profile['language'];
        
        notifyListeners();
        print('✅ User profile loaded successfully');
      }
    } catch (e) {
      print('❌ Error loading user profile: $e');
    }
  }

  // Update entire profile
  Future<void> updateProfile({
    String? name,
    int? age,
    List<String>? allergies,
    String? dietaryPreference,
    String? country,
    String? language,
  }) async {
    _name = name ?? _name;
    _age = age ?? _age;
    _allergies = allergies ?? _allergies;
    _dietaryPreference = dietaryPreference ?? _dietaryPreference;
    _country = country ?? _country;
    _language = language ?? _language;

    await _saveToDatabase();
    notifyListeners();
  }

  // Update individual fields
  Future<void> updateName(String name) async {
    _name = name;
    await _saveToDatabase();
    notifyListeners();
  }

  Future<void> updateAge(int age) async {
    _age = age;
    await _saveToDatabase();
    notifyListeners();
  }

  Future<void> updateAllergies(List<String> allergies) async {
    _allergies = allergies;
    await _saveToDatabase();
    notifyListeners();
  }

  Future<void> updateDietaryPreference(String preference) async {
    _dietaryPreference = preference;
    await _saveToDatabase();
    notifyListeners();
  }

  Future<void> updateCountry(String country) async {
    _country = country;
    await _saveToDatabase();
    notifyListeners();
  }

  Future<void> updateLanguage(String language) async {
    _language = language;
    await _saveToDatabase();
    notifyListeners();
  }

  // Save to database
  Future<void> _saveToDatabase() async {
    try {
      await _dbService.updateUserProfile({
        'name': _name,
        'age': _age,
        'allergies': json.encode(_allergies), // Store as JSON
        'dietary_preference': _dietaryPreference,
        'country': _country,
        'language': _language,
      });
      print('✅ User profile saved successfully');
    } catch (e) {
      print('❌ Error saving user profile: $e');
    }
  }

  // Check if profile is complete
  bool get isProfileComplete {
    return _name != null && _name!.isNotEmpty && _age != null;
  }

  // Clear profile data (for logout/reset)
  Future<void> clearProfile() async {
    _name = null;
    _age = null;
    _allergies = [];
    _dietaryPreference = null;
    _country = null;
    _language = null;
    
    await _saveToDatabase();
    notifyListeners();
  }

  // Check if user has any allergies
  bool get hasAllergies => _allergies.isNotEmpty;

  // Get profile summary for display
  Map<String, dynamic> get profileSummary {
    return {
      'name': _name ?? 'Not set',
      'age': _age ?? 'Not set',
      'allergyCount': _allergies.length,
      'dietaryPreference': _dietaryPreference ?? 'Not set',
      'country': _country ?? 'Not set',
      'language': _language ?? 'Not set',
    };
  }

  // NEW: Check if food contains user's allergens
  bool containsAllergens(List<String> foodAllergens) {
    if (_allergies.isEmpty || foodAllergens.isEmpty) return false;
    return foodAllergens.any((allergen) => _allergies.contains(allergen));
  }

  // NEW: Get matching allergens between user and food
  List<String> getMatchingAllergens(List<String> foodAllergens) {
    return foodAllergens.where((allergen) => _allergies.contains(allergen)).toList();
  }

  // NEW: Initialize with default values for testing
  void initializeWithDefaults() {
    _name = 'Food Explorer';
    _age = 25;
    _allergies = ['nuts', 'shellfish'];
    _dietaryPreference = 'Vegetarian';
    _country = 'Thailand';
    _language = 'English';
    notifyListeners();
  }

  // NEW: Check if user profile is empty
  bool get isEmpty {
    return _name == null && _age == null && _allergies.isEmpty;
  }

  // NEW: Get user initials for avatar
  String get initials {
    if (_name == null || _name!.isEmpty) return 'FP';
    final names = _name!.split(' ');
    if (names.length == 1) return _name!.substring(0, 2).toUpperCase();
    return '${names[0][0]}${names[names.length - 1][0]}'.toUpperCase();
  }
}
