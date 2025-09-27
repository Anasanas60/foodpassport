import 'package:flutter/material.dart';
import '../models/food_item.dart';

class EmergencyAlertScreen extends StatelessWidget {
  final FoodItem foodItem;

  const EmergencyAlertScreen({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allergens = foodItem.detectedAllergens;

    return Scaffold(
      backgroundColor: theme.colorScheme.errorContainer.withValues(alpha: 0.1),
      appBar: AppBar(
        title: const Text('🚨 EMERGENCY ALERT'),
        backgroundColor: theme.colorScheme.error,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, size: 100, color: theme.colorScheme.error),
              const SizedBox(height: 20),
              Text(
                'ALLERGEN DETECTED!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: theme.colorScheme.error),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                'Food: ${foodItem.name}',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              if (allergens.isNotEmpty) ...[
                Text(
                  'Detected Allergens:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.error),
                ),
                const SizedBox(height: 8),
                Text(
                  allergens.map((a) => a.toUpperCase()).join(', '),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
              const Text(
                'We detected ingredients you\'re allergic to. Notify staff immediately or seek medical help.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () async {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🚑 Alerting staff about ${allergens.join(", ")}'),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                  await Future.delayed(const Duration(seconds: 3));
                  if (!context.mounted) return;
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                ),
                child: const Text('CALL FOR HELP NOW', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    children: [
                      const Text(
                        'Food Details:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Calories: ${foodItem.calories.round()}'),
                      Text('Protein: ${foodItem.protein.round()}g'),
                      Text('Carbs: ${foodItem.carbs.round()}g'),
                      Text('Fat: ${foodItem.fat.round()}g'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
                child: Text('I\'m Safe - Go Back', style: TextStyle(color: theme.colorScheme.error)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
