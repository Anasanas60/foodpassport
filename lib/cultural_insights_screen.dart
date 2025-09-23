import 'package:flutter/material.dart';

class CulturalInsightsScreen extends StatelessWidget {
  final String dishName;

  const CulturalInsightsScreen({super.key, required this.dishName});

  @override
  Widget build(BuildContext context) {
    Map<String, Map<String, String>> cultureData = {
      "Pad Thai": {
        "origin": "Thailand, 1930s",
        "significance": "Created to promote Thai nationalism and reduce rice consumption during shortage.",
        "festivals": "Celebrated nationwide; street food staple during Songkran Festival.",
        "etiquette": "Eat with fork and spoon. Chopsticks are for noodles only in Chinese-Thai dishes."
      },
      "Sushi": {
        "origin": "Japan, Edo period (1603–1868)",
        "significance": "Originally preserved fish with fermented rice. Evolved into fresh delicacy.",
        "festivals": "Celebrated during Hinamatsuri (Girls’ Day) and New Year.",
        "etiquette": "Dip fish-side (not rice) in soy sauce. Eat in one bite. Don’t mix wasabi in soy sauce."
      },
    };

    var data = cultureData[dishName] ?? {
      "origin": "Unknown",
      "significance": "No cultural data available yet.",
      "festivals": "N/A",
      "etiquette": "Ask locals!"
    };

    return Scaffold(
      appBar: AppBar(
        title: Text('$dishName Culture'),
        backgroundColor: Colors.brown,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: ListTile(
                  leading: const Icon(Icons.flag, color: Colors.brown),
                  title: const Text('Origin', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data["origin"]!),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.history, color: Colors.brown),
                  title: const Text('Significance', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data["significance"]!),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.festival, color: Colors.brown),
                  title: const Text('Festivals', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data["festivals"]!),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.restaurant, color: Colors.brown),
                  title: const Text('Eating Etiquette', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(data["etiquette"]!),
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Dish'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}