import 'package:flutter/material.dart';
import '../models/food_item.dart';
import '../services/allergy_service.dart';
import '../services/user_profile_service.dart';

class FoodRecognitionViewModel extends ChangeNotifier {
  final AllergyService allergyService;
  final UserProfileService userProfileService;

  List<FoodItem> _filteredFoodItems = [];
  List<FoodItem> get filteredFoodItems => _filteredFoodItems;

  FoodRecognitionViewModel({
    required this.allergyService,
    required this.userProfileService,
  });

  Future<void> filterFoodItemsByAllergySensitivity(List<FoodItem> recognizedFoodItems) async {
    final allAllergies = await allergyService.getAllergies();

    _filteredFoodItems = recognizedFoodItems.map((foodItem) {
      final detectedAllergyObjects = allAllergies.where((allergy) =>
          foodItem.detectedAllergens.contains(allergy.name.toLowerCase())).toList();

      final filteredAllergyObjects = allergyService.filterAllergyAlerts(detectedAllergyObjects, userProfileService);
      
      return foodItem.copyWith(
        detectedAllergens: filteredAllergyObjects.map((a) => a.name).toList(),
      );
    }).toList();

    notifyListeners();
  }
}
