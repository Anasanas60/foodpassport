import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'services/food_recognition_service.dart';

class MenuScanScreen extends StatefulWidget {
  const MenuScanScreen({super.key});
  @override State<MenuScanScreen> createState() => _MenuScanScreenState();
}

class _MenuScanScreenState extends State<MenuScanScreen> {
  String _scannedText = '';
  Future<void> _scanMenu() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      await FoodRecognitionService.recognizeAndSaveFood(image);
      setState(() { _scannedText = 'Menu scanned successfully!'; });
    }
  }
  @override Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu Scanner')),
      body: Center(child: Column(children: [
        ElevatedButton(onPressed: _scanMenu, child: Text('Scan Menu')),
        SizedBox(height: 20), 
        Text(_scannedText)
      ])),
    );
  }
}
