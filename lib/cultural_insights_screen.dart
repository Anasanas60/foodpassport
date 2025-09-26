import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/food_state_service.dart';
import 'services/food_recognition_service.dart';
import 'models/food_item.dart';

class CulturalInsightsScreen extends StatefulWidget {
  final String dishName;

  const CulturalInsightsScreen({
    super.key,
    required this.dishName,
  });

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

      // Try to get cultural data from the API
      final culturalData = await FoodRecognitionService.getCulturalDetails(widget.dishName);
      
      if (culturalData != null) {
        setState(() {
          _culturalData = culturalData;
          _isLoading = false;
        });
      } else {
        // Fallback to generated cultural insights based on cuisine type
        setState(() {
          _culturalData = _generateCulturalInsights(widget.dishName);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load cultural data: $e';
        _isLoading = false;
        _culturalData = _generateCulturalInsights(widget.dishName);
      });
    }
  }

  Map<String, dynamic> _generateCulturalInsights(String dishName) {
    // Simple cultural insights based on common cuisine patterns
    final lowerDish = dishName.toLowerCase();
    
    Map<String, dynamic> insights = {
      'origin': 'Various Regions',
      'culturalInfo': 'This dish has variations across different cultures.',
      'history': 'A popular dish with rich culinary heritage.',
      'etiquette': 'Typically enjoyed as a main course.',
      'funFact': 'Loved by food enthusiasts worldwide!',
    };

    // Thai cuisine insights
    if (lowerDish.contains('thai') || lowerDish.contains('pad') || 
        lowerDish.contains('curry') && !lowerDish.contains('indian')) {
      insights = {
        'origin': 'Thailand',
        'culturalInfo': 'Thai cuisine emphasizes balanced flavors: sweet, sour, salty, bitter, and spicy.',
        'history': 'Influenced by neighboring countries and royal palace cuisine.',
        'etiquette': 'Eaten with fork and spoon; fork pushes food onto spoon.',
        'funFact': 'Thai food is known for its vibrant colors and aromatic herbs.',
      };
    }
    // Italian cuisine insights
    else if (lowerDish.contains('pizza') || lowerDish.contains('pasta') || 
             lowerDish.contains('risotto') || lowerDish.contains('italian')) {
      insights = {
        'origin': 'Italy',
        'culturalInfo': 'Italian cuisine is regional with emphasis on fresh, quality ingredients.',
        'history': 'Dating back to 4th century BC with Etruscan and Greek influences.',
        'etiquette': 'Pasta is twirled with fork, pizza eaten with hands.',
        'funFact': 'There are over 600 pasta shapes in Italian cuisine!',
      };
    }
    // Japanese cuisine insights
    else if (lowerDish.contains('sushi') || lowerDish.contains('ramen') || 
             lowerDish.contains('tempura') || lowerDish.contains('japanese')) {
      insights = {
        'origin': 'Japan',
        'culturalInfo': 'Emphasis on seasonality, presentation, and umami flavors.',
        'history': 'Influenced by Chinese cuisine and developed during Edo period.',
        'etiquette': 'Chopsticks used; say "itadakimasu" before eating.',
        'funFact': 'Sushi was originally a way to preserve fish in fermented rice.',
      };
    }
    // Mexican cuisine insights
    else if (lowerDish.contains('taco') || lowerDish.contains('burrito') || 
             lowerDish.contains('mexican') || lowerDish.contains('salsa')) {
      insights = {
        'origin': 'Mexico',
        'culturalInfo': 'UNESCO Intangible Cultural Heritage with complex flavors.',
        'history': 'Ancient Mesoamerican roots with Spanish influences.',
        'etiquette': 'Often eaten with hands; tortillas used as utensils.',
        'funFact': 'Chocolate was first consumed as a beverage in ancient Mexico.',
      };
    }
    // Indian cuisine insights
    else if (lowerDish.contains('curry') && lowerDish.contains('indian') || 
             lowerDish.contains('tikka') || lowerDish.contains('masala')) {
      insights = {
        'origin': 'India',
        'culturalInfo': 'Diverse regional cuisines with complex spice blends.',
        'history': '5000-year history influenced by various invasions and trade.',
        'etiquette': 'Often eaten with right hand; bread used to scoop food.',
        'funFact': 'India produces about 70% of the world\'s spices.',
      };
    }

    return insights;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foodState = Provider.of<FoodStateService>(context);
    final FoodItem? currentFood = foodState.currentFoodItem;

    return Scaffold(
      appBar: AppBar(
        title: Text('Culture: ${currentFood?.name ?? widget.dishName}'),
        backgroundColor: const Color(0xFF8B4513), // Brown color for cultural theme
        foregroundColor: Colors.white,
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
          : _errorMessage.isNotEmpty 
              ? _buildErrorState(theme)
              : _buildCulturalContent(theme, currentFood),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
          ),
          const SizedBox(height: 20),
          Text(
            'Discovering Cultural Insights...',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'Learning about ${widget.dishName}',
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
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
          Icon(
            Icons.public_off,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'Cultural Insights Unavailable',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadCulturalData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B4513),
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildCulturalContent(ThemeData theme, FoodItem? currentFood) {
    final insights = _culturalData!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cultural Header Card
          _buildCulturalHeader(theme, insights, currentFood),
          
          const SizedBox(height: 20),
          
          // Cultural Information Sections
          _buildInfoSection(
            theme,
            'Cultural Significance',
            Icons.architecture,
            insights['culturalInfo'] ?? 'Cultural information not available.',
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoSection(
            theme,
            'Historical Background',
            Icons.history,
            insights['history'] ?? 'Historical information not available.',
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoSection(
            theme,
            'Dining Etiquette',
            Icons.emoji_food_beverage,
            insights['etiquette'] ?? 'Etiquette information not available.',
          ),
          
          const SizedBox(height: 16),
          
          _buildInfoSection(
            theme,
            'Fun Fact',
            Icons.celebration,
            insights['funFact'] ?? 'Interesting facts about this dish.',
            isFunFact: true,
          ),
          
          const SizedBox(height: 16),
          
          // Ingredients Section (if available from API)
          if (_culturalData?['ingredients'] != null)
            _buildIngredientsSection(theme),
          
          const SizedBox(height: 30),
          
          // Cultural Tips
          _buildCulturalTips(theme, insights['origin']),
        ],
      ),
    );
  }

  Widget _buildCulturalHeader(ThemeData theme, Map<String, dynamic> insights, FoodItem? currentFood) {
    return Card(
      elevation: 4,
      color: const Color(0xFFF5F5DC), // Beige background
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Icon(
              Icons.public,
              size: 48,
              color: const Color(0xFF8B4513),
            ),
            const SizedBox(height: 16),
            Text(
              currentFood?.name ?? widget.dishName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B4513),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Culinary Heritage of ${insights['origin']}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFFA0522D),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            if (currentFood?.area != null) ...[
              const SizedBox(height: 8),
              Chip(
                backgroundColor: const Color(0xFF8B4513),
                label: Text(
                  currentFood!.area!,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(ThemeData theme, String title, IconData icon, String content, {bool isFunFact = false}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: isFunFact ? const Color(0xFFD2691E) : const Color(0xFF8B4513),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8B4513),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.justify,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIngredientsSection(ThemeData theme) {
    final ingredients = _culturalData!['ingredients'] as List<String>;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shopping_basket,
                  color: const Color(0xFF8B4513),
                ),
                const SizedBox(width: 8),
                Text(
                  'Key Ingredients',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8B4513),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ingredients.map((ingredient) => Chip(
                backgroundColor: const Color(0xFFF5F5DC),
                label: Text(ingredient),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCulturalTips(ThemeData theme, String origin) {
    return Card(
      color: const Color(0xFFFFF8DC),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cultural Tips for ${origin} Cuisine',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF8B4513),
              ),
            ),
            const SizedBox(height: 12),
            _buildTipItem('Respect local dining customs and traditions'),
            _buildTipItem('Try to learn a few phrases in the local language'),
            _buildTipItem('Be open to new flavors and cooking techniques'),
            _buildTipItem('Ask about the story behind traditional dishes'),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.emoji_objects, size: 16, color: const Color(0xFFD2691E)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}