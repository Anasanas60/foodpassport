import 'package:flutter/material.dart';
import '../models/food_item.dart';

class EmergencyAlertScreen extends StatelessWidget {
  final FoodItem foodItem;

  const EmergencyAlertScreen({super.key, required this.foodItem});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final allergens = foodItem.detectedAllergens;

    return Scaffold(
      backgroundColor: colorScheme.errorContainer,
      appBar: AppBar(
        title: const Text('🚨 EMERGENCY ALERT'),
        backgroundColor: colorScheme.error,
        foregroundColor: colorScheme.onError,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.medical_services),
            onPressed: () => _showEmergencyContacts(context),
            tooltip: 'Emergency Contacts',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildCriticalAlertSection(context, allergens, colorScheme),
            const SizedBox(height: 24),
            _buildEmergencyActions(context, allergens, colorScheme),
            const SizedBox(height: 24),
            _buildFoodDetailsCard(context, foodItem, colorScheme),
            const SizedBox(height: 24),
            _buildSafetyInformation(context, colorScheme),
            const SizedBox(height: 16),
            _buildSafeReturnButton(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildCriticalAlertSection(BuildContext context, List<String> allergens, ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.error, colorScheme.error.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.error.withAlpha(100),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: colorScheme.onError,
                  shape: BoxShape.circle,
                ),
              ),
              Icon(
                Icons.warning_amber_rounded,
                size: 80,
                color: colorScheme.error,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'ALLERGEN EMERGENCY!',
            style: textTheme.displaySmall?.copyWith(color: colorScheme.onError, letterSpacing: 1.2),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            foodItem.name,
            style: textTheme.headlineMedium?.copyWith(color: colorScheme.onError),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (allergens.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.onError.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.onError),
              ),
              child: Column(
                children: [
                  Text('DETECTED ALLERGENS:', style: textTheme.titleMedium?.copyWith(color: colorScheme.onError)),
                  const SizedBox(height: 8),
                  Text(allergens.map((a) => a.toUpperCase()).join('\n'),
                      style: textTheme.titleLarge?.copyWith(color: colorScheme.onError),
                      textAlign: TextAlign.center),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmergencyActions(BuildContext context, List<String> allergens, ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Text('EMERGENCY ACTIONS', style: textTheme.headlineSmall?.copyWith(color: colorScheme.error)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: ElevatedButton(
            onPressed: () => _callForHelp(context, allergens),
            style: ElevatedButton.styleFrom(backgroundColor: colorScheme.error, foregroundColor: colorScheme.onError),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emergency, size: 24),
                SizedBox(width: 12),
                Text('CALL FOR HELP NOW', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 12),
          child: OutlinedButton(
            onPressed: () => _alertStaff(context, allergens),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(color: colorScheme.error, width: 2),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 20),
                SizedBox(width: 12),
                Text('ALERT RESTAURANT STAFF', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        Container(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _shareLocation(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.secondary,
              side: BorderSide(color: colorScheme.secondary, width: 2),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.location_on, size: 20),
                SizedBox(width: 12),
                Text('SHARE MY LOCATION', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodDetailsCard(BuildContext context, FoodItem foodItem, ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text('FOOD DETAILS', style: textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
              children: [
                _buildNutritionItem(context, 'Calories', '${foodItem.calories.round()}', Icons.local_fire_department, Colors.orange),
                _buildNutritionItem(context, 'Protein', '${foodItem.protein.round()}g', Icons.fitness_center, Colors.blue),
                _buildNutritionItem(context, 'Carbs', '${foodItem.carbs.round()}g', Icons.grain, Colors.green),
                _buildNutritionItem(context, 'Fat', '${foodItem.fat.round()}g', Icons.water_drop, Colors.red),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.secondary),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified, color: colorScheme.secondary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Detection Confidence', style: textTheme.titleMedium),
                        Text('${(foodItem.confidenceScore * 100).toStringAsFixed(1)}% accurate',
                            style: textTheme.bodyMedium?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(BuildContext context, String label, String value, IconData icon, Color color) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: textTheme.bodySmall),
                Text(value, style: textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyInformation(BuildContext context, ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.medical_information, color: colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Text('SAFETY INFORMATION', style: textTheme.headlineSmall),
              ],
            ),
            const SizedBox(height: 16),
            _buildSafetyStep(context, '1. Stop eating immediately', Icons.block, colorScheme.error),
            _buildSafetyStep(context, '2. Notify staff about allergens', Icons.person, colorScheme.primary),
            _buildSafetyStep(context, '3. Use epinephrine if prescribed', Icons.medical_services, colorScheme.error),
            _buildSafetyStep(context, '4. Seek immediate medical attention', Icons.local_hospital, colorScheme.error),
            _buildSafetyStep(context, '5. Stay calm and monitor symptoms', Icons.psychology, colorScheme.secondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyStep(BuildContext context, String text, IconData icon, Color color) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildSafeReturnButton(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: () => _confirmSafeReturn(context),
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.secondary,
          side: BorderSide(color: colorScheme.secondary, width: 2),
        ),
        child: const Text(
          'I\'M SAFE - RETURN TO APP',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _callForHelp(BuildContext context, List<String> allergens) async {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(
        children: [
          Icon(Icons.emergency, color: Colors.white),
          SizedBox(width: 8),
          Text('🚑 Alerting emergency services about allergens'),
        ],
      ),
      backgroundColor: colorScheme.error,
      duration: const Duration(seconds: 4),
    ));

    await Future.delayed(const Duration(seconds: 2));

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Emergency Services Alerted'),
          content: const Text('Help is on the way. Stay calm and wait for assistance.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  void _alertStaff(BuildContext context, List<String> allergens) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(
        children: [
          Icon(Icons.person, color: Colors.white),
          SizedBox(width: 8),
          Text('Alerting restaurant staff about allergens'),
        ],
      ),
      backgroundColor: colorScheme.primary,
      duration: const Duration(seconds: 3),
    ));
  }

  void _shareLocation(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(
        children: [
          Icon(Icons.location_on, color: Colors.white),
          SizedBox(width: 8),
          Text('Sharing your location with emergency contacts'),
        ],
      ),
      backgroundColor: colorScheme.secondary,
      duration: const Duration(seconds: 3),
    ));
  }

  void _showEmergencyContacts(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [BoxShadow(color: Colors.black.withAlpha(100), blurRadius: 32, offset: const Offset(0, -8))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(
              child: Container(width: 60, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 24),
            Text('Emergency Contacts', style: textTheme.headlineMedium),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildContactItem(context, 'Emergency Services', '911', Icons.emergency),
                  _buildContactItem(context, 'Poison Control', '1-800-222-1222', Icons.medical_services),
                  _buildContactItem(context, 'Local Hospital', '(555) 123-4567', Icons.local_hospital),
                  _buildContactItem(context, 'Personal Contact', 'Mom - (555) 987-6543', Icons.person),
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildContactItem(BuildContext context, String name, String number, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12), border: Border.all(color: colorScheme.outline)),
      child: Row(children: [
        Icon(icon, color: colorScheme.primary, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(name, style: textTheme.titleMedium),
            Text(number, style: textTheme.bodyMedium),
          ]),
        ),
        IconButton(icon: Icon(Icons.phone, color: colorScheme.secondary), onPressed: () {}),
      ]),
    );
  }

  void _confirmSafeReturn(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm Safety'),
        content: const Text('Are you sure you\'re safe and want to return to the app?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('STAY HERE')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: ElevatedButton.styleFrom(backgroundColor: colorScheme.secondary, foregroundColor: colorScheme.onSecondary),
            child: const Text('I\'M SAFE'),
          ),
        ],
      ),
    );
  }
}
