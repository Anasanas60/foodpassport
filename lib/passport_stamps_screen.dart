import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/GamificationService.dart';

class PassportStampsScreen extends StatelessWidget {
  const PassportStampsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = Provider.of<GamificationService>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passport Stamps & Badges'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Level: ${gamification.level}',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text('Points: ${gamification.points}', style: theme.textTheme.titleMedium),
            const SizedBox(height: 20),
            Text('Badges:', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: gamification.badges
                  .map((badge) => Chip(
                        label: Text(badge),
                        backgroundColor: theme.colorScheme.primaryContainer,
                        labelStyle: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),
            Text('Achievements:', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: gamification.achievements.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) => ListTile(
                  leading: Icon(Icons.check_circle, color: theme.colorScheme.primary),
                  title: Text(
                    gamification.achievements[index],
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
