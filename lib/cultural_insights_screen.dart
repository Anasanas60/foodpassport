import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config/api_config.dart';

class CulturalInsightsScreen extends StatefulWidget {
  final String dishName;
  const CulturalInsightsScreen({super.key, required this.dishName});

  @override
  State<CulturalInsightsScreen> createState() => _CulturalInsightsScreenState();
}

class _CulturalInsightsScreenState extends State<CulturalInsightsScreen> {
  Map<String, dynamic>? _culturalData;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadCulturalData();
  }

  Future<void> _loadCulturalData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final data = await _fetchCulturalInfo(widget.dishName); 

      setState(() {
        _culturalData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load cultural data. Using generated insights.';
        _culturalData = _generateFallbackCulturalData(widget.dishName);
        _isLoading = false;
      });
    }
  }

  // Simulate fetching cultural info, replace with your actual API calls
  Future<Map<String, dynamic>> _fetchCulturalInfo(String dishName) async {
    // Example: try to get country info using your API or logic
    // For now, fallback to generated data
    return _generateFallbackCulturalData(dishName);
  }

  Map<String, dynamic> _generateFallbackCulturalData(String dishName) {
    return {
      'origin': 'Various Global Influences',
      'culturalInfo': '$dishName is enjoyed worldwide with rich diversity.',
      'history': 'This dish has traveled and adapted across cultures.',
      'etiquette': 'Enjoy this dish respectfully and with appreciation.',
      'funFact': 'Many popular dishes have surprising histories!',
      'hasRealData': false,
      'countryInfo': {},
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Cultural Insights: ${widget.dishName}'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCulturalData,
            tooltip: 'Reload Cultural Data',
          ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState(theme)
          : _culturalData != null
              ? _buildContent(theme)
              : _buildErrorState(theme),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading cultural insights...',
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'Discovering the story behind ${widget.dishName}',
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text('Unable to load cultural data', style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.error)),
          const SizedBox(height: 8),
          Text(_errorMessage, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant), textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadCulturalData,
            child: const Text('Try Again'),
            style: ElevatedButton.styleFrom(backgroundColor: theme.colorScheme.primary, foregroundColor: theme.colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    final data = _culturalData!;
    final hasRealData = data['hasRealData'] ?? false;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.public, size: 32, color: hasRealData ? theme.colorScheme.secondary : theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['origin'], style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('Culinary Origin', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                      if (hasRealData)
                        Chip(
                          label: const Text('Verified Data'),
                          backgroundColor: theme.colorScheme.secondaryContainer,
                          labelStyle: TextStyle(color: theme.colorScheme.secondary),
                        )
                      else
                        Chip(
                          label: const Text('AI Generated'),
                          backgroundColor: theme.colorScheme.primaryContainer,
                          labelStyle: TextStyle(color: theme.colorScheme.primary),
                        ),
                    ],
                  ),
                  if (data['countryInfo'] != null && data['countryInfo'].isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildCountryInfo(theme, data['countryInfo']),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildInfoCard(theme, 'Cultural Significance', Icons.history, data['culturalInfo'], theme.colorScheme.primary),
          const SizedBox(height: 16),
          _buildInfoCard(theme, 'Historical Background', Icons.book, data['history'], theme.colorScheme.secondary),
          const SizedBox(height: 16),
          _buildInfoCard(theme, 'Dining Etiquette', Icons.emoji_people, data['etiquette'], theme.colorScheme.tertiary),
          const SizedBox(height: 16),
          _buildInfoCard(theme, 'Fun Fact', Icons.emoji_events, data['funFact'], theme.colorScheme.primary),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest ?? theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info, size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasRealData
                        ? 'Cultural data sourced from RestCountries API and culinary research'
                        : 'AI-generated insights based on dish analysis',
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryInfo(ThemeData theme, Map<String, dynamic> countryInfo) {
    return Column(
      children: [
        if (countryInfo['flag'] != null) ...[
          Image.network(
            countryInfo['flag'],
            height: 40,
            errorBuilder: (context, error, stackTrace) => Container(),
          ),
          const SizedBox(height: 8),
        ],
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            if (countryInfo['capital'] != null) _buildCountryDetail(theme, 'Capital', countryInfo['capital']),
            if (countryInfo['region'] != null) _buildCountryDetail(theme, 'Region', countryInfo['region']),
            if (countryInfo['population'] != null) _buildCountryDetail(theme, 'Population', _formatPopulation(countryInfo['population'])),
          ],
        ),
      ],
    );
  }

  Widget _buildCountryDetail(ThemeData theme, String label, String value) {
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleMedium),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }

  String _formatPopulation(int population) {
    if (population >= 1000000) {
      return '${(population / 1000000).toStringAsFixed(1)}M';
    }
    if (population >= 1000) {
      return '${(population / 1000).toStringAsFixed(1)}K';
    }
    return population.toString();
  }

  Widget _buildInfoCard(ThemeData theme, String title, IconData icon, String content, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(title, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text(content, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
