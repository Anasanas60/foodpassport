import 'package:flutter/material.dart';

class CulturalInsightsScreen extends StatefulWidget {
  final String dishName;
  final Map<String, dynamic>? foodData;

  const CulturalInsightsScreen({
    super.key,
    required this.dishName,
    this.foodData,
  });

  @override
  State<CulturalInsightsScreen> createState() => _CulturalInsightsScreenState();
}

class _CulturalInsightsScreenState extends State<CulturalInsightsScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Culture: ${widget.dishName}'),
        backgroundColor: theme.colorScheme.secondary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: widget.foodData != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Origin: ${widget.foodData!['origin'] ?? 'Unknown'}',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Cultural Information:',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.foodData!['culturalInfo'] ?? 'Cultural insights will be displayed here based on the dish origin.',
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.public, size: 64, color: theme.colorScheme.onSurface.withAlpha((0.1 * 255).round())),
                    const SizedBox(height: 16),
                    Text(
                      'Cultural Insights for ${widget.dishName}',
                      style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cultural information will be displayed here.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
