import 'dart:convert';
import 'package:http/http.dart' as http;

class CulturalService {
  static Future<Map<String, dynamic>?> getCulturalInsights(String dishName) async {
    try {
      // Using Wikipedia API for cultural information
      final response = await http.get(
        Uri.parse('https://en.wikipedia.org/api/rest_v1/page/summary/$dishName'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'origin': _extractOriginFromText(data['extract'] ?? ''),
          'culturalInfo': data['extract'] ?? 'Cultural information available on Wikipedia.',
          'history': _generateHistoricalInfo(dishName),
          'etiquette': _generateEtiquetteInfo(dishName),
          'funFact': _generateFunFact(dishName),
        };
      }
      
      return _generateFallbackCulturalData(dishName);
    } catch (e) {
      print('Error fetching cultural data: $e');
      return _generateFallbackCulturalData(dishName);
    }
  }

  static String _extractOriginFromText(String text) {
    final originKeywords = ['originating', 'origin', 'from', 'traditional', 'country'];
    for (final keyword in originKeywords) {
      if (text.toLowerCase().contains(keyword)) {
        // Simple extraction logic - in production, use more sophisticated NLP
        return 'Various regions';
      }
    }
    return 'International cuisine';
  }

  static String _generateHistoricalInfo(String dishName) {
    final lowerName = dishName.toLowerCase();
    
    if (lowerName.contains('pizza')) return 'Pizza has its roots in ancient flatbreads from Egypt and Rome. Modern pizza developed in Naples, Italy in the 18th century.';
    if (lowerName.contains('sushi')) return 'Sushi originated as a way to preserve fish in fermented rice in Southeast Asia, later evolving in Japan during the Edo period.';
    if (lowerName.contains('taco')) return 'Tacos have indigenous Mexican origins, with evidence of pre-Columbian people eating fish tacons in the lake region of Mexico.';
    if (lowerName.contains('curry')) return 'Curry has a 4000-year history in the Indian subcontinent, with the word "curry" deriving from the Tamil word "kari".';
    
    return 'This dish has a rich culinary history that spans cultures and generations, evolving through trade routes and cultural exchanges.';
  }

  static String _generateEtiquetteInfo(String dishName) {
    final lowerName = dishName.toLowerCase();
    
    if (lowerName.contains('sushi')) return 'Eat sushi in one bite if possible. Use chopsticks or hands. Dip fish-side, not rice-side, in soy sauce.';
    if (lowerName.contains('pizza')) return 'In Italy, pizza is typically eaten with knife and fork. Elsewhere, hand-eating is common. Fold slices for easier eating.';
    if (lowerName.contains('noodle')) return 'Slurping noodles is acceptable in many Asian cultures as it enhances flavor and cools the noodles.';
    
    return 'Enjoy this dish according to local customs. When in doubt, observe how locals eat it or ask your host for guidance.';
  }

  static String _generateFunFact(String dishName) {
    final lowerName = dishName.toLowerCase();
    
    if (lowerName.contains('pizza')) return 'The most expensive pizza in the world costs \$12,000 and takes 72 hours to prepare.';
    if (lowerName.contains('chocolate')) return 'Chocolate was once used as currency by the Aztecs, who valued cocoa beans highly.';
    if (lowerName.contains('ice cream')) return 'The first ice cream recipe was written in 1665 by Sir Kenelm Digby, an English courtier.';
    
    return 'Food connects cultures - every dish tells a story of migration, trade, and human creativity across generations.';
  }

  static Map<String, dynamic> _generateFallbackCulturalData(String dishName) {
    return {
      'origin': 'Various culinary traditions',
      'culturalInfo': 'This dish represents the beautiful diversity of world cuisine, blending ingredients and techniques from different cultures.',
      'history': 'A dish with roots in traditional cooking methods that have been passed down through generations.',
      'etiquette': 'Typically enjoyed with appreciation for the cultural heritage it represents.',
      'funFact': 'Food is one of the most universal ways people connect across cultures and generations!',
    };
  }
}
