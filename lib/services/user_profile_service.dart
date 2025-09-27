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
  
  // Allergy alert sensitivity preference: 'all', 'moderate+', 'severe+'
  String _allergyAlertSensitivity = 'moderate+';

  // Getters
  String? get name => _name;
  int? get age => _age;
  List<String> get allergies => _allergies;
  String? get dietaryPreference => _dietaryPreference;
  String? get country => _country;
  String? get language => _language;
  String get allergyAlertSensitivity => _allergyAlertSensitivity;

  // UserProfile getter convenience for easy access
  UserProfile? get userProfile {
    if (_name == null && _age == null) return null;
    return UserProfile(
      name: _name,
      age: _age,
      allergies: _allergies,
      dietaryPreference: _dietaryPreference,
      country: _country,
      language: _language,
      allergyAlertSensitivity: _allergyAlertSensitivity,
    );
  }

  // Load user profile from database, including allergy alert sensitivity
  Future<void> loadUserProfile() async {
    try {
      final profile = await _dbService.getUserProfile();
      if (profile != null) {
        _name = profile['name'];
        _age = profile['age'];
        if (profile['allergies'] != null) {
          final allergiesJson = json.decode(profile['allergies']);
          _allergies = List<String>.from(allergiesJson);
        }
        _dietaryPreference = profile['dietary_preference'];
        _country = profile['country'];
        _language = profile['language'];

        _allergyAlertSensitivity = profile['allergy_alert_sensitivity'] ?? 'moderate+';

        notifyListeners();
        debugPrint('✅ User profile loaded successfully');
      }
    } catch (e) {
      debugPrint('❌ Error loading user profile: $e');
    }
  }

  // Update entire profile, including allergy alert sensitivity
  Future<void> updateProfile({
    String? name,
    int? age,
    List<String>? allergies,
    String? dietaryPreference,
    String? country,
    String? language,
    String? allergyAlertSensitivity,
  }) async {
    _name = name ?? _name;
    _age = age ?? _age;
    _allergies = allergies ?? _allergies;
    _dietaryPreference = dietaryPreference ?? _dietaryPreference;
    _country = country ?? _country;
    _language = language ?? _language;
    _allergyAlertSensitivity = allergyAlertSensitivity ?? _allergyAlertSensitivity;

    await _saveToDatabase();
    notifyListeners();
  }

  // Update allergy alert sensitivity individually
  Future<void> updateAllergyAlertSensitivity(String sensitivity) async {
    _allergyAlertSensitivity = sensitivity;
    await _saveToDatabase();
    notifyListeners();
  }

  // Update other profile fields (examples)

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

  // Save all profile fields to database including allergy alert sensitivity
  Future<void> _saveToDatabase() async {
    try {
      await _dbService.updateUserProfile({
        'name': _name,
        'age': _age,
        'allergies': json.encode(_allergies), // Store list as JSON string
        'dietary_preference': _dietaryPreference,
        'country': _country,
        'language': _language,
        'allergy_alert_sensitivity': _allergyAlertSensitivity,
      });
      debugPrint('✅ User profile saved successfully');
    } catch (e) {
      debugPrint('❌ Error saving user profile: $e');
    }
  }
}
