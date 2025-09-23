import 'package:flutter/material.dart';

class RecipeScreen extends StatelessWidget {
  final String dishName;

  const RecipeScreen({super.key, required this.dishName});

  @override
  Widget build(BuildContext context) {
    Map<String, List<String>> recipes = {
      "Pad Thai": [
        "Soak rice noodles in warm water for 30 mins.",
        "Stir-fry tofu, shrimp, egg in wok.",
        "Add noodles, tamarind sauce, fish sauce, palm sugar.",
        "Toss with bean sprouts, garlic chives.",
        "Top with crushed peanuts and lime."
      ],
      "Sushi": [
        "Cook sushi rice with vinegar mixture.",
        "Slice raw fish thinly.",
        "Roll rice and fish in seaweed sheets.",
        "Serve with soy sauce, wasabi, pickled ginger."
      ],
    };

    List<String> steps = recipes[dishName] ?? ["Recipe not available yet."];

    return Scaffold(
      appBar: AppBar(
        title: Text('$dishName Recipe'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ingredients:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...[
              "Rice Noodles, Tofu, Shrimp, Egg",
              "Fish Sauce, Tamarind, Palm Sugar",
              "Bean Sprouts, Garlic Chives, Lime",
              "Crushed Peanuts"
            ].map((ing) => ListTile(title: Text(ing), leading: const Icon(Icons.circle, size: 8))),
            const Divider(height: 32),
            const Text('Instructions:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...steps.asMap().entries.map((e) {
              return ListTile(
                title: Text(e.value),
                leading: CircleAvatar(child: Text("${e.key + 1}")),
              );
            }),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Dish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}