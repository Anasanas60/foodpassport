import 'package:flutter/material.dart';

class CulturalInsightsScreen extends StatefulWidget {
  final String dishName;
  final Map<String, dynamic>? foodData; // NEW: Add foodData parameter
  
  const CulturalInsightsScreen({
    super.key,
    required this.dishName,
    this.foodData, // NEW: Make it optional
  });

  @override
  State<CulturalInsightsScreen> createState() => _CulturalInsightsScreenState();
}

class _CulturalInsightsScreenState extends State<CulturalInsightsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Culture: ${widget.dishName}'),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Use real data if available, otherwise show placeholder
            if (widget.foodData != null) ...[
              Text(
                'Origin: ${widget.foodData!['origin'] ?? 'Unknown'}',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Cultural Information:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text('Cultural insights will be displayed here based on the dish origin.'),
            ] else ...[
              // Fallback if no foodData provided
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.public, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Cultural Insights for ${widget.dishName}',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text('Cultural information will be displayed here.'),
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
