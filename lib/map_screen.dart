import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/food_state_service.dart';
import '../services/user_profile_service.dart';
import '../models/food_item.dart';
import 'recipe_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selectedCategoryIndex = 0;
  final List<String> _categories = [
    'All',
    'Regional Specialties',
    'Street Food',
    'Desserts',
    'Healthy',
    'Spicy',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final foodState = Provider.of<FoodStateService>(context);
    final userProfileService = Provider.of<UserProfileService>(context);

    // Enhanced food discovery data with real images and flags
    final List<Map<String, dynamic>> foodDiscoveries = [
      {
        'name': 'Margherita Pizza',
        'cuisine': 'Italian',
        'country': 'Italy',
        'flag': '🇮🇹',
        'image': 'https://images.unsplash.com/photo-1604068549290-dea0e4a305ca?w=400',
        'difficulty': 'Easy',
        'rating': 4.8,
        'isExplored': true,
        'ingredients': ['Tomato', 'Mozzarella', 'Basil'],
      },
      {
        'name': 'Sushi Platter',
        'cuisine': 'Japanese',
        'country': 'Japan',
        'flag': '🇯🇵',
        'image': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=400',
        'difficulty': 'Medium',
        'rating': 4.9,
        'isExplored': false,
        'ingredients': ['Rice', 'Fish', 'Seaweed'],
      },
      {
        'name': 'Pad Thai',
        'cuisine': 'Thai',
        'country': 'Thailand',
        'flag': '🇹🇭',
        'image': 'https://images.unsplash.com/photo-1559314809-0f155d88c17d?w=400',
        'difficulty': 'Medium',
        'rating': 4.7,
        'isExplored': true,
        'ingredients': ['Noodles', 'Shrimp', 'Peanuts'],
      },
      {
        'name': 'Croissant',
        'cuisine': 'French',
        'country': 'France',
        'flag': '🇫🇷',
        'image': 'https://images.unsplash.com/photo-1555507032-40b1cf5a7c2c?w=400',
        'difficulty': 'Hard',
        'rating': 4.6,
        'isExplored': false,
        'ingredients': ['Butter', 'Flour', 'Yeast'],
      },
      {
        'name': 'Tacos al Pastor',
        'cuisine': 'Mexican',
        'country': 'Mexico',
        'flag': '🇲🇽',
        'image': 'https://images.unsplash.com/photo-1565299585323-38d6b0865b47?w=400',
        'difficulty': 'Easy',
        'rating': 4.8,
        'isExplored': true,
        'ingredients': ['Pork', 'Pineapple', 'Tortilla'],
      },
      {
        'name': 'Mango Sticky Rice',
        'cuisine': 'Thai',
        'country': 'Thailand',
        'flag': '🇹🇭',
        'image': 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=400',
        'difficulty': 'Easy',
        'rating': 4.9,
        'isExplored': false,
        'ingredients': ['Mango', 'Rice', 'Coconut'],
      },
    ];

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text('Explore Local Flavors'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: colorScheme.onPrimary),
            onPressed: () {
              _showFilterOptions(context, colorScheme);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Tabs - Enhanced with better styling
          _buildCategoryTabs(colorScheme),
          
          const SizedBox(height: 16),
          
          // Content Grid
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildFoodGrid(
                foodDiscoveries, 
                colorScheme, 
                foodState, 
                userProfileService.userProfile
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs(ColorScheme colorScheme) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final isSelected = index == _selectedCategoryIndex;
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 16 : 8,
              right: index == _categories.length - 1 ? 16 : 0,
              top: 8,
              bottom: 8,
            ),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategoryIndex = index;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? colorScheme.primary : Colors.grey[300]!,
                    width: 1.5,
                  ),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: colorScheme.primary.withAlpha(100),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ] : null,
                ),
                child: Text(
                  _categories[index],
                  style: TextStyle(
                    color: isSelected ? colorScheme.onPrimary : const Color(0xFF333333),
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFoodGrid(
    List<Map<String, dynamic>> foodDiscoveries,
    ColorScheme colorScheme,
    FoodStateService foodState,
    userProfile,
  ) {
    // Filter by selected category
    final filteredDiscoveries = _filterDiscoveriesByCategory(foodDiscoveries);

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.75,
      ),
      itemCount: filteredDiscoveries.length,
      itemBuilder: (context, index) {
        final food = filteredDiscoveries[index];
        return _buildFoodCard(food, colorScheme, foodState, userProfile);
      },
    );
  }

  List<Map<String, dynamic>> _filterDiscoveriesByCategory(
      List<Map<String, dynamic>> discoveries) {
    if (_selectedCategoryIndex == 0) return discoveries;

    final category = _categories[_selectedCategoryIndex];
    switch (category) {
      case 'Regional Specialties':
        return discoveries.where((food) => 
          food['cuisine'] == 'Italian' || 
          food['cuisine'] == 'Japanese' || 
          food['cuisine'] == 'French'
        ).toList();
      case 'Street Food':
        return discoveries.where((food) => 
          food['name'] == 'Tacos al Pastor' || 
          food['name'] == 'Pad Thai'
        ).toList();
      case 'Desserts':
        return discoveries.where((food) => 
          food['name'] == 'Croissant' || 
          food['name'] == 'Mango Sticky Rice'
        ).toList();
      case 'Healthy':
        return discoveries.where((food) => 
          food['name'] == 'Sushi Platter' || 
          food['name'] == 'Mango Sticky Rice'
        ).toList();
      case 'Spicy':
        return discoveries.where((food) => 
          food['name'] == 'Pad Thai' || 
          food['name'] == 'Tacos al Pastor'
        ).toList();
      default:
        return discoveries;
    }
  }

  Widget _buildFoodCard(
    Map<String, dynamic> food,
    ColorScheme colorScheme,
    FoodStateService foodState,
    userProfile,
  ) {
    final isExplored = food['isExplored'] as bool;
    final difficulty = food['difficulty'] as String;
    final rating = food['rating'] as double;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => _showFoodDetails(food, colorScheme, foodState),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food Image with Gradient Overlay
                Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    image: DecorationImage(
                      image: NetworkImage(food['image'] as String),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withAlpha(100),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Country Flag
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              food['flag'] as String,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ),
                        ),
                        
                        // Difficulty Badge
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getDifficultyColor(difficulty),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              difficulty[0],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        
                        // Rating
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(150),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star, color: Colors.amber, size: 10),
                                const SizedBox(width: 2),
                                Text(
                                  rating.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Content
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Food Name
                      Text(
                        food['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF333333),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const SizedBox(height: 4),
                      
                      // Cuisine and Country
                      Text(
                        '${food['cuisine']} • ${food['country']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      const Spacer(),
                      
                      // Quick Action Button
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isExplored ? colorScheme.primary.withAlpha(25) : colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            isExplored ? 'View Recipe' : 'Discover',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isExplored ? colorScheme.primary : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Passport Stamp for explored items
            if (isExplored)
              Positioned(
                top: -5,
                right: -5,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withAlpha(150),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.star,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showFilterOptions(BuildContext context, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filter Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              _buildFilterOption('Only Show Unexplored', false),
              _buildFilterOption('Show High Protein', false),
              _buildFilterOption('Show Vegetarian', true),
              _buildFilterOption('Show Gluten-Free', false),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String title, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Checkbox(
            value: isSelected,
            onChanged: (value) {},
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showFoodDetails(
    Map<String, dynamic> food,
    ColorScheme colorScheme,
    FoodStateService foodState,
  ) {
    final isExplored = food['isExplored'] as bool;
    final ingredients = food['ingredients'] as List<String>;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(100),
              blurRadius: 32,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Header with Image
              Stack(
                children: [
                  Container(
                    height: 200,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      image: DecorationImage(
                        image: NetworkImage(food['image'] as String),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(200),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        food['flag'] as String,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Food Title and Info
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          food['name'] as String,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        Text(
                          '${food['cuisine']} • ${food['country']}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getDifficultyColor(food['difficulty'] as String),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      food['difficulty'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Exploration Status with Gamification
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isExplored ? colorScheme.primary.withAlpha(25) : Colors.orange.withAlpha(25),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isExplored ? colorScheme.primary : Colors.orange,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isExplored ? Icons.verified : Icons.explore,
                      color: isExplored ? colorScheme.primary : Colors.orange,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isExplored ? 'Exploration Complete!' : 'New Discovery!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: const Color(0xFF333333),
                            ),
                          ),
                          Text(
                            isExplored ? '+10 XP • Passport Stamped' : 'Scan to explore and earn XP',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Ingredients Section
              const Text(
                'Ingredients',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ingredients.map((ingredient) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.primary.withAlpha(100)),
                  ),
                  child: Text(
                    ingredient,
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
              
              const Spacer(),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Create a food item and navigate to recipe
                        final foodItem = FoodItem(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: food['name'] as String,
                          confidenceScore: 0.9,
                          calories: 320,
                          protein: 15,
                          carbs: 45,
                          fat: 8,
                          source: 'explore',
                          detectedAllergens: [],
                          imagePath: '',
                          timestamp: DateTime.now(),
                        );
                        
                        foodState.setCurrentFood(foodItem);
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RecipeScreen(dishName: foodItem.name),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'View Recipe',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NutritionInfoItem extends StatelessWidget {
  final String label;
  final String value;

  const NutritionInfoItem({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}