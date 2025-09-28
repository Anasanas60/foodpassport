import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<void> _processMenuImage(XFile image) async {
    await Future.delayed(const Duration(seconds: 2));
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Scanner'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book,
              size: 80,
              color: theme.colorScheme.primary.withAlpha((0.5 * 255).round()),
            ),
            const SizedBox(height: 20),
            Text(
              'Menu Scanner',
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
            ),
            const SizedBox(height: 10),
            Text(
              'Scan restaurant menus to extract text and detect allergens',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 30),
            if (!_isScanning) ...[
              ElevatedButton.icon(
                onPressed: _scanMenu,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Menu with Camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
              const SizedBox(height: 15),
              OutlinedButton.icon(
                onPressed: _scanFromGallery,
                icon: const Icon(Icons.photo_library),
                label: const Text('Choose from Gallery'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                ),
              ),
            ],
            if (_isScanning) ...[
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text('Processing menu image...', style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 30),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: theme.colorScheme.outline),
                  ),
                  child: Text(
                    _scannedText.isEmpty ? 'Scan a menu to see results here...' : _scannedText,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _scannedText.isEmpty ? theme.colorScheme.outline : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              color: theme.colorScheme.secondaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      'Coming Soon Features:',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '• Text extraction from menus\n'
                      '• Language translation\n'
                      '• Allergy detection\n'
                      '• Price recognition',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
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
