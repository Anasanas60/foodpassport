import 'package:flutter/material.dart';
import '../models/passport_stamp.dart';
import '../models/user_achievements.dart';
import '../models/food_item.dart';

class AchievementService {
  static final List<PassportStamp> _allStamps = [
    // Milestone Stamps
    PassportStamp(
      id: 'first_food',
      title: 'First Discovery!',
      description: 'Scan your first food item',
      type: StampType.milestone,
      category: StampCategory.beginner,
      points: 50,
      earnedDate: DateTime(1970),
      icon: '🆕',
      color: Colors.blue,
      requirements: {'foods_scanned': 1},
    ),
    PassportStamp(
      id: 'food_explorer',
      title: 'Food Explorer',
      description: 'Discover 10 different foods',
      type: StampType.milestone,
      category: StampCategory.intermediate,
      points: 100,
      earnedDate: DateTime(1970),
      icon: '🔍',
      color: Colors.green,
      requirements: {'foods_scanned': 10},
    ),

    // Cuisine Stamps
    PassportStamp(
      id: 'thai_master',
      title: 'Thai Cuisine Master',
      description: 'Try 5 different Thai dishes',
      type: StampType.cuisine,
      category: StampCategory.intermediate,
      points: 150,
      earnedDate: DateTime(1970),
      icon: '🍛',
      color: Colors.red,
      requirements: {'thai_dishes': 5},
    ),
    PassportStamp(
      id: 'italian_chef',
      title: 'Italian Chef',
      description: 'Discover 3 Italian dishes',
      type: StampType.cuisine,
      category: StampCategory.intermediate,
      points: 120,
      earnedDate: DateTime(1970),
      icon: '🍝',
      color: Colors.green,
      requirements: {'italian_dishes': 3},
    ),

    // Nutrition Stamps
    PassportStamp(
      id: 'calorie_counter',
      title: 'Calorie Counter',
      description: 'Log 1,000 total calories',
      type: StampType.nutrition,
      category: StampCategory.beginner,
      points: 80,
      earnedDate: DateTime(1970),
      icon: '🔥',
      color: Colors.orange,
      requirements: {'total_calories': 1000},
    ),

    // Travel Stamps
    PassportStamp(
      id: 'world_traveler',
      title: 'World Traveler',
      description: 'Foods from 3 different countries',
      type: StampType.travel,
      category: StampCategory.advanced,
      points: 200,
      earnedDate: DateTime(1970),
      icon: '🌍',
      color: Colors.purple,
      requirements: {'unique_countries': 3},
    ),

    // Consistency Stamps
    PassportStamp(
      id: 'weekly_explorer',
      title: 'Weekly Explorer',
      description: '7-day scanning streak',
      type: StampType.consistency,
      category: StampCategory.intermediate,
      points: 150,
      earnedDate: DateTime(1970),
      icon: '📅',
      color: Colors.teal,
      requirements: {'streak_days': 7},
    ),

    // Challenge Stamps
    PassportStamp(
      id: 'variety_seeker',
      title: 'Variety Seeker',
      description: 'Discover 20 unique foods',
      type: StampType.challenge,
      category: StampCategory.advanced,
      points: 250,
      earnedDate: DateTime(1970),
      icon: '🎯',
      color: Colors.deepOrange,
      requirements: {'unique_foods': 20},
    ),

    // Secret Stamps
    PassportStamp(
      id: 'midnight_feast',
      title: 'Midnight Feaster',
      description: 'Scan food between midnight and 4 AM',
      type: StampType.secret,
      category: StampCategory.expert,
      points: 300,
      earnedDate: DateTime(1970),
      icon: '🌙',
      color: Colors.indigo,
      requirements: {'midnight_scans': 1},
      isSecret: true,
    ),
  ];

  static List<PassportStamp> checkNewAchievements({
    required UserAchievements currentStats,
    required List<FoodItem> foodHistory,
    required List<PassportStamp> earnedStamps,
  }) {
    final newAchievements = <PassportStamp>[];
    final earnedIds = earnedStamps.map((s) => s.id).toSet();

    for (final stamp in _allStamps) {
      if (earnedIds.contains(stamp.id)) continue;

      if (_meetsRequirements(stamp, currentStats, foodHistory)) {
        newAchievements.add(PassportStamp(
          id: stamp.id,
          title: stamp.title,
          description: stamp.description,
          type: stamp.type,
          category: stamp.category,
          points: stamp.points,
          earnedDate: DateTime.now(),
          icon: stamp.icon,
          color: stamp.color,
          requirements: stamp.requirements,
          isSecret: stamp.isSecret,
        ));
      }
    }

    return newAchievements;
  }

  static bool _meetsRequirements(
    PassportStamp stamp,
    UserAchievements stats,
    List<FoodItem> foodHistory,
  ) {
    for (final requirement in stamp.requirements.entries) {
      final key = requirement.key;
      final requiredValue = requirement.value;

      switch (key) {
        case 'foods_scanned':
          if (stats.foodsDiscovered < requiredValue) return false;
          break;
        
        case 'thai_dishes':
          final thaiCount = foodHistory.where((f) => 
            f.area?.toLowerCase().contains('thai') == true || 
            f.name.toLowerCase().contains('thai')
          ).length;
          if (thaiCount < requiredValue) return false;
          break;
        
        case 'italian_dishes':
          final italianCount = foodHistory.where((f) => 
            f.area?.toLowerCase().contains('ital') == true || 
            f.name.toLowerCase().contains('pizza') ||
            f.name.toLowerCase().contains('pasta')
          ).length;
          if (italianCount < requiredValue) return false;
          break;
        
        case 'total_calories':
          if (stats.totalCalories < requiredValue) return false;
          break;
        
        case 'unique_countries':
          final countries = foodHistory
              .where((f) => f.area != null)
              .map((f) => f.area!)
              .toSet();
          if (countries.length < requiredValue) return false;
          break;
        
        case 'streak_days':
          if (stats.currentStreak < requiredValue) return false;
          break;
        
        case 'unique_foods':
          final uniqueFoods = foodHistory.map((f) => f.name).toSet();
          if (uniqueFoods.length < requiredValue) return false;
          break;
        
        case 'midnight_scans':
          final midnightScans = foodHistory.where((f) {
            final hour = f.timestamp.hour;
            return hour >= 0 && hour <= 4;
          }).length;
          if (midnightScans < requiredValue) return false;
          break;
      }
    }

    return true;
  }

  static UserAchievements updateStats({
    required UserAchievements currentStats,
    required FoodItem newFood,
    required List<FoodItem> foodHistory,
  }) {
    // Update basic stats
    final newStats = UserAchievements(
      totalPoints: currentStats.totalPoints,
      level: currentStats.level,
      foodsDiscovered: currentStats.foodsDiscovered + 1,
      cuisinesTried: currentStats.cuisinesTried,
      totalCalories: currentStats.totalCalories + newFood.calories.round(),
      currentStreak: _calculateStreak(currentStats, newFood.timestamp),
      bestStreak: _calculateBestStreak(currentStats, newFood.timestamp),
      lastActivity: newFood.timestamp,
      cuisineCounts: _updateCuisineCounts(currentStats.cuisineCounts, newFood),
      achievementProgress: currentStats.achievementProgress,
    );

    // Update level based on points
    final newLevel = _calculateLevel(newStats.totalPoints);
    
    return newStats.copyWith(level: newLevel);
  }

  static int _calculateStreak(UserAchievements stats, DateTime newDate) {
    final lastActivity = stats.lastActivity;
    final difference = newDate.difference(lastActivity);
    
    if (difference.inDays == 1) {
      return stats.currentStreak + 1;
    } else if (difference.inDays > 1) {
      return 1; // Reset streak if gap more than 1 day
    }
    
    return stats.currentStreak; // Same day
  }

  static int _calculateBestStreak(UserAchievements stats, DateTime newDate) {
    final newStreak = _calculateStreak(stats, newDate);
    return newStreak > stats.bestStreak ? newStreak : stats.bestStreak;
  }

  static Map<String, int> _updateCuisineCounts(
    Map<String, int> currentCounts,
    FoodItem newFood,
  ) {
    final cuisine = newFood.area ?? 'Unknown';
    final newCounts = Map<String, int>.from(currentCounts);
    newCounts[cuisine] = (newCounts[cuisine] ?? 0) + 1;
    return newCounts;
  }

  static int _calculateLevel(int totalPoints) {
    const levelThresholds = [0, 100, 300, 600, 1000, 1500, 2100, 2800, 3600, 4500];
    for (int i = levelThresholds.length - 1; i >= 0; i--) {
      if (totalPoints >= levelThresholds[i]) {
        return i + 1;
      }
    }
    return 1;
  }
}

extension UserAchievementsExtension on UserAchievements {
  UserAchievements copyWith({
    int? totalPoints,
    int? level,
    int? foodsDiscovered,
    int? cuisinesTried,
    int? totalCalories,
    int? currentStreak,
    int? bestStreak,
    DateTime? lastActivity,
    Map<String, int>? cuisineCounts,
    Map<String, int>? achievementProgress,
  }) {
    return UserAchievements(
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      foodsDiscovered: foodsDiscovered ?? this.foodsDiscovered,
      cuisinesTried: cuisinesTried ?? this.cuisinesTried,
      totalCalories: totalCalories ?? this.totalCalories,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      lastActivity: lastActivity ?? this.lastActivity,
      cuisineCounts: cuisineCounts ?? this.cuisineCounts,
      achievementProgress: achievementProgress ?? this.achievementProgress,
    );
  }

  UserAchievements addPoints(int points) {
    return copyWith(totalPoints: totalPoints + points);
  }
}