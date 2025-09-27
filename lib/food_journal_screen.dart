import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../services/food_state_service.dart';
import '../models/food_item.dart';

class FoodJournalScreen extends StatefulWidget {
  const FoodJournalScreen({super.key});

  @override
  State<FoodJournalScreen> createState() => _FoodJournalScreenState();
}

class _FoodJournalScreenState extends State<FoodJournalScreen> {
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foodState = Provider.of<FoodStateService>(context);
    final List<FoodItem> foodEntries = foodState.foodHistory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Journal'),
      ),
      body: foodEntries.isEmpty
          ? _buildEmptyState(theme)
          : _buildFoodList(theme, foodEntries, foodState),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.restaurant_menu,
            size: 64,
            color: theme.colorScheme.onSurface.withAlpha(128),
          ),
          const SizedBox(height: 16),
          Text(
            'No Food Entries Yet',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(179),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scan some food to start your journal!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(128),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, '/camera'),
            icon: const Icon(Icons.camera_alt),
            label: const Text('Scan Your First Food'),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(
      ThemeData theme, List<FoodItem> foodEntries, FoodStateService foodState) {
    return ListView.builder(
      itemCount: foodEntries.length,
      itemBuilder: (context, index) {
        final foodItem = foodEntries[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: foodItem.photoPath != null
                ? Image.file(File(foodItem.photoPath!), width: 50, height: 50, fit: BoxFit.cover)
                : Icon(Icons.fastfood, size: 40, color: theme.colorScheme.primary),
            title: Text(foodItem.name),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${foodItem.calories.round()} cal • Allergens: ${foodItem.detectedAllergens.join(', ')}'),
                if (foodItem.notes != null && foodItem.notes!.isNotEmpty)
                  Text('Notes: ${foodItem.notes}', maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: theme.colorScheme.error),
              onPressed: () => _showDeleteDialog(context, foodItem, foodState, index),
            ),
            onTap: () async {
              await _showEditEntryDialog(context, foodItem, foodState, index);
              setState(() {});
            },
          ),
        );
      },
    );
  }

  Future<void> _showDeleteDialog(
      BuildContext context, FoodItem foodItem, FoodStateService foodState, int index) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Food Entry?'),
        content: Text('Are you sure you want to delete "${foodItem.name}" from your journal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      foodState.removeFromHistory(index);
      setState(() {});
    }
  }

  Future<void> _showEditEntryDialog(BuildContext context, FoodItem foodItem, FoodStateService foodState, int index) async {
    final TextEditingController notesController = TextEditingController(text: foodItem.notes);
    String? photoPath = foodItem.photoPath;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text('Edit Notes & Photo\n${foodItem.name}'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (photoPath != null)
                    Image.file(File(photoPath!), height: 150, fit: BoxFit.cover),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.camera_alt),
                        onPressed: () async {
                          final XFile? picked = await _picker.pickImage(source: ImageSource.camera);
                          if (picked != null) {
                            setDialogState(() {
                              photoPath = picked.path;
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.photo_library),
                        onPressed: () async {
                          final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
                          if (picked != null) {
                            setDialogState(() {
                              photoPath = picked.path;
                            });
                          }
                        },
                      ),
                      if (photoPath != null)
                        IconButton(
                          icon: const Icon(Icons.delete_forever),
                          onPressed: () {
                            setDialogState(() {
                              photoPath = null;
                            });
                          },
                        ),
                    ],
                  ),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(labelText: 'Notes'),
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final updatedItem = FoodItem(
                    id: foodItem.id,
                    name: foodItem.name,
                    confidenceScore: foodItem.confidenceScore,
                    calories: foodItem.calories,
                    protein: foodItem.protein,
                    carbs: foodItem.carbs,
                    fat: foodItem.fat,
                    source: foodItem.source,
                    detectedAllergens: foodItem.detectedAllergens,
                    imagePath: foodItem.imagePath,
                    timestamp: foodItem.timestamp,
                    photoPath: photoPath,
                    notes: notesController.text.trim(),
                    cuisineType: foodItem.cuisineType,
                    ingredients: foodItem.ingredients,
                    nutritionInfo: foodItem.nutritionInfo,
                    description: foodItem.description,
                    isVerified: foodItem.isVerified,
                    area: foodItem.area,
                    position: foodItem.position,
                  );

                  foodState.updateFoodAt(index, updatedItem);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );

    setState(() {});
  }
}
