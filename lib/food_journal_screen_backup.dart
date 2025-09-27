import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/food_state_service.dart';
import 'models/food_item.dart';
import 'passport_stamps_screen.dart';

class FoodJournalScreen extends StatefulWidget {
  const FoodJournalScreen({super.key});

  @override
  State<FoodJournalScreen> createState() => _FoodJournalScreenState();
}

class _FoodJournalScreenState extends State<FoodJournalScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foodState = Provider.of<FoodStateService>(context);
    final List<FoodItem> foodEntries = foodState.foodHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Journal'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.star),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PassportStampsScreen(),
                ),
              );
            },
            tooltip: 'View Passport Stamps',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.colorScheme.primaryContainer.withOpacity(0.3),
              theme.colorScheme.secondaryContainer.withOpacity(0.1),
            ],
          ),
        ),
        child: _buildContent(theme, foodEntries, foodState),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, List<FoodItem> foodEntries, FoodStateService foodState) {
    if (foodEntries.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Column(
      children: [
        _buildStatsHeader(theme, foodEntries),
        Expanded(
          child: _buildFoodList(theme, foodEntries, foodState),
        ),
      ],
    );
  }

  // Rest of the FoodJournalScreen methods remain the same...
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Food Entries Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan some food to start your journal!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to camera screen
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Scan Your First Food'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader(ThemeData theme, List<FoodItem> foodEntries) {
    final totalFoods = foodEntries.length;
    final totalCalories = foodEntries.fold<double>(0, (sum, item) => sum + item.calories);
    final uniqueCuisines = foodEntries.map((e) => e.area ?? 'Unknown').toSet().length;

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(theme, 'Total Foods', totalFoods.toString(), Icons.restaurant),
            _buildStatItem(theme, 'Total Calories', totalCalories.round().toString(), Icons.local_fire_department),
            _buildStatItem(theme, 'Cuisines', uniqueCuisines.toString(), Icons.public),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(ThemeData theme, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodList(ThemeData theme, List<FoodItem> foodEntries, FoodStateService foodState) {
    return ListView.builder(
      itemCount: foodEntries.length,
      itemBuilder: (context, index) {
        final foodItem = foodEntries[index];
        return _buildFoodItemCard(theme, foodItem, foodState, index);
      },
    );
  }

  Widget _buildFoodItemCard(ThemeData theme, FoodItem foodItem, FoodStateService foodState, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    foodItem.name,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                  onPressed: () {
                    _showDeleteDialog(context, foodItem, foodState, index);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildNutritionChip(theme, '${foodItem.calories.round()} cal', Icons.local_fire_department),
                const SizedBox(width: 8),
                _buildNutritionChip(theme, '${foodItem.protein.round()}g protein', Icons.fitness_center),
                const SizedBox(width: 8),
                if (foodItem.area != null) _buildNutritionChip(theme, foodItem.area!, Icons.public),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Scanned on ${_formatDate(foodItem.timestamp)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            if (foodItem.detectedAllergens.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: foodItem.detectedAllergens.map((allergen) => 
                  Chip(
                    label: Text(allergen.toUpperCase()),
                    backgroundColor: theme.colorScheme.errorContainer,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onErrorContainer,
                      fontSize: 10,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  )
                ).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionChip(ThemeData theme, String text, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(text),
      backgroundColor: theme.colorScheme.primaryContainer,
      labelStyle: TextStyle(
        color: theme.colorScheme.onPrimaryContainer,
        fontSize: 12,
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showDeleteDialog(BuildContext context, FoodItem foodItem, FoodStateService foodState, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Food Entry?'),
        content: Text('Are you sure you want to delete "${foodItem.name}" from your journal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              foodState.removeFromHistory(index);
              setState(() {});
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

