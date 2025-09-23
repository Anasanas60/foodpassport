import 'package:flutter/material.dart';

class RecipeScreen extends StatefulWidget {
  final String dishName;
  final Map<String, dynamic>? foodData; // NEW: Add foodData parameter
  
  const RecipeScreen({
    super.key,
    required this.dishName,
    this.foodData, // NEW: Make it optional
  });

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe: ${widget.dishName}'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Use real data if available, otherwise show placeholder
            if (widget.foodData != null) ...[
              Text(
                'Ingredients:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...(widget.foodData!['ingredients'] as List<String>).map((ingredient) => 
                Text('• $ingredient')
              ).toList(),
              const SizedBox(height: 20),
              Text(
                'Instructions:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(widget.foodData!['recipe'] ?? 'No recipe available.'),
            ] else ...[
              // Fallback if no foodData provided
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Recipe for ${widget.dishName}',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text('Recipe information will be displayed here.'),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}