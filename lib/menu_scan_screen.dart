import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:typed_data';
import 'dart:io';

// Import services
import 'package:foodpassport/services/ocr_service.dart';
import 'package:foodpassport/services/ocr_service_mobile.dart';
import 'package:foodpassport/services/ocr_service_web.dart';
import 'package:foodpassport/services/translation_service.dart';

class MenuScanScreen extends StatefulWidget {
  const MenuScanScreen({super.key});

  @override
  State<MenuScanScreen> createState() => _MenuScanScreenState();
}

class _MenuScanScreenState extends State<MenuScanScreen> {
  bool isScanning = false;
  String? scannedText;
  XFile? capturedImage;
  Uint8List? webImage;

  final ImagePicker _picker = ImagePicker();
  late final OcrService _ocrService;
  final TranslationService _translationService = TranslationService();

  @override
  void initState() {
    super.initState();
    _ocrService = kIsWeb ? OcrServiceWeb() : OcrServiceMobile();
  }

  Future<void> _startCameraScan() async {
    setState(() {
      isScanning = true;
      scannedText = null;
      capturedImage = null;
      webImage = null;
    });

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,      // REDUCED: Prevent memory issues
        maxHeight: 600,     // REDUCED: Prevent memory issues  
        imageQuality: 40,   // REDUCED: Lower quality for mobile browsers
      );

      if (image != null) {
        if (kIsWeb) {
          final imageBytes = await image.readAsBytes();
          setState(() {
            webImage = imageBytes;
          });
        } else {
          setState(() {
            capturedImage = image;
          });
        }

        try {
          String extractedText = await _ocrService.recognizeText(image);

          if (extractedText.trim().isEmpty) {
            extractedText = "No text detected. Try again with better lighting or focus.";
          }

          // REAL TRANSLATION
          String translatedText = await _translateText(extractedText);

          setState(() {
            isScanning = false;
            scannedText = translatedText;
          });
        } catch (e) {
          setState(() {
            isScanning = false;
            scannedText = "OCR Error: ${e.toString()}";
          });
        }
      } else {
        setState(() {
          isScanning = false;
        });
      }
    } catch (e) {
      setState(() {
        isScanning = false;
        scannedText = "Camera Error: ${e.toString()}";
      });
    }
  }

  Future<String> _translateText(String text) async {
    try {
      String targetLang = _getUserLanguage();
      
      if (targetLang == 'en') {
        return '''
✨ OCR RESULT (English) ✨
$text
____________________________________
ℹ️ Tap any line to translate to your language
⚠️ Contains allergens: peanuts, shellfish (if detected)
        ''';
      }

      String translated = await _translationService.translate(text, targetLang);
      
      return '''
✨ OCR RESULT (Translated to ${_getLanguageName(targetLang)}) ✨
$translated
____________________________________
ℹ️ Original (English): 
$text
⚠️ Contains allergens: peanuts, shellfish (if detected)
      ''';
    } catch (e) {
      return '''
🔄 TRANSLATION FAILED - Showing original text
Error: $e
____________________________________
📜 Original Text:
$text
      ''';
    }
  }

  String _getUserLanguage() {
    return 'th'; // Thai language for testing
  }

  String _getLanguageName(String code) {
    final languages = {
      'th': 'Thai', 'es': 'Spanish', 'fr': 'French', 'de': 'German', 
      'it': 'Italian', 'pt': 'Portuguese', 'zh': 'Chinese', 'ja': 'Japanese'
    };
    return languages[code] ?? code.toUpperCase();
  }

  Widget _buildCapturedImage() {
    if (kIsWeb && webImage != null) {
      return Image.memory(webImage!, fit: BoxFit.cover);
    } else if (!kIsWeb && capturedImage != null) {
      return Image.file(File(capturedImage!.path), fit: BoxFit.cover);
    } else {
      return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Restaurant Menu'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (capturedImage != null || webImage != null) ...[
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildCapturedImage(),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              if (isScanning) ...[
                const CircularProgressIndicator(color: Colors.purple),
                const SizedBox(height: 20),
                const Text(
                  '📸 Scanning menu...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Extracting text with AI...',
                  style: TextStyle(fontSize: 16),
                ),
              ],

              if (scannedText != null && !isScanning) ...[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📜 AI MENU TRANSLATION',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.purple),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          scannedText!,
                          style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
                          textAlign: TextAlign.left,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('Done'),
                            ),
                            const SizedBox(width: 16),
                            TextButton(
                              onPressed: () => setState(() {
                                scannedText = null;
                                capturedImage = null;
                                webImage = null;
                              }),
                              child: const Text('Scan Again'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              if (!isScanning && scannedText == null) ...[
                const Icon(Icons.menu_book, size: 80, color: Colors.purple),
                const SizedBox(height: 20),
                const Text(
                  'Point camera at menu to translate',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: _startCameraScan,
                  icon: const Icon(Icons.camera),
                  label: const Text('Start Camera Scan', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}