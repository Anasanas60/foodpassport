import 'package:flutter/material.dart';


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

  Future<Map<String, dynamic>> _fetchCulturalInfo(String dishName) async {
    return _generateFallbackCulturalData(dishName);
  }

  Map<String, dynamic> _generateFallbackCulturalData(String dishName) {
    final dishInsights = _getDishSpecificInsights(dishName);
    
    return {
      'origin': dishInsights['origin'],
      'culturalInfo': dishInsights['culturalInfo'],
      'history': dishInsights['history'],
      'etiquette': dishInsights['etiquette'],
      'funFact': dishInsights['funFact'],
      'hasRealData': false,
      'countryInfo': dishInsights['countryInfo'],
      'difficulty': dishInsights['difficulty'],
      'popularity': dishInsights['popularity'],
      'ingredients': dishInsights['ingredients'],
    };
  }

  Map<String, dynamic> _getDishSpecificInsights(String dishName) {
    final lowerDishName = dishName.toLowerCase();
    
    if (lowerDishName.contains('pizza') || lowerDishName.contains('pasta')) {
      return {
        'origin': 'Italy 🇮🇹',
        'culturalInfo': 'A cornerstone of Italian cuisine, representing family gatherings and celebration.',
        'history': 'Originated in Naples in the 18th century as a working-class food, now enjoyed worldwide.',
        'etiquette': 'Eat with hands in casual settings, use fork and knife in formal restaurants.',
        'funFact': 'The first pizza delivery was in 1889 for Queen Margherita of Savoy!',
        'countryInfo': {
          'capital': 'Rome',
          'region': 'Southern Europe',
          'population': 59554023,
          'flag': '🇮🇹'
        },
        'difficulty': 'Medium',
        'popularity': 'Global',
        'ingredients': ['Flour', 'Tomatoes', 'Cheese', 'Olive Oil'],
      };
    } else if (lowerDishName.contains('sushi') || lowerDishName.contains('ramen')) {
      return {
        'origin': 'Japan 🇯🇵',
        'culturalInfo': 'Represents precision, seasonality, and artistic presentation in Japanese culture.',
        'history': 'Evolved from street food to high art over centuries of culinary refinement.',
        'etiquette': 'Use chopsticks properly, say "itadakimasu" before eating.',
        'funFact': 'The first sushi was fermented fish preserved in rice!',
        'countryInfo': {
          'capital': 'Tokyo',
          'region': 'East Asia',
          'population': 125584838,
          'flag': '🇯🇵'
        },
        'difficulty': 'Hard',
        'popularity': 'Global',
        'ingredients': ['Rice', 'Fish', 'Seaweed', 'Soy Sauce'],
      };
    } else if (lowerDishName.contains('taco') || lowerDishName.contains('burrito')) {
      return {
        'origin': 'Mexico 🇲🇽',
        'culturalInfo': 'Street food culture meets ancient culinary traditions.',
        'history': 'Dates back to indigenous civilizations using corn as a staple.',
        'etiquette': 'Eat with hands, add salsa to taste, enjoy with fresh lime.',
        'funFact': 'Tacos were originally miners\' food in silver mines!',
        'countryInfo': {
          'capital': 'Mexico City',
          'region': 'North America',
          'population': 128932753,
          'flag': '🇲🇽'
        },
        'difficulty': 'Easy',
        'popularity': 'Global',
        'ingredients': ['Corn', 'Beans', 'Avocado', 'Chili'],
      };
    } else {
      return {
        'origin': 'Various Global Influences',
        'culturalInfo': '$dishName is enjoyed worldwide with rich diversity and cultural significance.',
        'history': 'This dish has traveled across cultures, adapting to local ingredients and traditions.',
        'etiquette': 'Enjoy this dish respectfully, appreciating its cultural heritage.',
        'funFact': 'Many popular dishes have surprising origins and cultural journeys!',
        'countryInfo': {
          'capital': 'Various',
          'region': 'Global',
          'population': 0,
          'flag': '🌍'
        },
        'difficulty': 'Medium',
        'popularity': 'Regional',
        'ingredients': ['Local Ingredients', 'Traditional Spices'],
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        title: Text(
          'Cultural Insights',
          style: TextStyle(
            color: const Color(0xFF333333),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: const Color(0xFF333333)),
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
            valueColor: AlwaysStoppedAnimation(const Color(0xFFFF6F61)),
          ),
          const SizedBox(height: 20),
          Text(
            'Discovering Cultural Story',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Uncovering the heritage behind ${widget.dishName}',
            style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF666666)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.travel_explore, size: 80, color: const Color(0xFF8BC34A)),
            const SizedBox(height: 20),
            Text(
              'Cultural Journey Unavailable',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(color: const Color(0xFF666666)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCulturalData,
              icon: const Icon(Icons.explore, color: Colors.white),
              label: const Text('Explore Again', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8BC34A),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
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
          // Cultural Hero Card
          _buildCulturalHeroCard(data, hasRealData),
          
          const SizedBox(height: 20),
          
          // Quick Facts Grid
          _buildQuickFactsGrid(data),
          
          const SizedBox(height: 20),
          
          // Cultural Sections
          _buildCulturalSections(data),
          
          const SizedBox(height: 20),
          
          // Ingredients & Characteristics
          _buildIngredientsSection(data),
          
          const SizedBox(height: 20),
          
          // Data Source Footer
          _buildDataSourceFooter(hasRealData),
        ],
      ),
    );
  }

  Widget _buildCulturalHeroCard(Map<String, dynamic> data, bool hasRealData) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6F61), Color(0xFFFF8A80)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6F61).withAlpha(80),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      data['countryInfo']['flag'] ?? '🌍',
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['origin'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Culinary Origin',
                        style: TextStyle(
                          color: Colors.white.withAlpha(204),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    hasRealData ? 'Verified' : 'AI Insight',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (data['countryInfo'] != null && data['countryInfo'].isNotEmpty)
              _buildCountryHighlights(data['countryInfo']),
          ],
        ),
      ),
    );
  }

  Widget _buildCountryHighlights(Map<String, dynamic> countryInfo) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          if (countryInfo['capital'] != null && countryInfo['capital'] != 'Various')
            _buildCountryStat('Capital', countryInfo['capital']),
          if (countryInfo['region'] != null && countryInfo['region'] != 'Global')
            _buildCountryStat('Region', countryInfo['region']),
          if (countryInfo['population'] != null && countryInfo['population'] > 0)
            _buildCountryStat('Population', _formatPopulation(countryInfo['population'])),
        ],
      ),
    );
  }

  Widget _buildCountryStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withAlpha(178),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickFactsGrid(Map<String, dynamic> data) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.4,
      ),
      children: [
        _buildQuickFactCard(
          'Difficulty',
          data['difficulty'],
          Icons.auto_awesome,
          const Color(0xFFFF6F61),
        ),
        _buildQuickFactCard(
          'Popularity',
          data['popularity'],
          Icons.trending_up,
          const Color(0xFF8BC34A),
        ),
        _buildQuickFactCard(
          'Cultural Impact',
          'Significant',
          Icons.public,
          const Color(0xFFFF6F61),
        ),
        _buildQuickFactCard(
          'Heritage',
          'Traditional',
          Icons.history_edu,
          const Color(0xFF8BC34A),
        ),
      ],
    );
  }

  Widget _buildQuickFactCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCulturalSections(Map<String, dynamic> data) {
    return Column(
      children: [
        _buildCulturalSection(
          'Cultural Significance',
          Icons.celebration,
          data['culturalInfo'],
          const Color(0xFFFF6F61),
        ),
        const SizedBox(height: 16),
        _buildCulturalSection(
          'Historical Journey',
          Icons.history,
          data['history'],
          const Color(0xFF8BC34A),
        ),
        const SizedBox(height: 16),
        _buildCulturalSection(
          'Dining Traditions',
          Icons.emoji_people,
          data['etiquette'],
          const Color(0xFFFF6F61),
        ),
        const SizedBox(height: 16),
        _buildCulturalSection(
          'Cultural Gem',
          Icons.emoji_events,
          data['funFact'],
          const Color(0xFF8BC34A),
        ),
      ],
    );
  }

  Widget _buildCulturalSection(String title, IconData icon, String content, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsSection(Map<String, dynamic> data) {
    final ingredients = data['ingredients'] as List<String>? ?? [];
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: const Color(0xFFFF6F61)),
                const SizedBox(width: 8),
                const Text(
                  'Key Ingredients & Characteristics',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (ingredients.isNotEmpty) ...[
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ingredients.map((ingredient) => Chip(
                  label: Text(ingredient),
                  backgroundColor: const Color(0xFFFF6F61).withAlpha(25),
                  labelStyle: const TextStyle(color: Color(0xFFFF6F61)),
                )).toList(),
              ),
              const SizedBox(height: 12),
            ],
            const Text(
              'This dish represents the unique flavors and cooking techniques of its cultural origin.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF666666),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSourceFooter(bool hasRealData) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info, size: 16, color: const Color(0xFF666666)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hasRealData
                  ? 'Cultural insights sourced from global culinary databases and cultural research'
                  : 'AI-powered cultural analysis based on dish characteristics and regional cuisine patterns',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
              ),
            ),
          ),
        ],
      ),
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
}