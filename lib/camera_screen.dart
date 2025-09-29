import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../models/food_item.dart' as models;
import 'emergency_alert_screen.dart';
import '../services/user_profile_service.dart';
import '../services/nutritionix_service.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({super.key, required this.camera});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isProcessing = false;
  bool _isImageCaptured = false;
  XFile? _capturedImage;
  String? _detectedDish;
  String? _detectedText;
  List<String> _detectedAllergens = [];
  bool _isTranslateMode = false;

  final NutritionixService _nutritionixService = NutritionixService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _controller = CameraController(widget.camera, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _controller = CameraController(widget.camera, ResolutionPreset.high);
      _initializeControllerFuture = _controller.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (_isImageCaptured && _capturedImage != null) {
                  return SizedBox.expand(
                    child: Image.file(
                      File(_capturedImage!.path),
                      fit: BoxFit.cover,
                    ),
                  );
                }
                return CameraPreview(_controller);
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
          _buildHeaderOverlay(colorScheme),
          _buildRealTimeOverlays(),
          _buildBottomActionBar(colorScheme),
          if (_isImageCaptured && _capturedImage != null)
            _buildPostScanSheet(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeaderOverlay(ColorScheme colorScheme) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.7),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              const Text(
                'foodpassport',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.flash_on, color: Colors.white),
                onPressed: _toggleFlash,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRealTimeOverlays() {
    return Positioned.fill(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_detectedDish != null && !_isTranslateMode)
            _buildDishRecognitionOverlay(),
          if (_detectedText != null && _isTranslateMode)
            _buildTextTranslationOverlay(),
          if (_detectedAllergens.isNotEmpty) _buildAllergyAlertOverlay(),
        ],
      ),
    );
  }

  Widget _buildDishRecognitionOverlay() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.restaurant, color: Theme.of(context).colorScheme.primary, size: 16),
          const SizedBox(width: 8),
          Text(
            _detectedDish!,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextTranslationOverlay() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Translated',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _detectedText!,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergyAlertOverlay() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            'Contains: ${_detectedAllergens.join(', ')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActionBar(ColorScheme colorScheme) {
    if (_isImageCaptured) return const SizedBox.shrink();

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModeButton(
                    icon: Icons.restaurant,
                    label: 'Dish ID',
                    isActive: !_isTranslateMode,
                    onTap: () => setState(() => _isTranslateMode = false),
                  ),
                  const SizedBox(width: 16),
                  _buildModeButton(
                    icon: Icons.translate,
                    label: 'Translate',
                    isActive: _isTranslateMode,
                    onTap: () => setState(() => _isTranslateMode = true),
                  ),
                ],
              ),
            ),
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 32, color: Colors.white),
                onPressed: _isProcessing ? null : _takePhoto,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? Theme.of(context).colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: isActive ? Colors.white : Colors.white70),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostScanSheet(BuildContext context, ColorScheme colorScheme) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ListView(
              controller: scrollController,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_detectedDish != null) _buildAchievementNotification(),
                const SizedBox(height: 16),
                if (_detectedDish != null) _buildDishInfoSection(),
                if (_detectedText != null) _buildTranslationSection(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() {
                          _isImageCaptured = false;
                          _capturedImage = null;
                          _detectedDish = null;
                          _detectedText = null;
                          _detectedAllergens.clear();
                        }),
                        child: const Text('Retake'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveToJournal,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Save to Journal'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementNotification() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.celebration, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Dish Identified! +10 XP',
              style: TextStyle(
                color: Color(0xFF333333),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDishInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _detectedDish!,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        if (_detectedAllergens.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Detected Ingredients:', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _detectedAllergens
                    .map((allergen) => Chip(label: Text(allergen), backgroundColor: Colors.grey[100]))
                    .toList(),
              ),
            ],
          ),
        const SizedBox(height: 16),
        const Text('Nutrition Information:', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Row(
          children: [
            NutritionInfoItem(label: 'Calories', value: '250'),
            SizedBox(width: 16),
            NutritionInfoItem(label: 'Protein', value: '15g'),
            SizedBox(width: 16),
            NutritionInfoItem(label: 'Carbs', value: '30g'),
          ],
        ),
      ],
    );
  }

  Widget _buildTranslationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Translated Text:', style: TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(_detectedText!),
        ),
      ],
    );
  }

  Future<void> _takePhoto() async {
    if (!_controller.value.isInitialized) return;
    setState(() {
      _isProcessing = true;
    });
    try {
      final image = await _controller.takePicture();
      _capturedImage = image;
      _isImageCaptured = true;

      final recognizedText = await recognizeTextFromImage(image.path);
      final queryText = recognizedText.isNotEmpty ? recognizedText : "unknown food";

      final apiResult = await _nutritionixService.searchFood(queryText);

      final foods = apiResult['foods'] as List<dynamic>?;
      final detectedDish = (foods != null && foods.isNotEmpty) ? (foods[0]['food_name'] as String) : queryText;

      final detectedAllergens = <String>[];
      if (foods != null && foods.isNotEmpty) {
        final food = foods[0];
        final String ingredients = (food['nf_ingredient_statement'] ?? '').toLowerCase();

        if (ingredients.contains('egg')) detectedAllergens.add('eggs');
        if (ingredients.contains('milk') || ingredients.contains('dairy')) detectedAllergens.add('dairy');
        if (ingredients.contains('gluten')) detectedAllergens.add('gluten');
      }

      setState(() {
        if (_isTranslateMode) {
          _detectedText = detectedDish;
          _detectedDish = null;
        } else {
          _detectedDish = detectedDish;
          _detectedText = null;
        }
        _detectedAllergens = detectedAllergens;
        _checkUserAllergies();
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('Failed to analyze image: $e');
    }
  }

  Future<String> recognizeTextFromImage(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final textRecognizer = TextRecognizer();

    final recognizedText = await textRecognizer.processImage(inputImage);
    await textRecognizer.close();

    return recognizedText.text;
  }

  void _toggleFlash() {
    if (!_controller.value.isInitialized) return;
    _controller.setFlashMode(_controller.value.flashMode == FlashMode.torch ? FlashMode.off : FlashMode.torch);
    setState(() {});
  }

  void _checkUserAllergies() {
    final userProfileService = Provider.of<UserProfileService>(context, listen: false);
    final userProfile = userProfileService.userProfile;
    if (userProfile != null) {
      final userAllergies = userProfile.allergies;
      final matchingAllergens = _detectedAllergens.where((a) => userAllergies.contains(a)).toList();
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
      name: _detectedDish ?? _detectedText ?? 'Unknown Dish',
      confidenceScore: 0.8,
      calories: 0.0,
      protein: 0.0,
      carbs: 0.0,
      fat: 0.0,
      source: 'camera',
      detectedAllergens: _detectedAllergens,
      imagePath: _capturedImage?.path ?? '',
      timestamp: DateTime.now(),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EmergencyAlertScreen(foodItem: foodItem)),
    );
  }

  void _saveToJournal() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved to Food Journal')));
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) =>
          AlertDialog(title: const Text('Analysis Failed'), content: Text(message), actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
      ]),
    );
  }
}

class NutritionInfoItem extends StatelessWidget {
  final String label;
  final String value;

  const NutritionInfoItem({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
