import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';

import '../models/food_item.dart' as models;
import '../services/nutritionix_service.dart';
import '../services/user_profile_service.dart';
import '../utils/allergen_checker.dart';
import '../emergency_alert_screen.dart';

class CameraViewModel extends ChangeNotifier {
  final BuildContext context;
  final CameraDescription camera;
  late CameraController cameraController;
  late Future<void> initializeControllerFuture;

  bool isProcessing = false;
  bool isImageCaptured = false;
  XFile? capturedImage;
  String? detectedDish;
  String? detectedText;
  List<String> detectedAllergens = [];
  bool isTranslateMode = false;

  final NutritionixService _nutritionixService = NutritionixService();

  CameraViewModel(this.context, this.camera) {
    cameraController = CameraController(camera, ResolutionPreset.high);
    initializeControllerFuture = cameraController.initialize();
  }

  void toggleTranslateMode() {
    isTranslateMode = !isTranslateMode;
    notifyListeners();
  }

  void retakePhoto() {
    isImageCaptured = false;
    capturedImage = null;
    detectedDish = null;
    detectedText = null;
    detectedAllergens.clear();
    notifyListeners();
  }

  Future<void> takePhoto() async {
    if (!cameraController.value.isInitialized) return;
    isProcessing = true;
    notifyListeners();

    try {
      final image = await cameraController.takePicture();
      capturedImage = image;
      isImageCaptured = true;

      final recognizedText = await _recognizeTextFromImage(image.path);
      final queryText = recognizedText.isNotEmpty ? recognizedText : "unknown food";

      final apiResult = await _nutritionixService.searchFood(queryText);

      final foods = apiResult['foods'] as List<dynamic>?;
      final detectedDishName = (foods != null && foods.isNotEmpty) ? (foods[0]['food_name'] as String) : queryText;

      final List<String> ingredients = [];
      if (foods != null && foods.isNotEmpty) {
        final food = foods[0];
        final String ingredientStatement = (food['nf_ingredient_statement'] ?? '').toLowerCase();
        ingredients.addAll(ingredientStatement.split(',').map((e) => e.trim()));
      }
      
      detectedAllergens = AllergenChecker.detectAllergens(ingredients: ingredients);

      if (isTranslateMode) {
        detectedText = detectedDishName;
        detectedDish = null;
      } else {
        detectedDish = detectedDishName;
        detectedText = null;
      }

      _checkUserAllergies();
    } catch (e) {
      _showErrorDialog('Failed to analyze image: $e');
    } finally {
      isProcessing = false;
      notifyListeners();
    }
  }

  Future<String> _recognizeTextFromImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer();
    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();
    return recognizedText.text;
  }

  void toggleFlash() {
    if (!cameraController.value.isInitialized) return;
    cameraController.setFlashMode(
      cameraController.value.flashMode == FlashMode.torch ? FlashMode.off : FlashMode.torch,
    );
    notifyListeners();
  }

  void _checkUserAllergies() {
    final userProfileService = Provider.of<UserProfileService>(context, listen: false);
    final userProfile = userProfileService.userProfile;
    if (userProfile != null) {
      final userAllergies = userProfile.allergies;
      final matchingAllergens = detectedAllergens.where((a) => userAllergies.contains(a)).toList();
      if (matchingAllergens.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToEmergencyScreen();
        });
      }
    }
  }

  void _navigateToEmergencyScreen() {
    final foodItem = models.FoodItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: detectedDish ?? detectedText ?? 'Unknown Dish',
      confidenceScore: 0.8,
      calories: 0.0,
      protein: 0.0,
      carbs: 0.0,
      fat: 0.0,
      source: 'camera',
      detectedAllergens: detectedAllergens,
      imagePath: capturedImage?.path ?? '',
      timestamp: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmergencyAlertScreen(foodItem: foodItem)),
    );
  }

  void saveToJournal() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Saved to Food Journal')),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analysis Failed'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
        ],
      ),
    );
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      cameraController = CameraController(camera, ResolutionPreset.high);
      initializeControllerFuture = cameraController.initialize();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}
