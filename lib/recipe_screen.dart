import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/recipe_data.dart';
import 'viewmodels/recipe_viewmodel.dart';

class RecipeScreen extends StatelessWidget {
  final String dishName;
  final String? imagePath;

  const RecipeScreen({super.key, required this.dishName, this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RecipeViewModel(context, dishName),
      child: Consumer<RecipeViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Recipe Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 0,
              centerTitle: true,
              actions: [
                if (viewModel.recipeData != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: viewModel.loadRecipeData,
                    tooltip: 'Refresh recipe',
                  ),
              ],
            ),
            body: _buildRecipeContent(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildRecipeContent(BuildContext context, RecipeViewModel viewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (viewModel.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primary.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Analyzing Recipe',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Using Spoonacular AI to generate the perfect recipe',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      );
    }

    if (viewModel.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 50,
                color: colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Recipe Unavailable',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'We couldn\'t load the recipe data. Please check your connection and try again.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: viewModel.loadRecipeData,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (viewModel.recipeData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restaurant_menu,
                size: 50,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Recipe Found',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We couldn\'t find a recipe for "${viewModel.dishName}"',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    final recipe = viewModel.recipeData!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Achievement Banner
          _buildAchievementBanner(context, viewModel),

          // Recipe Header
          _buildRecipeHeader(context, viewModel, recipe),

          const SizedBox(height: 20),

          // Allergy Warnings
          _buildAllergyWarnings(context, viewModel),
          
          if (viewModel.detectedAllergens.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildDetectedAllergens(context, viewModel),
          ],

          const SizedBox(height: 20),

          // Ingredients Section
          _buildSectionCard(
            context: context,
            title: 'Ingredients',
            icon: Icons.shopping_basket,
            color: colorScheme.primary,
            child: Column(
              children: recipe.ingredients.map(
                (ingredient) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withAlpha(20),
                          shape: BoxShape.circle,
                          border: Border.all(color: colorScheme.primary),
                        ),
                        child: Icon(
                          Icons.circle,
                          size: 8,
                          color: colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          ingredient,
                          style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    ],
                  ),
                ),
              ).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Instructions Section
          _buildSectionCard(
            context: context,
            title: 'Cooking Instructions',
            icon: Icons.menu_book,
            color: colorScheme.secondary,
            child: Column(
              children: recipe.instructions.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${entry.key + 1}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Tips Section
          if (recipe.tips.isNotEmpty) 
          _buildSectionCard(
            context: context,
            title: 'Chef\'s Tips',
            icon: Icons.lightbulb,
            color: Colors.amber,
            child: Column(
              children: recipe.tips.map(
                (tip) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.lightbulb_outline, size: 20, color: Colors.amber),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          tip,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: colorScheme.onSurface,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ).toList(),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAchievementBanner(BuildContext context, RecipeViewModel viewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.celebration, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recipe Unlocked!',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '+10 XP • New dish discovered',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecipeHeader(BuildContext context, RecipeViewModel viewModel, RecipeData recipe) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              recipe.name,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.primary),
                  ),
                  child: Text(
                    recipe.cuisine,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.secondary),
                  ),
                  child: Text(
                    recipe.category,
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.tertiaryContainer.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.tertiary),
                  ),
                  child: Text(
                    recipe.difficulty,
                    style: TextStyle(
                      color: colorScheme.tertiary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildInfoItem(
                  icon: Icons.schedule,
                  text: recipe.cookTime,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 20),
                _buildInfoItem(
                  icon: Icons.people,
                  text: 'Serves ${recipe.servings}',
                  color: colorScheme.secondary,
                ),
                const SizedBox(width: 20),
                _buildInfoItem(
                  icon: Icons.local_fire_department,
                  text: 'Nutrition Info',
                  color: colorScheme.tertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllergyWarnings(BuildContext context, RecipeViewModel viewModel) {
    final theme = Theme.of(context);
    if (viewModel.emergencyAllergens.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withAlpha(50),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'ALLERGY ALERT',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '⚠️ This dish contains: ${viewModel.emergencyAllergens.join(', ')}',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: Colors.red[700],
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Avoid consumption if you have allergies to these ingredients',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.red[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedAllergens(BuildContext context, RecipeViewModel viewModel) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    if (viewModel.detectedAllergens.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.secondary),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ingredients Info',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Contains: ${viewModel.detectedAllergens.join(', ')}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text, required Color color}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: const Color(0xFF333333),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}