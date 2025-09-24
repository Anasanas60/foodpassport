import 'package:geolocator/geolocator.dart';
import 'database_service.dart';

class FoodJournalService {
  final DatabaseService _dbService = DatabaseService();

  Future<void> addFoodEntry({
    required String foodName,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    String? imagePath,
    double? confidenceScore,
    String source = 'nutritionix',
    Position? position,
  }) async {
    try {
      final entry = {
        'food_name': foodName,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'image_path': imagePath,
        'latitude': position?.latitude,
        'longitude': position?.longitude,
        'address': _getSimpleAddress(position),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'confidence_score': confidenceScore ?? 0.8,
        'source': source,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      };

      await _dbService.insertFoodEntry(entry);
      await _updateUserStats(calories);
      await _checkForAchievements(foodName);
      
      print('✅ Food entry saved: $foodName');
    } catch (e) {
      print('❌ Error saving food entry: $e');
      throw Exception('Failed to save food entry: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFoodEntries() async {
    try {
      final entries = await _dbService.getFoodEntries();
      return entries.map((entry) => _deserializeFoodEntry(entry)).toList();
    } catch (e) {
      print('❌ Error fetching food entries: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getFoodEntriesByDate(DateTime date) async {
    try {
      final startOfDay = DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59).millisecondsSinceEpoch;
      
      final db = await _dbService.database;
      final entries = await db.query(
        'food_entries',
        where: 'timestamp BETWEEN ? AND ?',
        whereArgs: [startOfDay, endOfDay],
        orderBy: 'timestamp DESC',
      );
      
      return entries.map((entry) => _deserializeFoodEntry(entry)).toList();
    } catch (e) {
      print('❌ Error fetching entries by date: $e');
      return [];
    }
  }

  Future<bool> deleteFoodEntry(int id) async {
    try {
      final result = await _dbService.deleteFoodEntry(id);
      return result > 0;
    } catch (e) {
      print('❌ Error deleting food entry: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>> getNutritionSummary({int days = 7}) async {
    try {
      final cutoffTime = DateTime.now().subtract(Duration(days: days)).millisecondsSinceEpoch;
      
      final db = await _dbService.database;
      final result = await db.rawQuery('''
        SELECT 
          COUNT(*) as total_entries,
          SUM(calories) as total_calories,
          AVG(calories) as avg_calories,
          SUM(protein) as total_protein,
          SUM(carbs) as total_carbs,
          SUM(fat) as total_fat
        FROM food_entries 
        WHERE timestamp > ?
      ''', [cutoffTime]);

      return result.isNotEmpty ? result.first : {};
    } catch (e) {
      print('❌ Error getting nutrition summary: $e');
      return {};
    }
  }

  // Simplified address method without geocoding
  String? _getSimpleAddress(Position? position) {
    if (position == null) return null;
    return 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
  }

  Future<void> _updateUserStats(double calories) async {
    try {
      final currentStats = await _dbService.getUserStats() ?? {};
      final now = DateTime.now();
      final lastEntryDate = currentStats['last_entry_date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(currentStats['last_entry_date'])
          : null;

      int currentStreak = currentStats['current_streak'] ?? 0;
      if (lastEntryDate != null && _isConsecutiveDay(lastEntryDate, now)) {
        currentStreak++;
      } else {
        currentStreak = 1;
      }

      final newStats = {
        'total_foods_tried': (currentStats['total_foods_tried'] ?? 0) + 1,
        'current_streak': currentStreak,
        'best_streak': currentStreak > (currentStats['best_streak'] ?? 0) 
            ? currentStreak 
            : currentStats['best_streak'],
        'total_calories': (currentStats['total_calories'] ?? 0) + calories,
        'last_entry_date': now.millisecondsSinceEpoch,
      };

      await _dbService.updateUserStats(newStats);
    } catch (e) {
      print('❌ Error updating user stats: $e');
    }
  }

  bool _isConsecutiveDay(DateTime previous, DateTime current) {
    final difference = current.difference(previous).inDays;
    return difference == 1;
  }

  Future<void> _checkForAchievements(String foodName) async {
    final entries = await getFoodEntries();
    final totalEntries = entries.length;
    
    if (totalEntries == 1) {
      await _awardPassportStamp(
        type: 'first_food',
        title: 'First Bite!',
        description: 'Logged your first food discovery',
        category: 'milestone',
      );
    }
    
    final uniqueFoods = entries.map((e) => e['foodName'].toString().toLowerCase()).toSet();
    if (uniqueFoods.length >= 5) {
      await _awardPassportStamp(
        type: 'food_explorer',
        title: 'Food Explorer',
        description: 'Tried 5 different foods',
        category: 'variety',
      );
    }
  }

  Future<void> _awardPassportStamp({
    required String type,
    required String title,
    required String description,
    required String category,
  }) async {
    try {
      final stamp = {
        'stamp_type': type,
        'title': title,
        'description': description,
        'icon_name': 'stamp_$type',
        'earned_date': DateTime.now().millisecondsSinceEpoch,
        'category': category,
      };
      await _dbService.addPassportStamp(stamp);
      print('🎉 Passport stamp awarded: $title');
    } catch (e) {
      print('❌ Error awarding passport stamp: $e');
    }
  }

  Map<String, dynamic> _deserializeFoodEntry(Map<String, dynamic> entry) {
    return {
      'id': entry['id'],
      'foodName': entry['food_name'],
      'calories': entry['calories'],
      'protein': entry['protein'],
      'carbs': entry['carbs'],
      'fat': entry['fat'],
      'imagePath': entry['image_path'],
      'location': entry['latitude'] != null && entry['longitude'] != null
          ? {
              'latitude': entry['latitude'],
              'longitude': entry['longitude'],
              'address': entry['address'],
            }
          : null,
      'timestamp': DateTime.fromMillisecondsSinceEpoch(entry['timestamp']),
      'confidenceScore': entry['confidence_score'],
      'source': entry['source'],
    };
  }
}