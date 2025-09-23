import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  // We'll use TWO free translation APIs for better accuracy
  final String libreTranslateUrl = 'https://libretranslate.de/translate';
  final String argoTranslateUrl = 'https://translate.argosopentech.com/translate';

  Future<String> translate(String text, String targetLanguage) async {
    if (text.trim().isEmpty) return text;

    // Step 1: Try LibreTranslate first
    String result = await _tryTranslate(text, targetLanguage, libreTranslateUrl);

    // Step 2: If LibreTranslate fails or returns empty, try Argos Translate
    if (result.trim().isEmpty || result.contains('error')) {
      result = await _tryTranslate(text, targetLanguage, argoTranslateUrl);
    }

    // Step 3: If both fail, return original text
    if (result.trim().isEmpty) {
      return text;
    }

    return result;
  }

  Future<String> _tryTranslate(String text, String targetLanguage, String url) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'source': 'en',
          'target': targetLanguage,
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translatedText'] ?? '';
      }
    } catch (e) {
      // Ignore error and try next service
    }
    return '';
  }
}