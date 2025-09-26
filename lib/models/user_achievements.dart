class UserAchievements {
  final int totalPoints;
  final int level;
  final int foodsDiscovered;
  final int cuisinesTried;
  final int totalCalories;
  final int currentStreak;
  final int bestStreak;
  final DateTime lastActivity;
  final Map<String, int> cuisineCounts;
  final Map<String, int> achievementProgress;

  UserAchievements({
    required this.totalPoints,
    required this.level,
    required this.foodsDiscovered,
    required this.cuisinesTried,
    required this.totalCalories,
    required this.currentStreak,
    required this.bestStreak,
    required this.lastActivity,
    required this.cuisineCounts,
    required this.achievementProgress,
  });

  factory UserAchievements.initial() {
    return UserAchievements(
      totalPoints: 0,
      level: 1,
      foodsDiscovered: 0,
      cuisinesTried: 0,
      totalCalories: 0,
      currentStreak: 0,
      bestStreak: 0,
      lastActivity: DateTime.now(),
      cuisineCounts: {},
      achievementProgress: {},
    );
  }

  factory UserAchievements.fromMap(Map<String, dynamic> map) {
    return UserAchievements(
      totalPoints: map['total_points'] ?? 0,
      level: map['level'] ?? 1,
      foodsDiscovered: map['foods_discovered'] ?? 0,
      cuisinesTried: map['cuisines_tried'] ?? 0,
      totalCalories: map['total_calories'] ?? 0,
      currentStreak: map['current_streak'] ?? 0,
      bestStreak: map['best_streak'] ?? 0,
      lastActivity: DateTime.fromMillisecondsSinceEpoch(map['last_activity'] ?? DateTime.now().millisecondsSinceEpoch),
      cuisineCounts: Map<String, int>.from(map['cuisine_counts'] ?? {}),
      achievementProgress: Map<String, int>.from(map['achievement_progress'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'total_points': totalPoints,
      'level': level,
      'foods_discovered': foodsDiscovered,
      'cuisines_tried': cuisinesTried,
      'total_calories': totalCalories,
      'current_streak': currentStreak,
      'best_streak': bestStreak,
      'last_activity': lastActivity.millisecondsSinceEpoch,
      'cuisine_counts': cuisineCounts,
      'achievement_progress': achievementProgress,
    };
  }

  int get pointsToNextLevel {
    const levelThresholds = [0, 100, 300, 600, 1000, 1500, 2100, 2800, 3600, 4500];
    if (level >= levelThresholds.length) return 0;
    return levelThresholds[level] - totalPoints;
  }

  double get levelProgress {
    if (level == 1) return totalPoints / 100;
    const levelThresholds = [0, 100, 300, 600, 1000, 1500, 2100, 2800, 3600, 4500];
    if (level >= levelThresholds.length) return 1.0;
    
    final currentLevelPoints = levelThresholds[level - 1];
    final nextLevelPoints = levelThresholds[level];
    final pointsInLevel = totalPoints - currentLevelPoints;
    final levelRange = nextLevelPoints - currentLevelPoints;
    
    return pointsInLevel / levelRange;
  }

  String get levelTitle {
    const titles = [
      'Food Novice', 'Taste Explorer', 'Culinary Adventurer', 
      'Gourmet Traveler', 'Food Connoisseur', 'Master Chef',
      'Culinary Expert', 'Food Scholar', 'Gastronomic Legend', 'Ultimate Foodie'
    ];
    return titles[level.clamp(0, titles.length - 1)];
  }
}