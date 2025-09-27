import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../models/food_item.dart' as models;
import '../viewmodels/food_recognition_viewmodel.dart';
import 'emergency_alert_screen.dart';
import '../config/api_config.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  bool _isProcessing = false;
  String _currentStatus = 'Ready to scan food';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Scanner'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
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
          Text(_currentStatus,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 30),
          _buildActionButtons(),
          const SizedBox(height: 30),
          _isProcessing
              ? const Center(child: CircularProgressIndicator())
              : _buildFilteredFoodList(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isProcessing ? null : _takePhoto,
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
            onPressed: _isProcessing ? null : _pickFromGallery,
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

  Widget _buildFilteredFoodList() {
    return Expanded(
      child: Consumer<FoodRecognitionViewModel>(
        builder: (context, viewModel, child) {
          final filteredItems = viewModel.filteredFoodItems;
          if (filteredItems.isEmpty) {
            return const Center(child: Text('No food identified yet'));
          }
          return ListView.builder(
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('Allergens: ${item.detectedAllergens.join(', ')}'),
                onTap: () => _navigateToEmergencyScreen(item),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _takePhoto() async {
    final image = await _imagePicker.pickImage(
        source: ImageSource.camera, maxWidth: 1200, maxHeight: 1200, imageQuality: 85);
    if (image != null) {
      await _processImage(image);
    }
  }

  Future<void> _pickFromGallery() async {
    final image = await _imagePicker.pickImage(
        source: ImageSource.gallery, maxWidth: 1200, maxHeight: 1200, imageQuality: 85);
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
      final recognizedFoodItems = await _analyzeFoodImage(image.path);
      final viewModel = Provider.of<FoodRecognitionViewModel>(context, listen: false);
      await viewModel.filterFoodItemsByAllergySensitivity(recognizedFoodItems);

      setState(() {
        _currentStatus = 'Food identified';
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _currentStatus = 'Failed to analyze image.';
      });
      _showErrorDialog('Failed to analyze image: $e');
    }
  }

  Future<List<models.FoodItem>> _analyzeFoodImage(String imagePath) async {
    final url = Uri.parse(
        '${ApiConfig.spoonacularBaseUrl}/food/images/analyze?apiKey=${ApiConfig.spoonacularApiKey}');
    final bytes = await XFile(imagePath).readAsBytes();
    final base64Image = base64Encode(bytes);

    final response = await http.post(url,
        body: jsonEncode({'image': {'data': base64Image}, 'model': 'food-recognition'}),
        headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final dishName = (data['classifiers'] != null && data['classifiers'].isNotEmpty)
          ? data['classifiers'][0]['tagName'] ?? 'Unknown Dish'
          : 'Unknown Dish';

      final ingredientsList = <String>[];
      if (data['ingredients'] != null && data['ingredients'] is List) {
        for (var ingredient in data['ingredients']) {
          final name = ingredient['name'] ?? '';
          if (name.isNotEmpty) ingredientsList.add(name);
        }
      }

      return [
        models.FoodItem(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: dishName,
          confidenceScore: data['probability']?.toDouble() ?? 0.8,
          calories: 0.0,
          protein: 0.0,
          carbs: 0.0,
          fat: 0.0,
          source: 'spoonacular',
          detectedAllergens: ingredientsList,
          imagePath: imagePath,
          timestamp: DateTime.now(),
        )
      ];
    } else {
      throw Exception('Spoonacular API error: ${response.statusCode}');
    }
  }

  void _navigateToEmergencyScreen(models.FoodItem foodItem) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmergencyAlertScreen(foodItem: foodItem),
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Analysis Failed'),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
        ],
      ),
    );
  }
}
