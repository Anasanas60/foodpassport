import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/recipe_service.dart';
import '../services/user_profile_service.dart';
import '../models/recipe_data.dart';
import '../utils/allergen_checker.dart';

class RecipeScreen extends StatefulWidget {
  final String dishName;
  final String? imagePath;

  const RecipeScreen({super.key, required this.dishName, this.imagePath});

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

      final recipe = await RecipeService.getAIRecipe(
        widget.dishName,
        dietaryRestrictions: userProfile?.allergies ?? [],
      );

      if (mounted) {
        setState(() {
          _recipeData = recipe;
          _isLoading = false;

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

  Widget _buildAllergyWarnings(ThemeData theme) {
    if (_emergencyAllergens.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.error),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: theme.colorScheme.error),
              const SizedBox(width: 8),
              Text(
                'ALLERGY ALERT',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This dish contains: ${_emergencyAllergens.join(', ')}',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error),
          ),
          const SizedBox(height: 4),
          Text(
            'Avoid if you have these allergies',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedAllergens(ThemeData theme) {
    if (_detectedAllergens.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Contains: ${_detectedAllergens.join(', ')}',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeContent(BuildContext context) {
    final theme = Theme.of(context);

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
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text(
              'Failed to load recipe data',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text('Please check your connection and try again', style: theme.textTheme.bodyMedium),
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
            Icon(Icons.restaurant_menu, size: 64, color: theme.colorScheme.onSurface.withOpacity(0.4)),
            const SizedBox(height: 16),
            Text('No recipe data available', style: theme.textTheme.titleMedium),
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    children: [
                      Chip(
                        label: Text(recipe.cuisine),
                        backgroundColor: theme.colorScheme.primaryContainer,
                      ),
                      Chip(
                        label: Text(recipe.category),
                        backgroundColor: theme.colorScheme.secondaryContainer,
                      ),
                      Chip(
                        label: Text(recipe.difficulty),
                        backgroundColor: theme.colorScheme.tertiaryContainer,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(recipe.cookTime, style: theme.textTheme.bodyMedium),
                      const SizedBox(width: 16),
                      Icon(Icons.people, size: 16, color: theme.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text('Serves ${recipe.servings}', style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Allergy Warnings
          _buildAllergyWarnings(theme),
          _buildDetectedAllergens(theme),

          const SizedBox(height: 16),

          // Ingredients Section
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Ingredients', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...recipe.ingredients.map(
                    (ingredient) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: theme.colorScheme.primary),
                          const SizedBox(width: 12),
                          Expanded(child: Text(ingredient, style: theme.textTheme.bodyMedium)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Instructions Section
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Instructions', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...recipe.instructions.asMap().entries.map(
                        (entry) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Text(
                                    '${entry.key + 1}',
                                    style: theme.textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(entry.value, style: theme.textTheme.bodyMedium)),
                            ],
                          ),
                        ),
                      ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Tips Section
          if (recipe.tips.isNotEmpty) ...[
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Chef\'s Tips', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    ...recipe.tips.map(
                      (tip) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb_outline, size: 16, color: theme.colorScheme.secondary),
                            const SizedBox(width: 12),
                            Expanded(child: Text(tip, style: theme.textTheme.bodyMedium)),
                          ],
                        ),
                      ),
                    ),
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
          if (_recipeData != null)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _loadRecipeData,
              tooltip: 'Refresh recipe',
            ),
        ],
      ),
      body: _buildRecipeContent(context),
    );
  }
}
