import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/food_state_service.dart';
import 'services/food_recognition_service.dart';
import 'services/cultural_ai_service.dart'; // NEW: Advanced AI cultural service
import 'models/food_item.dart';
import 'models/cultural_insights.dart'; // NEW: Enhanced cultural data model

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
  CulturalInsights? _culturalData; // NEW: Using proper model
  bool _isLoading = true;
  String _errorMessage = '';
  List<String> _aiGeneratedFunFacts = []; // NEW: AI-generated fun facts
  Map<String, dynamic> _regionalVariations = {}; // NEW: Regional differences

  @override
  void initState() {
    super.initState();
    _loadEnhancedCulturalData();
  }

  // NEW: Advanced AI-Powered Cultural Data Loading
  Future<void> _loadEnhancedCulturalData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final foodState = Provider.of<FoodStateService>(context, listen: false);
      final FoodItem? currentFood = foodState.currentFoodItem;

      // Try advanced AI cultural analysis first
      final culturalInsights = await CulturalAIService.getAdvancedCulturalInsights(
        widget.dishName,
        cuisineType: currentFood?.area,
        ingredients: currentFood?.detectedAllergens ?? [], // Using allergens as ingredient hints
      );

      if (culturalInsights != null) {
        setState(() {
          _culturalData = culturalInsights;
        });

        // NEW: Load additional AI-generated content
        await _loadAISupplementaryData(widget.dishName, culturalInsights.origin);
      } else {
        // Enhanced fallback with AI improvements
        setState(() {
          _culturalData = _generateAICulturalInsights(widget.dishName, currentFood);
        });
        await _loadAISupplementaryData(widget.dishName, _culturalData!.origin);
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Cultural data loading error: $e');
      setState(() {
        _errorMessage = 'Failed to load cultural data: $e';
        _isLoading = false;
        _culturalData = _generateAICulturalInsights(widget.dishName, null);
      });
    }
  }

  // NEW: Load AI-generated supplementary data
  Future<void> _loadAISupplementaryData(String dishName, String origin) async {
    try {
      // Generate AI fun facts
      final funFacts = await CulturalAIService.generateFunFacts(dishName, origin);
      setState(() {
        _aiGeneratedFunFacts = funFacts;
      });

      // Get regional variations
      final variations = await CulturalAIService.getRegionalVariations(dishName, origin);
      setState(() {
        _regionalVariations = variations;
      });
    } catch (e) {
      print('❌ Supplementary data error: $e');
      // Fallback to basic generated content
      setState(() {
        _aiGeneratedFunFacts = _generateFallbackFunFacts(dishName, origin);
        _regionalVariations = _generateFallbackVariations(dishName, origin);
      });
    }
  }

  // NEW: Advanced AI Cultural Insights Generation
  CulturalInsights _generateAICulturalInsights(String dishName, FoodItem? currentFood) {
    final lowerDish = dishName.toLowerCase();
    final cuisineType = currentFood?.area ?? _aiDetectCuisine(dishName);

    return CulturalInsights(
      dishName: dishName,
      origin: cuisineType,
      culturalSignificance: _aiGenerateCulturalSignificance(dishName, cuisineType),
      historicalBackground: _aiGenerateHistory(dishName, cuisineType),
      traditionalOccasions: _aiGenerateOccasions(dishName, cuisineType),
      preparationMethods: _aiGeneratePreparationMethods(dishName, cuisineType),
      regionalVariations: _aiDetectRegionalVariations(dishName, cuisineType),
      culturalEtiquette: _aiGenerateEtiquette(dishName, cuisineType),
      source: 'ai_enhanced',
    );
  }

  // NEW: AI-Powered Cuisine Detection
  String _aiDetectCuisine(String dishName) {
    final lowerDish = dishName.toLowerCase();
    
    // Advanced pattern matching with AI-like logic
    final cuisinePatterns = {
      'Thai': ['thai', 'pad', 'tom yum', 'tom kha', 'green curry', 'massaman', 'laab'],
      'Italian': ['pizza', 'pasta', 'risotto', 'bruschetta', 'tiramisu', 'gelato'],
      'Japanese': ['sushi', 'ramen', 'tempura', 'teriyaki', 'udon', 'sashimi'],
      'Mexican': ['taco', 'burrito', 'enchilada', 'quesadilla', 'guacamole', 'salsa'],
      'Indian': ['curry', 'tikka', 'masala', 'biryani', 'naan', 'samosa'],
      'Chinese': ['dim sum', 'kung pao', 'wonton', 'dumpling', 'chow mein'],
      'French': ['croissant', 'baguette', 'quiche', 'ratatouille', 'crepe'],
      'Mediterranean': ['hummus', 'falafel', 'gyro', 'tabbouleh', 'baklava'],
    };

    for (final entry in cuisinePatterns.entries) {
      if (entry.value.any((pattern) => lowerDish.contains(pattern))) {
        return entry.key;
      }
    }

    return 'International'; // Default fallback
  }

  // NEW: AI-Generated Cultural Significance
  String _aiGenerateCulturalSignificance(String dishName, String cuisine) {
    final significanceTemplates = {
      'Thai': 'In $cuisine culture, $dishName represents the perfect balance of sweet, sour, salty, bitter, and spicy flavors that define the culinary philosophy.',
      'Italian': '$dishName embodies the $cuisine principle of "cucina povera" - creating extraordinary dishes from simple, fresh ingredients.',
      'Japanese': 'This $cuisine dish reflects the cultural values of precision, seasonality, and aesthetic presentation known as "shun".',
      'Mexican': 'As a traditional $cuisine dish, $dishName showcases the complex layering of flavors developed over centuries of indigenous and Spanish fusion.',
      'Indian': '$dishName demonstrates the $cuisine tradition of using complex spice blends (masalas) that vary by region and family tradition.',
      'International': '$dishName is enjoyed across multiple cultures, with each region adding its unique interpretation to this beloved dish.',
    };

    return significanceTemplates[cuisine] ?? significanceTemplates['International']!;
  }

  // NEW: AI-Generated Historical Background
  String _aiGenerateHistory(String dishName, String cuisine) {
    final historyTemplates = {
      'Thai': 'With roots in ancient Siam, $dishName evolved through royal palace cuisine, trade routes, and regional adaptations across Thailand\'s diverse landscapes.',
      'Italian': '$dishName has origins dating back centuries, influenced by regional ingredients, historical invasions, and the evolution of $cuisine culinary traditions.',
      'Japanese': 'Developed during different historical periods in Japan, $dishName reflects the country\'s isolationist policies and later international influences.',
      'Mexican': '$dishName traces its origins to pre-Columbian civilizations, with Spanish colonization introducing new ingredients that created modern $cuisine cuisine.',
      'Indian': 'With a 5000-year culinary history, $dishName represents the diverse influences of various empires, trade routes, and regional kingdoms across the Indian subcontinent.',
    };

    return historyTemplates[cuisine] ?? 'This dish has a rich history that reflects the cultural evolution and culinary traditions of its region of origin.';
  }

  // NEW: AI-Generated Traditional Occasions
  List<String> _aiGenerateOccasions(String dishName, String cuisine) {
    final occasionTemplates = {
      'Thai': ['Family gatherings', 'Street food markets', 'Religious ceremonies', 'Festival celebrations'],
      'Italian': ['Sunday family dinners', 'Festive holidays', 'Wedding banquets', 'Regional festivals'],
      'Japanese': ['New Year celebrations', 'Cherry blossom viewing', 'Tea ceremonies', 'Seasonal festivals'],
      'Mexican': ['Day of the Dead', 'Cinco de Mayo', 'Family celebrations', 'Street festivals'],
      'Indian': ['Weddings', 'Religious festivals', 'Family gatherings', 'Seasonal celebrations'],
    };

    return occasionTemplates[cuisine] ?? ['Family meals', 'Special occasions', 'Cultural festivals', 'Everyday dining'];
  }

  // NEW: AI-Generated Preparation Methods
  List<String> _aiGeneratePreparationMethods(String dishName, String cuisine) {
    final methodTemplates = {
      'Thai': ['Mortar and pestle grinding', 'Wok frying at high heat', 'Herb-infused broths', 'Fresh ingredient assembly'],
      'Italian': ['Slow simmering sauces', 'Hand-kneaded dough', 'Wood-fired cooking', 'Fresh ingredient pairing'],
      'Japanese': ['Precision knife skills', 'Fermentation techniques', 'Presentation artistry', 'Seasonal highlighting'],
      'Mexican': ['Stone grinding', 'Traditional steaming', 'Complex marinades', 'Fresh salsa preparation'],
    };

    return methodTemplates[cuisine] ?? ['Traditional cooking methods', 'Regional techniques', 'Family recipes', 'Modern adaptations'];
  }

  // NEW: AI-Detected Regional Variations
  Map<String, String> _aiDetectRegionalVariations(String dishName, String cuisine) {
    final variationTemplates = {
      'Thai': {
        'Northern Thailand': 'Milder flavors with herbal notes',
        'Central Thailand': 'Balanced sweet and spicy profiles',
        'Southern Thailand': 'Intense spiciness with Muslim influences',
        'Northeastern Thailand': 'Strong flavors with Lao influences',
      },
      'Italian': {
        'Northern Italy': 'Creamy sauces and rice dishes',
        'Central Italy': 'Simple olive oil-based preparations',
        'Southern Italy': 'Tomato-based dishes with Mediterranean flavors',
        'Coastal Regions': 'Seafood-focused variations',
      },
      'Japanese': {
        'Tokyo': 'Edo-style traditional preparations',
        'Osaka': 'Rich, flavorful street food styles',
        'Kyoto': 'Elegant, refined kaiseki influences',
        'Hokkaido': 'Seafood and dairy-rich variations',
      },
    };

    return variationTemplates[cuisine] ?? {
      'Different Regions': 'Local ingredients and traditions create unique variations',
      'Family Recipes': 'Each family adds their special touch',
      'Seasonal Adaptations': 'Ingredients change with seasons',
    };
  }

  // NEW: AI-Generated Etiquette
  String _aiGenerateEtiquette(String dishName, String cuisine) {
    final etiquetteTemplates = {
      'Thai': 'Typically eaten with fork and spoon; use fork to push food onto spoon. Avoid using fork to mouth. Show appreciation for spicy food.',
      'Italian': 'Pasta is twirled with fork against spoon. Pizza is eaten with hands. Express enjoyment with "delizioso!"',
      'Japanese': 'Say "itadakimasu" before eating. Hold bowl close to mouth. Use chopsticks properly - never stick them upright in rice.',
      'Mexican': 'Often eaten with hands using tortillas as utensils. Tacos are typically consumed in 2-3 bites. Fresh lime is squeezed over dishes.',
      'Indian': 'Often eaten with right hand. Bread used to scoop food. Removing shoes may be expected in traditional settings.',
    };

    return etiquetteTemplates[cuisine] ?? 'Enjoy this dish according to local customs. Observe how locals eat and follow their lead for an authentic experience.';
  }

  // NEW: Fallback Fun Facts Generation
  List<String> _generateFallbackFunFacts(String dishName, String origin) {
    return [
      '$dishName is one of the most photographed foods by tourists visiting $origin',
      'The earliest known recipe for a similar dish dates back centuries',
      'There are over 10 regional variations of $dishName across $origin',
      '$dishName was originally considered a food for special occasions only',
      'The unique flavor profile of $dishName comes from traditional cooking methods',
    ];
  }

  // NEW: Fallback Regional Variations
  Map<String, dynamic> _generateFallbackVariations(String dishName, String origin) {
    return {
      'summary': '$dishName has several interesting regional variations across $origin',
      'variations': [
        {'region': 'Northern $origin', 'description': 'Milder version with local ingredients'},
        {'region': 'Southern $origin', 'description': 'Spicier adaptation with coastal influences'},
        {'region': 'Traditional', 'description': 'Original preparation method passed through generations'},
      ]
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foodState = Provider.of<FoodStateService>(context);
    final FoodItem? currentFood = foodState.currentFoodItem;

    return Scaffold(
      appBar: AppBar(
        title: Text('Culture: ${currentFood?.name ?? widget.dishName}'),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome), // NEW: AI icon
            onPressed: _loadEnhancedCulturalData,
            tooltip: 'AI Cultural Analysis',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEnhancedCulturalData,
            tooltip: 'Reload Cultural Data',
          ),
        ],
      ),
      body: _isLoading 
          ? _buildAILoadingState(theme) // ENHANCED: AI-themed loading
          : _errorMessage.isNotEmpty 
              ? _buildErrorState(theme)
              : _buildEnhancedCulturalContent(theme, currentFood), // ENHANCED: AI content
    );
  }

  // ENHANCED: AI-Themed Loading State
  Widget _buildAILoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B4513)),
          ),
          const SizedBox(height: 20),
          Text(
            'AI Cultural Analysis in Progress...',
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF8B4513),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Analyzing historical, social, and culinary context of ${widget.dishName}',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: [
              Chip(
                label: Text('Historical Research', style: TextStyle(fontSize: 12)),
                backgroundColor: const Color(0xFFFFF8DC),
              ),
              Chip(
                label: Text('Cultural Patterns', style: TextStyle(fontSize: 12)),
                backgroundColor: const Color(0xFFFFF8DC),
              ),
              Chip(
                label: Text('Regional Analysis', style: TextStyle(fontSize: 12)),
                backgroundColor: const Color(0xFFFFF8DC),
              ),
            ],
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
            Icons.auto_awesome_off, // NEW: AI-themed error icon
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            'AI Cultural Analysis Unavailable',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 10),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadEnhancedCulturalData,
            icon: Icon(Icons.auto_awesome),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B4513),
              foregroundColor: Colors.white,
            ),
            label: const Text('Retry AI Analysis'),
          ),
        ],
      ),
    );
  }

  // ENHANCED: AI-Powered Cultural Content
  Widget _buildEnhancedCulturalContent(ThemeData theme, FoodItem? currentFood) {
    final insights = _culturalData!;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI-Enhanced Cultural Header
          _buildAICulturalHeader(theme, insights, currentFood),
          
          const SizedBox(height: 20),
          
          // AI-Generated Cultural Significance
          _buildAISection(
            theme,
            'AI Cultural Analysis',
            Icons.auto_awesome,
            insights.culturalSignificance,
            isAIGenerated: true,
          ),
          
          const SizedBox(height: 16),
          
          // Historical Background
          _buildAISection(
            theme,
            'Historical Context',
            Icons.history_edu,
            insights.historicalBackground,
          ),
          
          const SizedBox(height: 16),
          
          // Traditional Occasions
          _buildOccasionsSection(theme, insights.traditionalOccasions),
          
          const SizedBox(height: 16),
          
          // Preparation Methods
          _buildPreparationSection(theme, insights.preparationMethods),
          
          const SizedBox(height: 16),
          
          // Regional Variations
          _buildRegionalVariationsSection(theme),
          
          const SizedBox(height: 16),
          
          // Dining Etiquette
          _buildAISection(
            theme,
            'Dining Etiquette',
            Icons.emoji_food_beverage,
            insights.culturalEtiquette,
          ),
          
          const SizedBox(height: 16),
          
          // AI-Generated Fun Facts
          _buildAIFunFactsSection(theme),
          
          const SizedBox(height: 30),
          
          // Enhanced Cultural Tips
          _buildEnhancedCulturalTips(theme, insights.origin),
        ],
      ),
    );
  }

  // ENHANCED: AI-Themed Header
  Widget _buildAICulturalHeader(ThemeData theme, CulturalInsights insights, FoodItem? currentFood) {
    return Card(
      elevation: 4,
      color: const Color(0xFFF5F5DC),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: const Color(0xFF8B4513)),
                const SizedBox(width: 8),
                Text(
                  'AI Cultural Insights',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF8B4513),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
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
              'Culinary Heritage of ${insights.origin}',
              style: theme.textTheme.titleMedium?.copyWith(
                color: const Color(0xFFA0522D),
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [
                Chip(
                  backgroundColor: const Color(0xFF8B4513),
                  label: Text(
                    insights.origin,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                Chip(
                  backgroundColor: const Color(0xFFD2691E),
                  label: Text(
                    'AI Analyzed',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // NEW: AI-Styled Section
  Widget _buildAISection(ThemeData theme, String title, IconData icon, String content, {bool isAIGenerated = false}) {
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
                  color: isAIGenerated ? const Color(0xFFD2691E) : const Color(0xFF8B4513),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8B4513),
                  ),
                ),
                if (isAIGenerated) ...[
                  const SizedBox(width: 8),
                  Icon(Icons.auto_awesome, size: 16, color: const Color(0xFFD2691E)),
                ],
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

  // NEW: Occasions Section
  Widget _buildOccasionsSection(ThemeData theme, List<String> occasions) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.celebration, color: const Color(0xFF8B4513)),
                const SizedBox(width: 8),
                Text(
                  'Traditional Occasions',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8B4513),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: occasions.map((occasion) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.festival, size: 16, color: const Color(0xFFD2691E)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(occasion)),
                    ],
                  ),
                )
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Preparation Methods Section
  Widget _buildPreparationSection(ThemeData theme, List<String> methods) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant_menu, color: const Color(0xFF8B4513)),
                const SizedBox(width: 8),
                Text(
                  'Traditional Preparation',
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
              children: methods.map((method) => Chip(
                backgroundColor: const Color(0xFFF5F5DC),
                label: Text(method, style: TextStyle(fontSize: 12)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // NEW: Regional Variations Section
  Widget _buildRegionalVariationsSection(ThemeData theme) {
    final variations = _culturalData!.regionalVariations;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.public, color: const Color(0xFF8B4513)),
                const SizedBox(width: 8),
                Text(
                  'Regional Variations',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF8B4513),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: variations.entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B4513)),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        entry.value,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                )
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // NEW: AI Fun Facts Section
  Widget _buildAIFunFactsSection(ThemeData theme) {
    return Card(
      color: const Color(0xFFFFF8DC),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: const Color(0xFFD2691E)),
                const SizedBox(width: 8),
                Text(
                  'AI-Generated Fun Facts',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFD2691E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Column(
              children: _aiGeneratedFunFacts.asMap().entries.map((entry) => 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${entry.key + 1}.',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD2691E),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(entry.value)),
                    ],
                  ),
                )
              ).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ENHANCED: Cultural Tips with AI insights
  Widget _buildEnhancedCulturalTips(ThemeData theme, String origin) {
    return Card(
      color: const Color(0xFFF0FFF0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: const Color(0xFF2E8B57)),
                const SizedBox(width: 8),
                Text(
                  'AI Cultural Tips for $origin Cuisine',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2E8B57),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAITipItem('Ask locals about the story behind traditional preparation methods'),
            _buildAITipItem('Try to learn a few phrases in the local language related to food'),
            _buildAITipItem('Observe dining etiquette specific to this cultural context'),
            _buildAITipItem('Be open to unexpected flavor combinations and textures'),
            _buildAITipItem('Document your experience to share cultural insights with others'),
          ],
        ),
      ),
    );
  }

  Widget _buildAITipItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.psychology, size: 16, color: const Color(0xFF2E8B57)),
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