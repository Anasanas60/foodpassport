import 'package:flutter/material.dart';

class RecipeScreen extends StatefulWidget {
  final String dishName;
  final Map<String, dynamic>? foodData;

  const RecipeScreen({
    super.key,
    required this.dishName,
    this.foodData,
  });

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe: ${widget.dishName}'),
        backgroundColor: theme.colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.foodData != null
            ? ListView(
                children: [
                  Text(
                    'Ingredients:',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ...(widget.foodData!['ingredients'] as List<String>).map(
                    (ingredient) =>
                        Text('• $ingredient', style: theme.textTheme.bodyLarge),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Instructions:',
                    style: theme.textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.foodData!['recipe'] ?? 'No recipe available.',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant,
                        size: 64,
                        color: theme.colorScheme.onSurface.withAlpha(77)),
                    const SizedBox(height: 16),
                    Text(
                      'Recipe for ${widget.dishName}',
                      style: theme.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Recipe information will be displayed here.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
