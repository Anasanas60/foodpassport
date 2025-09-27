import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/GamificationService.dart';

class PassportStampsScreen extends StatelessWidget {
  const PassportStampsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = Provider.of<GamificationService>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Passport Stamps & Badges')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level: ${gamification.level}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text('Points: ${gamification.points}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            const Text('Badges:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,
              children: gamification.badges.map((badge) => Chip(label: Text(badge))).toList(),
            ),
            const SizedBox(height: 20),
            const Text('Achievements:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView(
                children: gamification.achievements.map((ach) => ListTile(title: Text(ach))).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
