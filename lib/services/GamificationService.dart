import 'package:flutter/foundation.dart';

class GamificationService with ChangeNotifier {
  int _points = 0;
  int _level = 1;
  final Set<String> _badges = {};
  final List<String> _achievements = [];

  int get points => _points;
  int get level => _level;
  Set<String> get badges => _badges;
  List<String> get achievements => _achievements;

  void addPoints(int pts) {
    _points += pts;
    _checkLevelUp();
    notifyListeners();
  }

  void _checkLevelUp() {
    int newLevel = (_points ~/ 100) + 1;
    if (newLevel > _level) {
      _level = newLevel;
      _unlockBadge('Level $_level Achieved');
      _addAchievement('Reached level $_level');
    }
  }

  void _unlockBadge(String badge) {
    if (!_badges.contains(badge)) {
      _badges.add(badge);
      notifyListeners();
    }
  }

  void _addAchievement(String achievement) {
    if (!_achievements.contains(achievement)) {
      _achievements.add(achievement);
      notifyListeners();
    }
  }
}
