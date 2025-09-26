import 'package:flutter/material.dart';
import '../models/passport_stamp.dart';

class AchievementService {
  static List<Map<String, dynamic>> getSampleAchievements() {
    return [
      {
        'title': 'First Food Scan',
        'description': 'Scan your first food item',
        'icon': Icons.camera_alt,
        'completed': true,
      }
    ];
  }

  static PassportStamp createBasicStamp({required String foodName, required DateTime date, required String location}) {
    return PassportStamp(
      id: 'temp',
      foodName: foodName,
      date: date,
      location: location,
      imageUrl: '',
      color: Colors.blue,
      icon: Icons.restaurant,
    );
  }

  static List<Map<String, dynamic>> checkAchievements(List<PassportStamp> stamps) {
    return getSampleAchievements();
  }
}
