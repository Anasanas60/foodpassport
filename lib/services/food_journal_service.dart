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
      await _updateUserStats(calories, foodName);
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
      final startOfDay = DateTime(date.year, date.month, date.day);
      final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);
      
      final entries = await _dbService.getFoodEntries();
      
      // Filter entries by date manually since we don't have direct DB query access
      return entries.where((entry) {
        final entryDate = DateTime.fromMillisecondsSinceEpoch(entry['timestamp']);
        return entryDate.isAfter(startOfDay) && entryDate.isBefore(endOfDay);
      }).map((entry) => _deserializeFoodEntry(entry)).toList();
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
      final cutoffTime = DateTime.now().subtract(Duration(days: days));
      final entries = await getFoodEntries();
      
      final recentEntries = entries.where((entry) {
        return entry['timestamp'].isAfter(cutoffTime);
      }).toList();

      if (recentEntries.isEmpty) {
        return {
          'total_entries': 0,
          'total_calories': 0,
          'avg_calories': 0,
          'total_protein': 0,
          'total_carbs': 0,
          'total_fat': 0,
        };
      }

      final totalCalories = recentEntries.fold<double>(0, (sum, entry) => sum + (entry['calories'] ?? 0));
      final totalProtein = recentEntries.fold<double>(0, (sum, entry) => sum + (entry['protein'] ?? 0));
      final totalCarbs = recentEntries.fold<double>(0, (sum, entry) => sum + (entry['carbs'] ?? 0));
      final totalFat = recentEntries.fold<double>(0, (sum, entry) => sum + (entry['fat'] ?? 0));

      return {
        'total_entries': recentEntries.length,
        'total_calories': totalCalories,
        'avg_calories': totalCalories / recentEntries.length,
        'total_protein': totalProtein,
        'total_carbs': totalCarbs,
        'total_fat': totalFat,
      };
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

  Future<void> _updateUserStats(double calories, String foodName) async {
    try {
      final currentStats = await _dbService.getUserStats() ?? {};
      final now = DateTime.now();
      final lastEntryDate = currentStats['last_entry_date'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(currentStats['last_entry_date'])
          : null;

      int currentStreak = currentStats['current_streak'] ?? 0;
      if (lastEntryDate != null && _isConsecutiveDay(lastEntryDate, now)) {
        currentStreak++;
      } else if (lastEntryDate == null || !_isSameDay(lastEntryDate, now)) {
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
    final previousDay = DateTime(previous.year, previous.month, previous.day);
    final currentDay = DateTime(current.year, current.month, current.day);
    final difference = currentDay.difference(previousDay).inDays;
    return difference == 1;
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
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
    
    final uniqueFoods = entries.map((e) => e['foodName']?.toString().toLowerCase() ?? '').toSet();
    if (uniqueFoods.length >= 5) {
      await _awardPassportStamp(
        type: 'food_explorer',
        title: 'Food Explorer',
        description: 'Tried 5 different foods',
        category: 'variety',
      );
    }

    // Check for streak achievements
    final currentStats = await _dbService.getUserStats() ?? {};
    final currentStreak = currentStats['current_streak'] ?? 0;
    
    if (currentStreak >= 7) {
      await _awardPassportStamp(
        type: 'weekly_streak',
        title: 'Weekly Streak!',
        description: 'Logged food for 7 consecutive days',
        category: 'consistency',
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
      // Check if stamp already exists to avoid duplicates
      final existingStamps = await _dbService.getPassportStamps();
      final alreadyAwarded = existingStamps.any((stamp) => stamp['stamp_type'] == type);
      
      if (!alreadyAwarded) {
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
      }
    } catch (e) {
      print('❌ Error awarding passport stamp: $e');
    }
  }

  Map<String, dynamic> _deserializeFoodEntry(Map<String, dynamic> entry) {
    return {
      'id': entry['id'],
      'foodName': entry['food_name'],
      'calories': (entry['calories'] as num).toDouble(),
      'protein': (entry['protein'] as num).toDouble(),
      'carbs': (entry['carbs'] as num).toDouble(),
      'fat': (entry['fat'] as num).toDouble(),
      'imagePath': entry['image_path'],
      'location': entry['latitude'] != null && entry['longitude'] != null
          ? {
              'latitude': (entry['latitude'] as num).toDouble(),
              'longitude': (entry['longitude'] as num).toDouble(),
              'address': entry['address'],
            }
          : null,
      'timestamp': DateTime.fromMillisecondsSinceEpoch(entry['timestamp']),
      'confidenceScore': (entry['confidence_score'] as num?)?.toDouble() ?? 0.8,
      'source': entry['source'] ?? 'nutritionix',
    };
  }

  // Additional utility methods
  Future<List<Map<String, dynamic>>> getPassportStamps() async {
    try {
      return await _dbService.getPassportStamps();
    } catch (e) {
      print('❌ Error fetching passport stamps: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getUserStats() async {
    try {
      return await _dbService.getUserStats();
    } catch (e) {
      print('❌ Error fetching user stats: $e');
      return null;
    }
  }

  Future<void> resetUserData() async {
    try {
      await _dbService.resetDatabase();
      print('✅ User data reset successfully');
    } catch (e) {
      print('❌ Error resetting user data: $e');
      throw Exception('Failed to reset user data: $e');
    }
  }
}