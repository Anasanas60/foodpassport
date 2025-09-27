import 'package:flutter/foundation.dart';
import '../models/food_item.dart';

class FoodStateService with ChangeNotifier {
  FoodItem? _currentFoodItem;
  final List<FoodItem> _foodHistory = [];

  FoodItem? get currentFoodItem => _currentFoodItem;
  List<FoodItem> get foodHistory => List.unmodifiable(_foodHistory);

  void setCurrentFood(FoodItem foodItem) {
    _currentFoodItem = foodItem;
    notifyListeners();
  }

  void addToHistory(FoodItem foodItem) {
    _foodHistory.insert(0, foodItem);
    if (_foodHistory.length > 100) {
      _foodHistory.removeLast();
    }
    notifyListeners();
  }

  void removeFromHistory(int index) {
    if (index >= 0 && index < _foodHistory.length) {
      _foodHistory.removeAt(index);
      notifyListeners();
    }
  }

  void updateFoodAt(int index, FoodItem updatedFoodItem) {
    if (index >= 0 && index < _foodHistory.length) {
      _foodHistory[index] = updatedFoodItem;
      notifyListeners();
    }
  }

  void clearHistory() {
    _foodHistory.clear();
    notifyListeners();
  }
}
