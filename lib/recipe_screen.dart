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
            if (widget.foodData != null) ...[
              const Text(
                'Ingredients:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              ...(widget.foodData!['ingredients'] as List<String>).map((ingredient) => 
                Text('• $ingredient')
              ),
              const SizedBox(height: 20),
              const Text(
                'Instructions:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(widget.foodData!['recipe'] ?? 'No recipe available.'),
            ] else ...[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.restaurant, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Recipe for ${widget.dishName}',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    const Text('Recipe information will be displayed here.'),
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