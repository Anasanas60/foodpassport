import 'package:flutter/foundation.dart';
import '../models/food_item.dart';

class FoodStateService with ChangeNotifier {
  List<FoodItem> _foodHistory = [];
  FoodItem? _currentFoodItem;
  bool _hasAllergyRisk = false;
  dynamic _userProfile;

  List<FoodItem> get foodHistory => _foodHistory;
  FoodItem? get currentFoodItem => _currentFoodItem;
  bool get hasAllergyRisk => _hasAllergyRisk;
  dynamic get userProfile => _userProfile;

  void setCurrentFood(FoodItem foodItem) {
    _currentFoodItem = foodItem;
    notifyListeners();
  }

  void addToHistory(FoodItem foodItem) {
    _foodHistory.insert(0, foodItem);
    notifyListeners();
  }

  void removeFromHistory(int index) {
    if (index >= 0 && index < _foodHistory.length) {
      _foodHistory.removeAt(index);
      notifyListeners();
    }
  }

  void clearHistory() {
    _foodHistory.clear();
    notifyListeners();
  }

  void setAllergyRisk(bool risk) {
    _hasAllergyRisk = risk;
    notifyListeners();
  }

  void setUserProfile(dynamic profile) {
    _userProfile = profile;
    notifyListeners();
  }
}
