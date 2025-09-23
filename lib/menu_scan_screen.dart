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
import 'package:foodpassport/services/translation_service.dart'; // ← ADD THIS

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
  final TranslationService _translationService = TranslationService(); // ← ADD THIS

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

    final image = await _picker.pickImage(source: ImageSource.camera);

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

        // REAL TRANSLATION - NO MORE MOCK!
        String translatedText = await _translateText(extractedText);

        setState(() {
          isScanning = false;
          scannedText = translatedText;
        });
      } catch (e) {
        setState(() {
          isScanning = false;
          scannedText = "Error: $e";
        });
      }
    } else {
      setState(() {
        isScanning = false;
      });
    }
  }

  Future<String> _translateText(String text) async {
    try {
      // Get user's preferred language (you can later get this from settings)
      String targetLang = _getUserLanguage();
      
      // Skip translation if target is English
      if (targetLang == 'en') {
        return '''
✨ OCR RESULT (English) ✨
$text
____________________________________
ℹ️ Tap any line to translate to your language
⚠️ Contains allergens: peanuts, shellfish (if detected)
        ''';
      }

      // Translate using our free service
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
      // Fallback to original text if translation fails
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
    // Later: Get from user preferences
    // For now, let's use Thai ('th') since you're in Bangkok!
    return 'th'; // Change to 'ja', 'zh', 'fr', 'es', etc. to test other languages
  }

  String _getLanguageName(String code) {
    final languages = {
      'es': 'Spanish',
      'fr': 'French',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'zh': 'Chinese',
      'ja': 'Japanese',
      'ko': 'Korean',
      'th': 'Thai',
      'vi': 'Vietnamese',
      'ru': 'Russian',
      'ar': 'Arabic',
      'hi': 'Hindi',
      'bn': 'Bengali',
      'ur': 'Urdu',
      'sw': 'Swahili',
      'fa': 'Persian',
      'tr': 'Turkish',
      'nl': 'Dutch',
      'pl': 'Polish',
      'uk': 'Ukrainian',
      'el': 'Greek',
      'he': 'Hebrew',
      'cs': 'Czech',
      'hu': 'Hungarian',
      'ro': 'Romanian',
      'da': 'Danish',
      'fi': 'Finnish',
      'sv': 'Swedish',
      'no': 'Norwegian',
      'id': 'Indonesian',
      'ms': 'Malay',
      'tl': 'Tagalog',
      'my': 'Burmese',
      'km': 'Khmer',
      'lo': 'Lao',
      'si': 'Sinhala',
      'ne': 'Nepali',
      'gu': 'Gujarati',
      'ta': 'Tamil',
      'te': 'Telugu',
      'mr': 'Marathi',
      'kn': 'Kannada',
      'ml': 'Malayalam',
      'pa': 'Punjabi',
      'am': 'Amharic',
      'om': 'Oromo',
      'so': 'Somali',
      'ha': 'Hausa',
      'yo': 'Yoruba',
      'ig': 'Igbo',
      'zu': 'Zulu',
      'xh': 'Xhosa',
      'af': 'Afrikaans',
      'ny': 'Chichewa',
      'sn': 'Shona',
      'st': 'Sesotho',
      'tg': 'Tajik',
      'uz': 'Uzbek',
      'kk': 'Kazakh',
      'ky': 'Kyrgyz',
      'mn': 'Mongolian',
      'bo': 'Tibetan',
      'sd': 'Sindhi',
      'ps': 'Pashto',
      'ku': 'Kurdish',
      'ckb': 'Sorani Kurdish',
      'dv': 'Dhivehi',
      'ff': 'Fulah',
      'bm': 'Bambara',
      'mg': 'Malagasy',
      'ln': 'Lingala',
      'tn': 'Tswana',
      'rw': 'Kinyarwanda',
      'rn': 'Kirundi',
      'sg': 'Sango',
      'ti': 'Tigrinya',
      'ak': 'Akan',
      'ee': 'Ewe',
      'tw': 'Twi',
      'hz': 'Herero',
      'kj': 'Kuanyama',
      'lg': 'Ganda',
      'mt': 'Maltese',
      'cy': 'Welsh',
      'ga': 'Irish',
      'gd': 'Scottish Gaelic',
      'gv': 'Manx',
      'kw': 'Cornish',
      'br': 'Breton',
      'co': 'Corsican',
      'oc': 'Occitan',
      'ca': 'Catalan',
      'eu': 'Basque',
      'gl': 'Galician',
      'fy': 'Frisian',
      'lb': 'Luxembourgish',
      'is': 'Icelandic',
      'fo': 'Faroese',
      'sm': 'Samoan',
      'to': 'Tongan',
      'fj': 'Fijian',
      'mh': 'Marshallese',
      'na': 'Nauruan',
      'ki': 'Kikuyu',
      'lu': 'Luba-Katanga',
      'kg': 'Kongo',
      'ts': 'Tsonga',
      'ss': 'Swati',
      've': 'Venda',
      'nr': 'South Ndebele',
      'nd': 'North Ndebele',
    };
    return languages[code] ?? code.toUpperCase();
  }

  Widget _buildCapturedImage() {
    if (kIsWeb && webImage != null) {
      return Image.memory(webImage!, fit: BoxFit.cover);
    } else if (!kIsWeb && capturedImage != null) {
      return Image.file(File(capturedImage!.path), fit: BoxFit.cover);
    } else {
      return Container(); // Should not happen
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