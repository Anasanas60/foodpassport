import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/food_state_service.dart';
import 'models/food_item.dart';
import 'animations/shimmer_loading.dart';
import 'recipe_screen.dart';

class FoodJournalScreen extends StatefulWidget {
  const FoodJournalScreen({super.key});

  @override
  State<FoodJournalScreen> createState() => _FoodJournalScreenState();
}

class _FoodJournalScreenState extends State<FoodJournalScreen> {
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadFoodEntries();
  }

  Future<void> _loadFoodEntries() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      // Simulate loading delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load food journal: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadFoodEntries();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foodState = Provider.of<FoodStateService>(context);
    final List<FoodItem> foodEntries = foodState.foodHistory;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.menu_book, color: Color(0xFFff6b6b)),
            SizedBox(width: 12),
            Text('Food Journal 🍽️'),
          ],
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFff6b6b)),
            onPressed: _refreshData,
            tooltip: 'Refresh Journal',
          ),
          if (foodEntries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              onPressed: _showClearConfirmation,
              tooltip: 'Clear Journal',
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildJournalHeader(theme, foodEntries),
            const SizedBox(height: 20),
            Expanded(
              child: _buildContent(theme, foodEntries, foodState),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/camera');
        },
        backgroundColor: const Color(0xFFff6b6b),
        foregroundColor: Colors.white,
        child: const Icon(Icons.camera_alt),
        tooltip: 'Scan New Food',
      ),
    );
  }

  Widget _buildJournalHeader(ThemeData theme, List<FoodItem> foodEntries) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: theme.colorScheme.secondary, width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFff6b6b),
              const Color(0xFFffa726)
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: ShimmerLoading(
            isLoading: _isLoading,
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.restaurant, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildJournalStat(
                      _isLoading ? '0' : foodEntries.length.toString(),
                      'Food Entries',
                      Icons.restaurant_menu,
                    ),
                    _buildJournalStat(
                      _isLoading ? '0' : _calculateTotalCalories(foodEntries).toStringAsFixed(0),
                      'Total Calories',
                      Icons.local_fire_department,
                    ),
                    _buildJournalStat(
                      _isLoading ? '0' : _getUniqueCuisines(foodEntries).length.toString(),
                      'Cuisines',
                      Icons.public,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildJournalStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.9)
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme, List<FoodItem> foodEntries, FoodStateService foodState) {
    if (_isLoading) {
      return _buildShimmerLoadingGrid();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (foodEntries.isEmpty) {
      return _buildEmptyJournalState();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      backgroundColor: const Color(0xFFff6b6b),
      color: Colors.white,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: foodEntries.length,
        itemBuilder: (context, index) {
          final foodItem = foodEntries[index];
          return _buildFoodJournalCard(foodItem, foodState);
        },
      ),
    );
  }

  Widget _buildShimmerLoadingGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return ShimmerLoading(
          isLoading: true,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[200],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFff6b6b),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.error_outline, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _loadFoodEntries,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFff6b6b),
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyJournalState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFff6b6b), width: 3),
            ),
            child: const Icon(Icons.restaurant_menu,
                size: 50, color: Color(0xFFff6b6b)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your Food Journal is Empty!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFFff6b6b),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Start your culinary journey by scanning\nfood to build your personal food diary!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/camera');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFff6b6b),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt),
                SizedBox(width: 8),
                Text('Scan First Food'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodJournalCard(FoodItem foodItem, FoodStateService foodState) {
    final foodColor = _getFoodColor(foodItem.name);
    final hasAllergyRisk = foodItem.detectedAllergens.isNotEmpty && 
        foodState.userProfile != null &&
        foodItem.containsAllergens(foodState.userProfile!.allergies);

    return GestureDetector(
      onTap: () {
        foodState.setCurrentFood(foodItem);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecipeScreen(dishName: foodItem.name),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: hasAllergyRisk ? Colors.orange : Theme.of(context).colorScheme.secondary, 
            width: hasAllergyRisk ? 2 : 1
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image/Color Header
            Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [foodColor, _darkenColor(foodColor, 0.3)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          hasAllergyRisk ? Icons.warning : Icons.restaurant, 
                          size: 30, 
                          color: Colors.white
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${foodItem.calories.round()} cal',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.star, 
                        size: 16, 
                        color: foodColor
                      ),
                    ),
                  ),
                  if (hasAllergyRisk)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning, 
                          size: 16, 
                          color: Colors.white
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Food Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      foodItem.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF333333),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Nutrition Summary
                    Row(
                      children: [
                        Icon(Icons.fitness_center, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'P:${foodItem.protein.round()}g',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.grain, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          'C:${foodItem.carbs.round()}g',
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Date and Time
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(foodItem.timestamp),
                          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Confidence and Source
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.verified, size: 12, color: foodColor),
                            const SizedBox(width: 4),
                            Text(
                              '${(foodItem.confidenceScore * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 10,
                                color: foodColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          foodItem.source,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                    if (hasAllergyRisk) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Contains allergens!',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Color _getFoodColor(String foodName) {
    final colors = [
      const Color(0xFF1a237e), // Blue
      const Color(0xFF2e7d32), // Green
      const Color(0xFF8b0000), // Red
      const Color(0xFFff6f00), // Orange
      const Color(0xFF4a148c), // Purple
      const Color(0xFF00695c), // Teal
    ];
    final index = foodName.hashCode.abs() % colors.length;
    return colors[index];
  }

  Color _darkenColor(Color color, double factor) {
    assert(factor >= 0 && factor <= 1);
    return Color.fromARGB(
      color.alpha,
      (color.red * (1 - factor)).round(),
      (color.green * (1 - factor)).round(),
      (color.blue * (1 - factor)).round(),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  double _calculateTotalCalories(List<FoodItem> foodEntries) {
    return foodEntries.fold(0.0, (sum, entry) => sum + entry.calories);
  }

  List<String> _getUniqueCuisines(List<FoodItem> foodEntries) {
    final cuisines = foodEntries
        .where((entry) => entry.area != null)
        .map((entry) => entry.area!)
        .toSet()
        .toList();
    return cuisines;
  }

  void _showClearConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Food Journal?'),
        content: const Text('This will remove all your food entries. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final foodState = Provider.of<FoodStateService>(context, listen: false);
              // Clear the food history
              // Note: You'll need to add a clearHistory method to FoodStateService
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Food journal cleared')),
              );
            },
            child: const Text('Clear', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}