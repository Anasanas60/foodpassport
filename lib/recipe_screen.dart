import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/food_state_service.dart';
import 'models/food_item.dart';
import 'cultural_insights_screen.dart';
import 'emergency_alert_screen.dart';

class RecipeScreen extends StatefulWidget {
  final String dishName;

  const RecipeScreen({
    super.key,
    required this.dishName,
  });

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foodState = Provider.of<FoodStateService>(context);
    final FoodItem? currentFood = foodState.currentFoodItem;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentFood?.name ?? widget.dishName),
        backgroundColor: theme.colorScheme.secondary,
        actions: [
          if (currentFood != null) ...[
            IconButton(
              icon: const Icon(Icons.language),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CulturalInsightsScreen(
                      dishName: currentFood.name,
                    ),
                  ),
                );
              },
              tooltip: 'Cultural Insights',
            ),
          ],
        ],
      ),
      body: currentFood != null 
          ? _buildFoodDetails(context, currentFood)
          : _buildPlaceholder(context),
    );
  }

  Widget _buildFoodDetails(BuildContext context, FoodItem foodItem) {
    final theme = Theme.of(context);
    final foodState = Provider.of<FoodStateService>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food Image and Basic Info
          _buildFoodHeader(context, foodItem),
          
          const SizedBox(height: 20),
          
          // Nutrition Information
          _buildNutritionCard(foodItem, theme),
          
          const SizedBox(height: 16),
          
          // Allergen Information
          if (foodItem.detectedAllergens.isNotEmpty) ...[
            _buildAllergenCard(foodItem, theme, foodState),
            const SizedBox(height: 16),
          ],
          
          // Food Details
          _buildFoodDetailsCard(foodItem, theme),
          
          const SizedBox(height: 16),
          
          // Action Buttons
          _buildActionButtons(context, foodItem),
        ],
      ),
    );
  }

  Widget _buildFoodHeader(BuildContext context, FoodItem foodItem) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Food Image Placeholder
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.restaurant,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              foodItem.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Confidence: ${(foodItem.confidenceScore * 100).toStringAsFixed(1)}%',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.source, color: Colors.blue, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Source: ${foodItem.source}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionCard(FoodItem foodItem, ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nutrition Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNutritionItem('Calories', '${foodItem.calories.round()}', Icons.local_fire_department),
                _buildNutritionItem('Protein', '${foodItem.protein.round()}g', Icons.fitness_center),
                _buildNutritionItem('Carbs', '${foodItem.carbs.round()}g', Icons.grain),
                _buildNutritionItem('Fat', '${foodItem.fat.round()}g', Icons.water_drop),
              ],
            ),
            if (foodItem.servingSize != null) ...[
              const SizedBox(height: 12),
              Text(
                'Serving: ${foodItem.servingSize} ${foodItem.servingUnit ?? ''}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildAllergenCard(FoodItem foodItem, ThemeData theme, FoodStateService foodState) {
    final hasAllergyRisk = foodState.hasAllergyRisk;
    
    return Card(
      elevation: 2,
      color: hasAllergyRisk ? Colors.orange[50] : Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  hasAllergyRisk ? Icons.warning : Icons.check_circle,
                  color: hasAllergyRisk ? Colors.orange : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  hasAllergyRisk ? 'Allergy Alert' : 'Allergen Information',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: hasAllergyRisk ? Colors.orange : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Detected allergens: ${foodItem.detectedAllergens.map((a) => a.toUpperCase()).join(', ')}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: hasAllergyRisk ? Colors.orange[800] : Colors.green[800],
              ),
            ),
            if (hasAllergyRisk) ...[
              const SizedBox(height: 8),
              Text(
                'This food contains ingredients you are allergic to!',
                style: TextStyle(color: Colors.orange[800]),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EmergencyAlertScreen(foodItem: foodItem),
                    ),
                  );
                },
                icon: const Icon(Icons.warning),
                label: const Text('View Emergency Info'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFoodDetailsCard(FoodItem foodItem, ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Food Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (foodItem.category != null) ...[
              _buildDetailRow('Category', foodItem.category!),
            ],
            if (foodItem.area != null) ...[
              _buildDetailRow('Cuisine', foodItem.area!),
            ],
            _buildDetailRow('Detection Time', 
                '${foodItem.timestamp.hour}:${foodItem.timestamp.minute.toString().padLeft(2, '0')}'),
            _buildDetailRow('Confidence Level', 
                '${(foodItem.confidenceScore * 100).toStringAsFixed(1)}%'),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, FoodItem foodItem) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              // Add to favorites or journal
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Added ${foodItem.name} to your food journal')),
              );
            },
            icon: const Icon(Icons.bookmark_add),
            label: const Text('Save to Journal'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CulturalInsightsScreen(
                    dishName: foodItem.name,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.language),
            label: const Text('Culture Info'),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant,
              size: 64,
              color: theme.colorScheme.onSurface.withAlpha(77)),
          const SizedBox(height: 16),
          Text(
            'Recipe for ${widget.dishName}',
            style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'No food data available. Scan a food item first!',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/camera');
            },
            child: const Text('Scan Food Now'),
          ),
        ],
      ),
    );
  }
}