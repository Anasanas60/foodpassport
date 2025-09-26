import 'package:flutter/material.dart';

class PassportStamp {
  final String id;
  final String foodName;
  final DateTime date;
  final String location;
  final String imageUrl;
  final Color color;
  final IconData icon;

  String get title => foodName;
  String get description => 'Discovered food';
  int get points => 10;
  String get formattedDate => 'Sample Date';

  PassportStamp({
    required this.id,
    required this.foodName,
    required this.date,
    required this.location,
    required this.imageUrl,
    required this.color,
    required this.icon,
  });

  factory PassportStamp.basic({required String foodName, required DateTime date, required String location}) {
    return PassportStamp(
      id: '1',
      foodName: foodName,
      date: date,
      location: location,
      imageUrl: '',
      color: Colors.blue,
      icon: Icons.restaurant,
    );
  }
}
