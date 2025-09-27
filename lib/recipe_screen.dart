import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/recipe_service.dart';
import '../services/user_profile_service.dart';
import '../models/recipe_data.dart';
import '../utils/allergen_checker.dart';

class RecipeScreen extends StatefulWidget {
  final String dishName;
  const RecipeScreen({super.key, required this.dishName});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  RecipeData? _recipeData;
  bool _isLoading = true;
  bool _hasError = false;
  List<String> _detectedAllergens = [];
  List<String> _emergencyAllergens = [];

  @override
  void initState() {
    super.initState();
    _loadRecipeData();
  }

  Future<void> _loadRecipeData() async {
    try {
      final userProfileService = Provider.of<UserProfileService>(context, listen: false);
      final userProfile = userProfileService.userProfile;
      
      // Get real recipe data from Spoonacular API
      final recipe = await RecipeService.getAIRecipe(
        widget.dishName,
        dietaryRestrictions: userProfile?.allergies ?? [],
      );

      if (mounted) {
        setState(() {
          _recipeData = recipe;
          _isLoading = false;
          
          // Check for allergens
          if (recipe != null && userProfile != null) {
            _detectedAllergens = AllergenChecker.detectAllergens(
              foodName: recipe.name,
              description: recipe.summary,
              cuisineType: recipe.cuisine,
              ingredients: recipe.ingredients,
            );
            
            _emergencyAllergens = AllergenChecker.getEmergencyAllergens(
              detectedAllergens: _detectedAllergens,
              userAllergies: userProfile.allergies,
            );
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Widget _buildAllergyWarnings() {
    if (_emergencyAllergens.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.red[700]),
              const SizedBox(width: 8),
              Text(
                'ALLERGY ALERT',
                style: TextStyle(
                  color: Colors.red[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This dish contains: ${_emergencyAllergens.join(', ')}',
            style: TextStyle(
              color: Colors.red[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Avoid if you have these allergies',
            style: TextStyle(
              color: Colors.red[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedAllergens() {
    if (_detectedAllergens.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.orange[700]),
              const SizedBox(width: 8),
              Text(
                'Contains: ${_detectedAllergens.join(', ')}',
                style: TextStyle(
                  color: Colors.orange[700],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing recipe with Spoonacular AI...'),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Failed to load recipe data',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text('Please check your connection and try again'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecipeData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_recipeData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No recipe data available'),
          ],
        ),
      );
    }

    final recipe = _recipeData!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recipe Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: [
                      Chip(
                        label: Text(recipe.cuisine),
                        backgroundColor: Colors.blue[50],
                      ),
                      Chip(
                        label: Text(recipe.category),
                        backgroundColor: Colors.green[50],
                      ),
                      Chip(
                        label: Text(recipe.difficulty),
                        backgroundColor: Colors.orange[50],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(recipe.cookTime),
                      const SizedBox(width: 16),
                      Icon(Icons.people, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text('Serves ${recipe.servings}'),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Allergy Warnings
          _buildAllergyWarnings(),
          _buildDetectedAllergens(),

          const SizedBox(height: 16),

          // Ingredients Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingredients',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...recipe.ingredients.map((ingredient) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.blue),
                        const SizedBox(width: 12),
                        Expanded(child: Text(ingredient)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Instructions Section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Instructions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...recipe.instructions.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              '${entry.key + 1}',
                              style: const TextStyle(
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
                  )),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tips Section
          if (recipe.tips.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Chef\'s Tips',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...recipe.tips.map((tip) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 16, color: Colors.amber),
                          const SizedBox(width: 12),
                          Expanded(child: Text(tip)),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe: ${widget.dishName}'),
        actions: [
          if (_recipeData != null) IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadRecipeData,
            tooltip: 'Refresh recipe',
          ),
        ],
      ),
      body: _buildRecipeContent(),
    );
  }
}