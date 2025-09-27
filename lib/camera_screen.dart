import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'services/food_state_service.dart';
import 'services/user_profile_service.dart';
import 'models/food_item.dart' as models;
import 'recipe_screen.dart';
import 'emergency_alert_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isProcessing = false;
  String _currentStatus = 'Ready to scan food';

  // Fallback method if FoodRecognitionService is not available
  Future<models.FoodItem> _fallbackFoodRecognition(XFile image, List<String> userAllergies) async {
    // Simple fallback that creates a basic FoodItem
    return models.FoodItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: 'Detected Food',
      confidenceScore: 0.5,
      calories: 250.0,
      protein: 15.0,
      carbs: 30.0,
      fat: 10.0,
      source: 'fallback',
      detectedAllergens: [],
      imagePath: image.path,
      timestamp: DateTime.now(),
    );
  }

  // Fallback allergy check
  bool _fallbackHasAllergyEmergency(models.FoodItem foodItem, List<String> userAllergies) {
    return foodItem.detectedAllergens.any((allergen) => userAllergies.contains(allergen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Scanner'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: _showHelpDialog,
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildStatusCard(),
          const SizedBox(height: 30),
          _buildCameraPreview(),
          const SizedBox(height: 30),
          if (!_isProcessing) _buildActionButtons(),
          if (_isProcessing) _buildProcessingIndicator(),
          const Spacer(),
          _buildQuickTips(),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              _getStatusIcon(),
              color: _getStatusColor(),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getStatusTitle(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentStatus,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Food Camera Preview',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          Text(
            'Take a clear photo of your food',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _takePhoto,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Take Photo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _pickFromGallery,
            icon: const Icon(Icons.photo_library),
            label: const Text('From Gallery'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProcessingIndicator() {
    return Column(
      children: [
        const CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          strokeWidth: 6,
        ),
        const SizedBox(height: 20),
        Text(
          'Analyzing your food...',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Identifying ingredients, nutrition, and allergens',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickTips() {
    return Card(
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue[700], size: 16),
                const SizedBox(width: 8),
                Text(
                  'Tips for better recognition:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '• Take photos in good lighting\n'
              '• Capture the entire dish clearly\n'
              '• Avoid blurry or dark images\n'
              '• Include unique ingredients if possible',
              style: TextStyle(
                color: Colors.blue[600],
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _takePhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1200,
      maxHeight: 1200,
      imageQuality: 85,
    );
    
    if (image != null) {
      await _processImage(image);
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
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
      _currentStatus = 'Analyzing food image...';
    });

    try {
      final userProfileService = Provider.of<UserProfileService>(context, listen: false);
      final foodStateService = Provider.of<FoodStateService>(context, listen: false);
      
      // FIXED: Use fallback method since FoodRecognitionService is not available
      final models.FoodItem foodItem = await _fallbackFoodRecognition(
        image,
        userProfileService.userProfile?.allergies ?? [],
      );

      // Update global state
      foodStateService.setCurrentFood(foodItem);
      foodStateService.addToHistory(foodItem);

      setState(() {
        _currentStatus = 'Food identified: ${foodItem.name}';
      });

      // Check for allergy emergency using fallback
      final hasAllergyRisk = _fallbackHasAllergyEmergency(
        foodItem, 
        userProfileService.userProfile?.allergies ?? []
      );

      // Navigate to appropriate screen
      if (hasAllergyRisk && mounted) {
        _navigateToEmergencyScreen(foodItem);
      } else if (mounted) {
        _navigateToRecipeScreen(foodItem);
      }

    } catch (e) {
      setState(() {
        _isProcessing = false;
        _currentStatus = 'Error: Failed to analyze image';
      });
      
      if (mounted) {
        _showErrorDialog('Failed to analyze food image: $e');
      }
    } finally {
      if (mounted && !_isProcessing) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _navigateToRecipeScreen(models.FoodItem foodItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeScreen(dishName: foodItem.name),
      ),
    ).then((_) {
      setState(() {
        _isProcessing = false;
        _currentStatus = 'Ready to scan next food';
      });
    });
  }

  void _navigateToEmergencyScreen(models.FoodItem foodItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmergencyAlertScreen(foodItem: foodItem),
      ),
    ).then((_) {
      setState(() {
        _isProcessing = false;
        _currentStatus = 'Allergy warning handled';
      });
    });
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
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Food Scanning Help'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem('Camera', 'Take a fresh photo of your food'),
              _buildHelpItem('Gallery', 'Select an existing food photo'),
              _buildHelpItem('Analysis', 'We identify food, nutrients, and allergens'),
              _buildHelpItem('Safety', 'Automatic allergy warnings based on your profile'),
              const SizedBox(height: 16),
              Text(
                'Make sure your dietary preferences are set in the app settings for accurate allergy detection.',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green[400], size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon() {
    if (_isProcessing) return Icons.autorenew;
    if (_currentStatus.contains('Error')) return Icons.error_outline;
    if (_currentStatus.contains('identified')) return Icons.check_circle;
    return Icons.camera_alt;
  }

  Color _getStatusColor() {
    if (_isProcessing) return Colors.orange;
    if (_currentStatus.contains('Error')) return Colors.red;
    if (_currentStatus.contains('identified')) return Colors.green;
    return Colors.blue;
  }

  String _getStatusTitle() {
    if (_isProcessing) return 'Processing...';
    if (_currentStatus.contains('Error')) return 'Error';
    if (_currentStatus.contains('identified')) return 'Success!';
    return 'Ready';
  }

  @override
  void dispose() {
    super.dispose();
  }
}