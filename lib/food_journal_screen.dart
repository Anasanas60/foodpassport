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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Journal'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
      body: journalEntries.isEmpty
          ? Center(
              child: Text(
                'No journal entries yet.\nScan some food to get started!',
                style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: journalEntries.length,
              itemBuilder: (context, index) {
                final item = journalEntries[index];
                return _buildJournalCard(context, item, theme);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/camera'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.camera_alt),
        tooltip: 'Scan New Food',
      ),
    );
  }

  Widget _buildJournalCard(BuildContext context, FoodItem item, ThemeData theme) {
    final allergyWarning = item.detectedAllergens.isNotEmpty;
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, '/recipe', arguments: {'dishName': item.name});
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: item.imagePath.isNotEmpty
                    ? Image.asset(
                        item.imagePath,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: theme.colorScheme.surface,
                        child: Icon(Icons.fastfood, size: 40, color: theme.colorScheme.onSurfaceVariant),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                        'Calories: ${item.calories.round()} | Protein: ${item.protein.round()}g | Carbs: ${item.carbs.round()}g | Fat: ${item.fat.round()}g',
                        style: theme.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Text(
                      'Scanned on: ${_formatDate(item.timestamp)}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    ),
                    if (allergyWarning) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error, size: 18),
                          const SizedBox(width: 6),
                          Text(
                            'Contains allergens',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    if (difference.inDays == 0) return 'Today';
    if (difference.inDays == 1) return 'Yesterday';
    if (difference.inDays < 7) return '${difference.inDays} days ago';
    return '${date.day}/${date.month}/${date.year}';
  }
}
