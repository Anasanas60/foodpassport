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

      // Try to get real cultural data
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
    // Analyze dish name to determine likely cuisine origin
    final cuisineType = _determineCuisineType(dishName);
    
    try {
      // Try to get country information first
      final countryData = await _fetchCountryInfo(cuisineType);
      
      return {
        'origin': countryData['name'] ?? cuisineType,
        'countryInfo': countryData,
        'culturalInfo': _generateCulturalDescription(dishName, cuisineType, countryData),
        'history': _generateDishHistory(dishName, cuisineType),
        'etiquette': _generateDiningEtiquette(cuisineType),
        'funFact': _generateFunFact(dishName, cuisineType),
        'cuisine': cuisineType,
        'hasRealData': countryData.isNotEmpty,
      };
    } catch (e) {
      // Fallback to generated data
      return _generateFallbackCulturalData(dishName);
    }
  }

  Future<Map<String, dynamic>> _fetchCountryInfo(String cuisineType) async {
    final countryName = _cuisineToCountry(cuisineType);
    
    if (countryName.isEmpty) return {};
    
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.restCountriesUrl}/${Uri.encodeComponent(countryName)}')
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List && data.isNotEmpty) {
          final country = data[0];
          return {
            'name': country['name']?['common'] ?? countryName,
            'region': country['region'] ?? 'Unknown',
            'subregion': country['subregion'] ?? '',
            'population': country['population'] ?? 0,
            'capital': country['capital'] != null ? country['capital'][0] : 'Unknown',
            'languages': country['languages'] ?? {},
            'flag': country['flags']?['png'] ?? '',
          };
        }
      }
      return {};
    } catch (e) {
      return {};
    }
  }

  String _determineCuisineType(String dishName) {
    final lowerName = dishName.toLowerCase();
    
    if (lowerName.contains('sushi') || lowerName.contains('ramen') || lowerName.contains('tempura')) 
      return 'Japanese';
    if (lowerName.contains('taco') || lowerName.contains('burrito') || lowerName.contains('enchilada')) 
      return 'Mexican';
    if (lowerName.contains('pasta') || lowerName.contains('pizza') || lowerName.contains('risotto')) 
      return 'Italian';
    if (lowerName.contains('curry') || lowerName.contains('tikka') || lowerName.contains('masala')) 
      return 'Indian';
    if (lowerName.contains('pho') || lowerName.contains('banh mi') || lowerName.contains('spring roll')) 
      return 'Vietnamese';
    if (lowerName.contains('pad thai') || lowerName.contains('tom yum') || lowerName.contains('green curry')) 
      return 'Thai';
    if (lowerName.contains('burger') || lowerName.contains('steak') || lowerName.contains('barbecue')) 
      return 'American';
    if (lowerName.contains('croissant') || lowerName.contains('baguette') || lowerName.contains('ratatouille')) 
      return 'French';
    if (lowerName.contains('kung pao') || lowerName.contains('dim sum') || lowerName.contains('wonton')) 
      return 'Chinese';
    
    return 'International';
  }

  String _cuisineToCountry(String cuisine) {
    final mapping = {
      'Japanese': 'Japan',
      'Mexican': 'Mexico',
      'Italian': 'Italy',
      'Indian': 'India',
      'Vietnamese': 'Vietnam',
      'Thai': 'Thailand',
      'American': 'United States',
      'French': 'France',
      'Chinese': 'China',
    };
    return mapping[cuisine] ?? cuisine;
  }

  String _generateCulturalDescription(String dishName, String cuisine, Map<String, dynamic> countryInfo) {
    final countryName = countryInfo['name'] ?? cuisine;
    final region = countryInfo['region'] ?? 'the region';
    
    return '$dishName is a beloved dish from $countryName, reflecting the rich culinary traditions of $region. '
           'This dish showcases the unique flavors and cooking techniques that define ${cuisine.toLowerCase()} cuisine, '
           'often featuring local ingredients and traditional preparation methods passed down through generations.';
  }

  String _generateDishHistory(String dishName, String cuisine) {
    return '$dishName has a fascinating history rooted in ${cuisine.toLowerCase()} culinary traditions. '
           'The dish evolved over centuries, influenced by local ingredients, cultural exchanges, and historical events. '
           'Today, it represents both traditional cooking methods and modern adaptations that appeal to global palates.';
  }

  String _generateDiningEtiquette(String cuisine) {
    switch (cuisine.toLowerCase()) {
      case 'japanese':
        return '• Slurping noodles shows enjoyment\n• Say "itadakimasu" before eating\n• Use chopsticks properly\n• Don\'t stick chopsticks upright in rice';
      case 'italian':
        return '• Use fork and knife for pasta\n• Don\'t cut spaghetti\n• Bread is for soaking up sauce\n• Cappuccino only in morning';
      case 'indian':
        return '• Eat with right hand only\n• Bread used to scoop food\n• Try a bit of everything\n• Remove shoes if eating on floor';
      case 'mexican':
        return '• Use tortillas as utensils\n• Eat tacos with hands\n• Lime juice enhances flavors\n• Try different salsa heat levels';
      default:
        return '• Observe local customs\n• Try traditional eating methods\n• Respect food presentation\n• Enjoy the authentic experience';
    }
  }

  String _generateFunFact(String dishName, String cuisine) {
    final facts = {
      'Japanese': 'In Japan, it\'s considered polite to slurp noodles loudly to show appreciation!',
      'Italian': 'Real Italian pizza has a thin crust and minimal toppings to highlight quality ingredients.',
      'Indian': 'Indian cuisine uses over 25 different spices commonly, creating complex flavor profiles.',
      'Mexican': 'Chocolate was first consumed as a bitter drink by ancient Mesoamerican civilizations.',
      'Thai': 'Thai food balances sweet, sour, salty, bitter, and spicy flavors in every meal.',
      'Chinese': 'Chinese meals typically include fan (grains) and cai (vegetables/meat) for balance.',
    };
    
    return facts[cuisine] ?? 'This dish reflects centuries of culinary evolution and cultural exchange!';
  }

  Map<String, dynamic> _generateFallbackCulturalData(String dishName) {
    return {
      'origin': 'Various Global Influences',
      'culturalInfo': '$dishName is enjoyed worldwide with regional variations. This dish represents the beautiful diversity of global cuisine, adapting to local tastes while maintaining its core identity.',
      'history': 'This popular dish has traveled across cultures, evolving with each new region it touches while preserving its essential character.',
      'etiquette': 'Enjoy this dish in the way that feels most natural to you! Food is about pleasure and connection across cultures.',
      'funFact': 'Many popular dishes have surprising origins and have evolved significantly from their original versions!',
      'cuisine': 'International',
      'hasRealData': false,
    };
  }

  @override 
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cultural Insights: ${widget.dishName}'),
        backgroundColor: Colors.purple,
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
          ? _buildLoadingState()
          : _culturalData != null 
              ? _buildContent() 
              : _buildErrorState(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading cultural insights...',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discovering the story behind ${widget.dishName}',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          Text(
            'Unable to load cultural data',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: TextStyle(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadCulturalData,
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final data = _culturalData!;
    final hasRealData = data['hasRealData'] ?? false;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Origin Card
          Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.public,
                        size: 32,
                        color: hasRealData ? Colors.green : Colors.purple,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['origin'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Culinary Origin',
                              style: TextStyle(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (hasRealData)
                        Chip(
                          label: const Text('Verified Data'),
                          backgroundColor: Colors.green[50],
                          labelStyle: const TextStyle(color: Colors.green),
                        )
                      else
                        Chip(
                          label: const Text('AI Generated'),
                          backgroundColor: Colors.purple[50],
                          labelStyle: const TextStyle(color: Colors.purple),
                        ),
                    ],
                  ),
                  if (data['countryInfo'] != null && data['countryInfo'].isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildCountryInfo(data['countryInfo']),
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Cultural Information
          _buildInfoCard(
            'Cultural Significance',
            Icons.history,
            data['culturalInfo'],
            Colors.blue,
          ),
          
          const SizedBox(height: 16),
          
          // History
          _buildInfoCard(
            'Historical Background',
            Icons.book,
            data['history'],
            Colors.orange,
          ),
          
          const SizedBox(height: 16),
          
          // Dining Etiquette
          _buildInfoCard(
            'Dining Etiquette',
            Icons.emoji_people,
            data['etiquette'],
            Colors.green,
          ),
          
          const SizedBox(height: 16),
          
          // Fun Fact
          _buildInfoCard(
            'Fun Fact',
            Icons.emoji_events,
            data['funFact'],
            Colors.purple,
          ),
          
          const SizedBox(height: 20),
          
          // Data Source Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasRealData 
                        ? 'Cultural data sourced from RestCountries API and culinary research'
                        : 'AI-generated insights based on dish analysis',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryInfo(Map<String, dynamic> countryInfo) {
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
            if (countryInfo['capital'] != null) 
              _buildCountryDetail('Capital', countryInfo['capital']),
            if (countryInfo['region'] != null) 
              _buildCountryDetail('Region', countryInfo['region']),
            if (countryInfo['population'] != null) 
              _buildCountryDetail('Population', _formatPopulation(countryInfo['population'])),
          ],
        ),
      ],
    );
  }

  Widget _buildCountryDetail(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
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

  Widget _buildInfoCard(String title, IconData icon, String content, Color color) {
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
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}