import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/food_state_service.dart';
import '../models/food_item.dart';

class FoodJournalScreen extends StatelessWidget {
  const FoodJournalScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final foodState = Provider.of<FoodStateService>(context);
    final journalEntries = foodState.foodHistory;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Journal'),
        elevation: 0,
        centerTitle: true,
        actions: [
          if (journalEntries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () {
                // Show analytics
                _showAnalytics(context, journalEntries, colorScheme);
              },
              tooltip: 'View Analytics',
            ),
        ],
      ),
      body: journalEntries.isEmpty
          ? _buildEmptyState(context, theme, colorScheme)
          : _buildJournalList(context, journalEntries, theme, colorScheme),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/camera'),
        child: const Icon(Icons.camera_alt),
        tooltip: 'Scan New Food',
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book,
                size: 80,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Your Food Journal is Empty',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Start scanning food to build your culinary journey and earn XP!',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/camera'),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan Your First Dish'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalList(BuildContext context, List<FoodItem> entries, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // Stats Overview
        _buildStatsOverview(context, entries, colorScheme),
        
        // Journal Entries
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final item = entries[index];
              return _buildJournalCard(context, item, theme, colorScheme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverview(BuildContext context, List<FoodItem> entries, ColorScheme colorScheme) {
    final totalDishes = entries.length;
    final totalCalories = entries.fold(0, (sum, item) => sum + item.calories.round());
    final uniqueCuisines = entries.map((e) => e.source).toSet().length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(context,
            value: totalDishes.toString(),
            label: 'Dishes',
            icon: Icons.restaurant,
            color: colorScheme.onPrimary,
          ),
          _buildStatItem(context,
            value: '${totalCalories}k',
            label: 'Calories',
            icon: Icons.local_fire_department,
            color: colorScheme.onPrimary,
          ),
          _buildStatItem(context,
            value: uniqueCuisines.toString(),
            label: 'Cuisines',
            icon: Icons.flag,
            color: colorScheme.onPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, {
    required String value,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(color: color, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: textTheme.bodySmall?.copyWith(color: color.withValues(alpha: 0.8)),
        ),
      ],
    );
  }

  Widget _buildJournalCard(BuildContext context, FoodItem item, ThemeData theme, ColorScheme colorScheme) {
    final textTheme = theme.textTheme;
    final allergyWarning = item.detectedAllergens.isNotEmpty;
    final isRecent = DateTime.now().difference(item.timestamp).inDays < 1;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(
            context,
            '/recipe',
            arguments: {'dishName': item.name},
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Food Image
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      image: item.imagePath.isNotEmpty
                          ? DecorationImage(
                              image: AssetImage(item.imagePath),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: item.imagePath.isEmpty
                        ? Icon(
                            Icons.restaurant,
                            size: 40,
                            color: colorScheme.primary,
                          )
                        : null,
                  ),
                  if (isRecent)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.fiber_new,
                          color: colorScheme.onSecondary,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
              
              const SizedBox(width: 16),
              
              // Food Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: textTheme.titleLarge,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (allergyWarning)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: colorScheme.error),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning, color: colorScheme.error, size: 12),
                                const SizedBox(width: 4),
                                Text(
                                  'Allergy',
                                  style: textTheme.labelSmall?.copyWith(color: colorScheme.error, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Nutrition Info
                    Wrap(
                      spacing: 12,
                      children: [
                        _buildNutritionChip(
                          '${item.calories.round()} cal',
                          Icons.local_fire_department,
                          Colors.orange,
                        ),
                        _buildNutritionChip(
                          '${item.protein.round()}g protein',
                          Icons.fitness_center,
                          Colors.blue,
                        ),
                        _buildNutritionChip(
                          '${item.carbs.round()}g carbs',
                          Icons.grass,
                          Colors.green,
                        ),
                        _buildNutritionChip(
                          '${item.fat.round()}g fat',
                          Icons.water_drop,
                          Colors.red,
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Date and Source
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(item.timestamp),
                          style: textTheme.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.secondary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.source,
                            style: textTheme.labelSmall?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    
                    // XP Reward
                    if (isRecent)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.celebration, size: 12, color: colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              '+15 XP',
                              style: textTheme.labelSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              // Chevron
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNutritionChip(String text, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAnalytics(BuildContext context, List<FoodItem> entries, ColorScheme colorScheme) {
    final textTheme = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Food Journal Analytics',
                style: textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              // Add analytics content here
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.analytics, size: 80, color: colorScheme.primary.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      Text(
                        'Analytics Coming Soon',
                        style: textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track your eating habits and progress',
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}