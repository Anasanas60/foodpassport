import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../models/user_profile.dart';

class FoodStateService with ChangeNotifier {
  FoodItem? _currentFoodItem;
  List<FoodItem> _foodHistory = [];
  UserProfile? _userProfile;

  FoodItem? get currentFoodItem => _currentFoodItem;
  List<FoodItem> get foodHistory => _foodHistory;
  UserProfile? get userProfile => _userProfile;

  void setCurrentFood(FoodItem foodItem) {
    _currentFoodItem = foodItem;
    notifyListeners();
  }

  void addToHistory(FoodItem foodItem) {
    _foodHistory.insert(0, foodItem);
    notifyListeners();
  }

  void setUserProfile(UserProfile profile) {
    _userProfile = profile;
    notifyListeners();
  }

  // Check if current food has user's allergens
  bool get hasAllergyRisk {
    if (_currentFoodItem == null || _userProfile == null) return false;
    return _currentFoodItem!.containsAllergens(_userProfile!.allergies);
  }

  // Get high-risk allergens for emergency screen
  List<String> get emergencyAllergens {
    if (_currentFoodItem == null || _userProfile == null) return [];
    return _currentFoodItem!.getHighRiskAllergens(_userProfile!.allergies);
  }

  void clearCurrentFood() {
    _currentFoodItem = null;
    notifyListeners();
  }
}