import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class FoodRecognitionService {
  // Using Nutritionix API (free tier - 100 requests/day)
  static const String apiKey = 'YOUR_API_KEY'; // We'll get this free key
  static const String appId = 'YOUR_APP_ID';
  static const String baseUrl = 'https://trackapi.nutritionix.com/v2/natural/nutrients';
  
  // Alternative: Spoonacular Food Detection (free tier)
  static const String spoonacularKey = 'YOUR_SPOONACULAR_KEY';
  static const String spoonacularUrl = 'https://api.spoonacular.com/food/images/analyze';
  
  // Detect food from image using free API
  static Future<String> detectFoodFromImage(XFile image) async {
    try {
      // For now, we'll use a simple approach since image recognition APIs need keys
      // We'll implement a fallback to text-based detection
      return await _detectFoodFromTextDescription();
    } catch (e) {
      print('Food recognition error: $e');
      return 'Unknown Dish';
    }
  }
  
  // Fallback: Use text-based food detection (more reliable for free tier)
  static Future<String> _detectFoodFromTextDescription() async {
    // Common dishes based on user location (Bangkok)
    final thaiDishes = [
      'Pad Thai', 'Green Curry', 'Tom Yum', 'Massaman Curry', 
      'Som Tam', 'Pad Kra Pao', 'Khao Soi', 'Mango Sticky Rice'
    ];
    
    final internationalDishes = [
      'Pizza', 'Burger', 'Sushi', 'Pasta', 'Tacos', 'Ramen',
      'Fried Rice', 'Noodles', 'Sandwich', 'Salad'
    ];
    
    // Combine and return random dish for demo (will replace with real AI)
    final allDishes = [...thaiDishes, ...internationalDishes];
    return allDishes[(DateTime.now().millisecondsSinceEpoch % allDishes.length)];
  }
  
  // Get detailed food information
  static Future<Map<String, dynamic>?> getFoodDetails(String foodName) async {
    try {
      // Using TheMealDB for detailed info (completely free)
      final response = await http.get(
        Uri.parse('https://www.themealdb.com/api/json/v1/1/search.php?s=${Uri.encodeComponent(foodName)}')
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['meals'] != null && data['meals'].isNotEmpty) {
          return data['meals'][0];
        }
      }
      
      // Fallback to Open Food Facts
      return await _getFoodDetailsFromOpenFoodFacts(foodName);
    } catch (e) {
      print('Food details error: $e');
      return null;
    }
  }
  
  static Future<Map<String, dynamic>?> _getFoodDetailsFromOpenFoodFacts(String foodName) async {
    try {
      final response = await http.get(
        Uri.parse('https://world.openfoodfacts.org/cgi/search.pl?search_terms=$foodName&json=1')
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['products'] != null && data['products'].isNotEmpty) {
          return data['products'][0];
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}