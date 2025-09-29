import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/food_item.dart' as models;
import 'emergency_alert_screen.dart';
import '../services/user_profile_service.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isProcessing = false;
  bool _isImageCaptured = false;
  File? _capturedImage;
  String? _detectedDish;
  String? _detectedText;
  List<String> _detectedAllergens = [];
  bool _isTranslateMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview/Image Background
          _buildCameraPreview(),
          
          // Semi-transparent UI Overlays
          _buildHeaderOverlay(colorScheme),
          _buildRealTimeOverlays(),
          _buildBottomActionBar(colorScheme),
          
          // Post-Scan Results Sheet
          if (_isImageCaptured && _capturedImage != null)
            _buildPostScanSheet(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildCameraPreview() {
    if (_isImageCaptured && _capturedImage != null) {
      // Show captured image
      return Container(
        width: double.infinity,
        height: double.infinity,
        child: Image.file(
          _capturedImage!,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // Show camera placeholder (in real app, this would be live camera feed)
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey[900],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_camera,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Camera Preview',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            Text(
              'Point camera at food or menu',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
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
              Colors.black.withAlpha(178), // 0.7 opacity
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
              Text(
                'foodpassport',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: Icon(
                  Icons.flash_on,
                  color: Colors.white,
                ),
                onPressed: () {
                  // Toggle flash
                },
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
          // Dish Recognition Overlay
          if (_detectedDish != null && !_isTranslateMode)
            _buildDishRecognitionOverlay(),
          
          // Text Translation Overlay
          if (_detectedText != null && _isTranslateMode)
            _buildTextTranslationOverlay(),
          
          // Allergy Alert Overlay
          if (_detectedAllergens.isNotEmpty)
            _buildAllergyAlertOverlay(),
        ],
      ),
    );
  }

  Widget _buildDishRecognitionOverlay() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(229), // 0.9 opacity
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.restaurant,
            color: Theme.of(context).colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            _detectedDish!,
            style: TextStyle(
              color: const Color(0xFF333333),
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
        color: Colors.white.withAlpha(229), // 0.9 opacity
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
            child: Text(
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
            style: TextStyle(
              color: const Color(0xFF333333),
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
        color: Colors.red.withAlpha(229), // 0.9 opacity
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            'Contains: ${_detectedAllergens.join(', ')}',
            style: TextStyle(
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
              Colors.black.withAlpha(204), // 0.8 opacity
              Colors.transparent,
            ],
          ),
        ),
        child: Column(
          children: [
            // Mode Toggle
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(51), // 0.2 opacity
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
            
            // Shutter Button
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: IconButton(
                icon: Icon(Icons.camera_alt, size: 32, color: Colors.white),
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
                color: Colors.black.withAlpha(51), // 0.2 opacity
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
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
                
                // Achievement Notification
                if (_detectedDish != null)
                  _buildAchievementNotification(),
                
                const SizedBox(height: 16),
                
                // Dish Info
                if (_detectedDish != null)
                  _buildDishInfoSection(),
                
                // Translation Info
                if (_detectedText != null)
                  _buildTranslationSection(),
                
                const Spacer(),
                
                // Action Buttons
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
        color: Theme.of(context).colorScheme.primary.withAlpha(25), // 0.1 opacity
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
          Expanded(
            child: Text(
              'Dish Identified! +10 XP',
              style: TextStyle(
                color: const Color(0xFF333333),
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
        
        // Ingredients
        if (_detectedAllergens.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Detected Ingredients:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _detectedAllergens.map((allergen) => Chip(
                  label: Text(allergen),
                  backgroundColor: Colors.grey[100],
                )).toList(),
              ),
            ],
          ),
        
        const SizedBox(height: 16),
        
        // Nutrition Info (placeholder)
        const Text(
          'Nutrition Information:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
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
        const Text(
          'Translated Text:',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary.withAlpha(25), // 0.1 opacity
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(_detectedText!),
        ),
      ],
    );
  }

  Future<void> _takePhoto() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    
    if (image != null) {
      await _processImage(image);
    }
  }

  Future<void> _processImage(XFile image) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      _capturedImage = File(image.path);
      
      // Simulate AI processing with mock data
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock detection results
      setState(() {
        _isImageCaptured = true;
        _isProcessing = false;
        
        if (_isTranslateMode) {
          _detectedText = 'Grilled Salmon with Lemon Butter Sauce';
          _detectedAllergens = ['fish', 'dairy'];
        } else {
          _detectedDish = 'French Crêpe';
          _detectedAllergens = ['eggs', 'dairy', 'gluten'];
        }
        
        // Check for user allergies
        _checkUserAllergies();
      });
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showErrorDialog('Failed to analyze image: $e');
    }
  }

  void _checkUserAllergies() {
    final userProfileService = Provider.of<UserProfileService>(context, listen: false);
    final userProfile = userProfileService.userProfile;
    
    if (userProfile != null) {
      final userAllergies = userProfile.allergies;
      final matchingAllergens = _detectedAllergens.where(
        (allergen) => userAllergies.contains(allergen)
      ).toList();
      
      if (matchingAllergens.isNotEmpty) {
        // Show emergency alert
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _navigateToEmergencyScreen();
        });
      }
    }
  }

  void _navigateToEmergencyScreen() {
    final foodItem = models.FoodItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _detectedDish ?? 'Unknown Dish',
      confidenceScore: 0.8,
      calories: 0.0,
      protein: 0.0,
      carbs: 0.0,
      fat: 0.0,
      source: 'camera',
      detectedAllergens: _detectedAllergens,
      imagePath: _capturedImage?.path ?? '', // FIXED: Provide empty string as fallback
      timestamp: DateTime.now(),
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmergencyAlertScreen(foodItem: foodItem),
      ),
    );
  }

  void _saveToJournal() {
    // Implement save to journal functionality
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK')
          ),
        ],
      ),
    );
  }
}

class NutritionInfoItem extends StatelessWidget {
  final String label;
  final String value;

  const NutritionInfoItem({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}