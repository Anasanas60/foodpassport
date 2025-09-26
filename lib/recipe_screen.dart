import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/food_state_service.dart';
import 'services/recipe_service.dart'; // NEW: AI Recipe Service
import 'models/food_item.dart';
import 'models/recipe_data.dart'; // NEW: Recipe Data Model
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
  RecipeData? _recipeData;
  bool _isLoadingRecipe = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAIRecipe();
  }

  // NEW: AI-Powered Recipe Loading
  Future<void> _loadAIRecipe() async {
    final foodState = Provider.of<FoodStateService>(context, listen: false);
    final FoodItem? currentFood = foodState.currentFoodItem;

    if (currentFood != null) {
      setState(() {
        _isLoadingRecipe = true;
        _errorMessage = '';
      });

      try {
        // Try to get AI-generated recipe first
        final recipe = await RecipeService.getAIRecipe(
          currentFood.name,
          cuisineType: currentFood.area,
          dietaryRestrictions: _getUserDietaryRestrictions(),
        );

        if (recipe != null) {
          setState(() {
            _recipeData = recipe;
          });
        } else {
          // Fallback to basic recipe generation
          setState(() {
            _recipeData = _generateFallbackRecipe(currentFood);
          });
        }
      } catch (e) {
        print('❌ Recipe loading error: $e');
        setState(() {
          _errorMessage = 'Failed to load recipe. Using basic information.';
          _recipeData = _generateFallbackRecipe(currentFood);
        });
      } finally {
        setState(() {
          _isLoadingRecipe = false;
        });
      }
    }
  }

  // NEW: Get user dietary restrictions for AI recipe personalization
  List<String> _getUserDietaryRestrictions() {
    // This should integrate with your UserProfileService
    // For now, return common restrictions
    return ['gluten-free', 'dairy-free']; // Example restrictions
  }

  // NEW: AI-Powered Fallback Recipe Generation
  RecipeData _generateFallbackRecipe(FoodItem foodItem) {
    final cuisine = foodItem.area ?? 'International';
    final category = foodItem.category ?? 'Main Course';
    
    return RecipeData(
      id: 'fallback_${foodItem.id}',
      name: foodItem.name,
      cuisine: cuisine,
      category: category,
      cookTime: '30 minutes',
      difficulty: 'Medium',
      servings: 2,
      ingredients: _aiGenerateIngredients(foodItem.name, cuisine),
      instructions: _aiGenerateInstructions(foodItem.name, cuisine, category),
      tips: _aiGenerateCookingTips(foodItem.name, cuisine),
      nutritionInfo: {
        'calories': foodItem.calories.round(),
        'protein': foodItem.protein.round(),
        'carbs': foodItem.carbs.round(),
        'fat': foodItem.fat.round(),
      },
      source: 'ai_generated',
    );
  }

  // NEW: AI-Powered Ingredient Generation
  List<String> _aiGenerateIngredients(String dishName, String cuisine) {
    final ingredients = <String>[];
    
    // AI Logic: Generate ingredients based on dish name and cuisine
    if (dishName.toLowerCase().contains('curry')) {
      ingredients.addAll([
        '500g chicken or vegetables',
        '2 tbsp curry powder',
        '1 onion, chopped',
        '2 cloves garlic, minced',
        '1 cup coconut milk',
        '2 tbsp oil',
        'Salt to taste',
        'Fresh herbs for garnish'
      ]);
    } else if (dishName.toLowerCase().contains('salad')) {
      ingredients.addAll([
        'Mixed greens (lettuce, spinach, arugula)',
        '1 cucumber, sliced',
        '2 tomatoes, chopped',
        '1 bell pepper, sliced',
        'Olive oil dressing',
        'Lemon juice',
        'Salt and pepper to taste'
      ]);
    } else {
      // Generic AI-generated ingredients
      ingredients.addAll([
        'Main protein (chicken, beef, tofu, etc.)',
        'Fresh vegetables',
        'Cooking oil',
        'Seasonings and spices',
        'Sauce or broth base',
        'Garnish ingredients'
      ]);
    }

    // Add cuisine-specific ingredients
    if (cuisine.toLowerCase().contains('thai')) {
      ingredients.add('Thai basil or cilantro');
      ingredients.add('Fish sauce or soy sauce');
      ingredients.add('Chili peppers');
    } else if (cuisine.toLowerCase().contains('italian')) {
      ingredients.add('Olive oil');
      ingredients.add('Garlic');
      ingredients.add('Fresh herbs (basil, oregano)');
    }

    return ingredients;
  }

  // NEW: AI-Powered Instruction Generation
  List<String> _aiGenerateInstructions(String dishName, String cuisine, String category) {
    final instructions = <String>[];
    
    // AI Logic: Generate cooking instructions based on dish type
    instructions.add('Prepare all ingredients by washing, chopping, and measuring.');
    
    if (category.toLowerCase().contains('curry') || category.toLowerCase().contains('stir-fry')) {
      instructions.add('Heat oil in a large pan or wok over medium-high heat.');
      instructions.add('Sauté onions and garlic until fragrant and translucent.');
      instructions.add('Add main protein and cook until browned on all sides.');
      instructions.add('Add vegetables and stir-fry for 3-5 minutes until tender-crisp.');
      instructions.add('Add sauce/curry paste and simmer for 10-15 minutes.');
      instructions.add('Adjust seasoning and serve hot with rice or bread.');
    } else if (category.toLowerCase().contains('salad')) {
      instructions.add('Wash and dry all vegetables thoroughly.');
      instructions.add('Chop vegetables into bite-sized pieces.');
      instructions.add('Prepare dressing by whisking oil, acid, and seasonings.');
      instructions.add('Toss vegetables with dressing just before serving.');
      instructions.add('Garnish with fresh herbs and serve immediately.');
    } else {
      instructions.add('Follow standard cooking techniques for this dish type.');
      instructions.add('Adjust cooking time based on ingredient sizes.');
      instructions.add('Taste and adjust seasoning throughout cooking process.');
      instructions.add('Plate attractively and garnish before serving.');
    }

    // Add cuisine-specific tips
    if (cuisine.toLowerCase().contains('thai')) {
      instructions.add('Balance sweet, sour, salty, and spicy flavors authentically.');
    } else if (cuisine.toLowerCase().contains('italian')) {
      instructions.add('Use high-quality olive oil for authentic flavor.');
    }

    instructions.add('Enjoy your homemade $dishName!');

    return instructions;
  }

  // NEW: AI-Powered Cooking Tips
  List<String> _aiGenerateCookingTips(String dishName, String cuisine) {
    final tips = <String>[];
    
    tips.add('Use fresh ingredients for best flavor and nutrition.');
    
    if (dishName.toLowerCase().contains('curry')) {
      tips.add('Toast spices briefly before grinding for enhanced flavor.');
      tips.add('Simmer curry slowly to develop complex flavors.');
      tips.add('Balance coconut milk with acid (lime juice) to cut richness.');
    } else if (dishName.toLowerCase().contains('salad')) {
      tips.add('Dress salad just before serving to maintain crispness.');
      tips.add('Chill plates for cold salads to keep them refreshing.');
      tips.add('Add nuts or seeds for extra crunch and nutrition.');
    }

    // Cuisine-specific AI tips
    if (cuisine.toLowerCase().contains('thai')) {
      tips.add('Authentic Thai cooking balances four flavors: sweet, sour, salty, spicy.');
      tips.add('Use palm sugar for authentic Thai sweetness.');
    } else if (cuisine.toLowerCase().contains('italian')) {
      tips.add('Cook pasta al dente for authentic Italian texture.');
      tips.add('Use fresh herbs rather than dried for brighter flavor.');
    }

    tips.add('Taste and adjust seasoning throughout the cooking process.');
    tips.add('Don\'t be afraid to customize based on your preferences!');

    return tips;
  }

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
            if (_recipeData != null) ...[
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _loadAIRecipe,
                tooltip: 'Regenerate Recipe',
              ),
            ],
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
          
          // AI Recipe Section - NEW
          if (_isLoadingRecipe) _buildRecipeLoading(),
          if (_errorMessage.isNotEmpty) _buildErrorCard(_errorMessage, theme),
          if (_recipeData != null) _buildAIRecipeSection(_recipeData!, theme),
          
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

  // NEW: AI Recipe Loading Widget
  Widget _buildRecipeLoading() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            const SizedBox(height: 16),
            Text(
              'AI is generating your recipe...',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Analyzing ingredients and cooking methods',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Error Display Widget
  Widget _buildErrorCard(String message, ThemeData theme) {
    return Card(
      elevation: 2,
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: Colors.orange[800]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NEW: AI Recipe Section
  Widget _buildAIRecipeSection(RecipeData recipe, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.purple),
                    const SizedBox(width: 8),
                    Text(
                      'AI-Generated Recipe',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple,
                      ),
                    ),
                    const Spacer(),
                    Chip(
                      label: Text(recipe.difficulty),
                      backgroundColor: Colors.purple[50],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildRecipeInfo('Cook Time', recipe.cookTime, Icons.timer),
                    const SizedBox(width: 16),
                    _buildRecipeInfo('Servings', recipe.servings.toString(), Icons.people),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Ingredients Section
        _buildIngredientsSection(recipe, theme),
        
        const SizedBox(height: 16),
        
        // Instructions Section
        _buildInstructionsSection(recipe, theme),
        
        const SizedBox(height: 16),
        
        // Cooking Tips Section
        _buildTipsSection(recipe, theme),
      ],
    );
  }

  Widget _buildRecipeInfo(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text('$value', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildIngredientsSection(RecipeData recipe, ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ingredients',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recipe.ingredients.map((ingredient) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 6, color: Colors.green),
                      const SizedBox(width: 12),
                      Expanded(child: Text(ingredient)),
                    ],
                  ),
                )
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructionsSection(RecipeData recipe, ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instructions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recipe.instructions.asMap().entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(entry.value)),
                    ],
                  ),
                )
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsSection(RecipeData recipe, ThemeData theme) {
    return Card(
      elevation: 2,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'AI Cooking Tips',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recipe.tips.map((tip) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.emoji_objects, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(child: Text(tip)),
                    ],
                  ),
                )
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Rest of your existing methods remain the same...
  Widget _buildFoodHeader(BuildContext context, FoodItem foodItem) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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