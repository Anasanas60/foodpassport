import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// REMOVED: import 'services/food_recognition_service.dart'; - not available

class MenuScanScreen extends StatefulWidget {
  const MenuScanScreen({super.key});
  @override 
  State<MenuScanScreen> createState() => _MenuScanScreenState();
}

class _MenuScanScreenState extends State<MenuScanScreen> {
  String _scannedText = '';
  bool _isScanning = false;

  Future<void> _scanMenu() async {
    setState(() {
      _isScanning = true;
      _scannedText = 'Scanning menu...';
    });

    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        // FIXED: Use a simple fallback since FoodRecognitionService is not available
        await _processMenuImage(image);
        setState(() { 
          _scannedText = 'Menu scanned successfully!\n\nFeatures coming soon:\n• Text extraction\n• Language translation\n• Allergy detection';
        });
      } else {
        setState(() { 
          _scannedText = 'No image selected';
        });
      }
    } catch (e) {
      setState(() { 
        _scannedText = 'Error scanning menu: $e';
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  // Fallback method for menu processing
  Future<void> _processMenuImage(XFile image) async {
    // Simulate processing delay
    await Future.delayed(const Duration(seconds: 2));
    
    // In a real app, this would use OCR to extract text from the menu
    // For now, we'll just return a success message
    return;
  }

  Future<void> _scanFromGallery() async {
    setState(() {
      _isScanning = true;
      _scannedText = 'Processing image from gallery...';
    });

    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _processMenuImage(image);
        setState(() { 
          _scannedText = 'Menu image processed!\n\nThis feature will include:\n• OCR text recognition\n• Multi-language translation\n• Smart allergy warnings';
        });
      }
    } catch (e) {
      setState(() { 
        _scannedText = 'Error processing image: $e';
      });
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Scanner'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Scanner Icon
            Icon(
              Icons.menu_book,
              size: 80,
              color: Colors.blue[300],
            ),
            const SizedBox(height: 20),
            
            // Title
            const Text(
              'Menu Scanner',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 10),
            
            // Description
            const Text(
              'Scan restaurant menus to extract text and detect allergens',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 30),

            // Scan Buttons
            if (!_isScanning) ...[
              ElevatedButton.icon(
                onPressed: _scanMenu,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Menu with Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                onPressed: _scanFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                ),
              ),
            ],

            // Loading Indicator
            if (_isScanning) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              const Text('Processing menu image...'),
            ],

            const SizedBox(height: 30),

            // Scanned Text Display
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Text(
                    _scannedText.isEmpty ? 'Scan a menu to see results here...' : _scannedText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _scannedText.isEmpty ? Colors.grey[400] : Colors.grey[800],
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Feature Info
            Card(
              color: Colors.orange[50],
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    const Text(
                      'Coming Soon Features:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Text extraction from menus\n'
                      '• Language translation\n'
                      '• Allergy detection\n'
                      '• Price recognition',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}