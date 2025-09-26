class PassportStamp {
  final String id;
  final String title;
  final String description;
  final StampType type;
  final StampCategory category;
  final int points;
  final DateTime earnedDate;
  final String icon;
  final Color color;
  final Map<String, dynamic> requirements;
  final bool isSecret;

  PassportStamp({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.category,
    required this.points,
    required this.earnedDate,
    required this.icon,
    required this.color,
    this.requirements = const {},
    this.isSecret = false,
  });

  factory PassportStamp.fromMap(Map<String, dynamic> map) {
    return PassportStamp(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      type: StampType.values.firstWhere((e) => e.name == map['type'], orElse: () => StampType.milestone),
      category: StampCategory.values.firstWhere((e) => e.name == map['category'], orElse: () => StampCategory.general),
      points: map['points'] ?? 10,
      earnedDate: DateTime.fromMillisecondsSinceEpoch(map['earned_date']),
      icon: map['icon'] ?? '🌟',
      color: _parseColor(map['color']),
      requirements: map['requirements'] ?? {},
      isSecret: map['is_secret'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.name,
      'category': category.name,
      'points': points,
      'earned_date': earnedDate.millisecondsSinceEpoch,
      'icon': icon,
      'color': color.value,
      'requirements': requirements,
      'is_secret': isSecret,
    };
  }

  static Color _parseColor(dynamic color) {
    if (color is int) return Color(color);
    if (color is String) {
      switch (color) {
        case 'blue': return const Color(0xFF1a237e);
        case 'green': return const Color(0xFF2e7d32);
        case 'red': return const Color(0xFF8b0000);
        case 'orange': return const Color(0xFFff6f00);
        case 'purple': return const Color(0xFF4a148c);
        case 'teal': return const Color(0xFF00695c);
        default: return const Color(0xFF1a237e);
      }
    }
    return const Color(0xFF1a237e);
  }

  bool get isEarned => earnedDate.isBefore(DateTime.now());
  String get formattedDate => '${earnedDate.day}/${earnedDate.month}/${earnedDate.year}';
}

enum StampType {
  milestone('Milestone', Icons.flag),
  cuisine('Cuisine', Icons.restaurant),
  nutrition('Nutrition', Icons.bolt),
  travel('Travel', Icons.public),
  consistency('Consistency', Icons.calendar_today),
  challenge('Challenge', Icons.emoji_events),
  secret('Secret', Icons.lock);

  final String displayName;
  final IconData icon;

  const StampType(this.displayName, this.icon);
}

enum StampCategory {
  general('General', '🌟'),
  beginner('Beginner', '🆕'),
  intermediate('Intermediate', '⚡'),
  advanced('Advanced', '🏆'),
  expert('Expert', '👑');

  final String displayName;
  final String icon;

  const StampCategory(this.displayName, this.icon);
}