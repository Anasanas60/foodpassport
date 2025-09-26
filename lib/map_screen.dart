import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/food_state_service.dart';
import 'models/food_item.dart';
import 'recipe_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
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

      // Simulate loading for better UX
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load food map: $e';
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
    final List<FoodItem> foodEntries = foodState.foodHistory
        .where((entry) => entry.position != null)
        .toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.explore, color: Color(0xFF4CAF50)),
            SizedBox(width: 12),
            Text('Food Discovery Map 🗺️'),
          ],
        ),
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshData,
            tooltip: 'Refresh Food Map',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildMapHeader(theme, foodEntries),
            const SizedBox(height: 20),
            Expanded(child: _buildContent(theme, foodEntries, foodState)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/camera');
        },
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        child: const Icon(Icons.camera_alt),
        tooltip: 'Scan New Food',
      ),
    );
  }

  Widget _buildMapHeader(ThemeData theme, List<FoodItem> foodEntries) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(40),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.explore, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FOOD DISCOVERY MAP',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track your culinary discoveries around the world',
                          style: TextStyle(
                            fontSize: 12, 
                            color: Colors.white.withAlpha(204),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMapStat(
                    foodEntries.length.toString(),
                    'Food Discoveries', 
                    Icons.restaurant,
                  ),
                  _buildMapStat(
                    _getUniqueCuisines(foodEntries).length.toString(),
                    'Cuisines Tried', 
                    Icons.public,
                  ),
                  _buildMapStat(
                    _getTotalDistance(foodEntries).toStringAsFixed(0),
                    'Km Traveled*', 
                    Icons.airplanemode_active,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '*Estimated distance between food locations',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withAlpha(178),
                  fontStyle: FontStyle.italic,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(40),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold, 
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10, 
            color: Colors.white.withAlpha(204),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme, List<FoodItem> foodEntries, FoodStateService foodState) {
    if (_isLoading) {
      return _buildLoadingMap();
    }
    if (_errorMessage.isNotEmpty) {
      return _buildErrorMap();
    }
    if (foodEntries.isEmpty) {
      return _buildEmptyMap();
    }
    return RefreshIndicator(
      onRefresh: _refreshData,
      backgroundColor: const Color(0xFF4CAF50),
      color: Colors.white,
      child: ListView.builder(
        itemCount: foodEntries.length,
        itemBuilder: (context, index) {
          final foodItem = foodEntries[index];
          return _buildFoodMapCard(foodItem, index, theme, foodState);
        },
      ),
    );
  }

  Widget _buildLoadingMap() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.explore, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          Text(
            'Mapping Your Discoveries...', 
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 10),
          const CircularProgressIndicator(color: Color(0xFF4CAF50)),
        ],
      ),
    );
  }

  Widget _buildErrorMap() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
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
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMap() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF4CAF50), width: 3),
            ),
            child: const Icon(Icons.explore_off, size: 60, color: Color(0xFF4CAF50)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Food Discoveries Yet!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Start your food discovery journey\nby scanning dishes with location enabled',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/camera');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt),
                SizedBox(width: 8),
                Text('Start Discovery'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodMapCard(FoodItem foodItem, int index, ThemeData theme, FoodStateService foodState) {
    final foodColor = _getFoodColor(foodItem.name);
    final position = foodItem.position!;
    final hasAllergyRisk = foodItem.detectedAllergens.isNotEmpty && 
        foodState.userProfile != null &&
        foodItem.containsAllergens(foodState.userProfile!.allergies);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: hasAllergyRisk ? Colors.orange : const Color(0xFF4CAF50), 
          width: hasAllergyRisk ? 2 : 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              foodColor.withAlpha(25),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: foodColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF4CAF50), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasAllergyRisk ? Icons.warning : Icons.location_pin, 
                  color: Colors.white, 
                  size: 20,
                ),
                Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          title: Text(
            foodItem.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.pin_drop, size: 12, color: foodColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _getLocationDescription(position),
                      style: TextStyle(color: Colors.grey[700], fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.explore, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${position.latitude.toStringAsFixed(4)}°N, ${position.longitude.toStringAsFixed(4)}°E',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.restaurant, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${foodItem.calories.round()} cal • ${_formatDate(foodItem.timestamp)}',
                    style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (hasAllergyRisk) ...[
                const SizedBox(height: 4),
                Text(
                  '⚠️ Contains allergens',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.zoom_in_map, color: foodColor, size: 20),
              const SizedBox(height: 4),
              Text(
                'View',
                style: TextStyle(
                  fontSize: 10,
                  color: foodColor,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          onTap: () {
            _showFoodDiscoveryDetails(foodItem, foodState);
          },
        ),
      ),
    );
  }

  void _showFoodDiscoveryDetails(FoodItem foodItem, FoodStateService foodState) {
    final foodColor = _getFoodColor(foodItem.name);
    final position = foodItem.position!;
    final hasAllergyRisk = foodItem.detectedAllergens.isNotEmpty && 
        foodState.userProfile != null &&
        foodItem.containsAllergens(foodState.userProfile!.allergies);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFf8f5f0)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: foodColor, 
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        hasAllergyRisk ? Icons.warning : Icons.explore,
                        color: Colors.white, 
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        foodItem.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildDiscoveryDetailRow('📍 Location', _getLocationDescription(position), Icons.pin_drop),
                _buildDiscoveryDetailRow(
                  '🌐 Coordinates',
                  '${position.latitude.toStringAsFixed(6)}°N, ${position.longitude.toStringAsFixed(6)}°E',
                  Icons.explore,
                ),
                _buildDiscoveryDetailRow('🔥 Calories', '${foodItem.calories.round()} calories', Icons.bolt),
                _buildDiscoveryDetailRow('💪 Protein', '${foodItem.protein.round()}g', Icons.fitness_center),
                _buildDiscoveryDetailRow('🍚 Carbs', '${foodItem.carbs.round()}g', Icons.grain),
                _buildDiscoveryDetailRow('🥑 Fat', '${foodItem.fat.round()}g', Icons.oil_barrel),
                if (foodItem.area != null) 
                  _buildDiscoveryDetailRow('🌍 Cuisine', foodItem.area!, Icons.public),
                _buildDiscoveryDetailRow('📅 Discovery Date', _formatDate(foodItem.timestamp), Icons.calendar_today),
                _buildDiscoveryDetailRow('🔍 Source', foodItem.source, Icons.psychology),
                _buildDiscoveryDetailRow(
                  '🎯 Confidence',
                  '${(foodItem.confidenceScore * 100).toStringAsFixed(0)}% certain',
                  Icons.verified,
                ),
                if (hasAllergyRisk) 
                  _buildDiscoveryDetailRow('⚠️ Allergy Risk', 'Contains your allergens!', Icons.warning),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
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
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('View Details'),
                      ),
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

  Widget _buildDiscoveryDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Icon(icon, size: 14, color: const Color(0xFF4CAF50)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500, 
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 12)),
          ),
        ],
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

  String _getLocationDescription(Position position) {
    // Simple location description based on coordinates
    if (position.latitude > 48.0 && position.latitude < 60.0 && 
        position.longitude > -10.0 && position.longitude < 5.0) {
      return 'United Kingdom';
    } else if (position.latitude > 35.0 && position.latitude < 45.0 && 
               position.longitude > 135.0 && position.longitude < 145.0) {
      return 'Japan';
    } else if (position.latitude > 10.0 && position.latitude < 20.0 && 
               position.longitude > 95.0 && position.longitude < 105.0) {
      return 'Thailand';
    } else if (position.latitude > 40.0 && position.latitude < 50.0 && 
               position.longitude > -125.0 && position.longitude < -65.0) {
      return 'United States';
    } else {
      return 'Lat: ${position.latitude.toStringAsFixed(2)}, Lon: ${position.longitude.toStringAsFixed(2)}';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  List<String> _getUniqueCuisines(List<FoodItem> foodEntries) {
    final cuisines = foodEntries
        .where((entry) => entry.area != null)
        .map((entry) => entry.area!)
        .toSet()
        .toList();
    return cuisines;
  }

  double _getTotalDistance(List<FoodItem> foodEntries) {
    double totalDistance = 0.0;
    for (int i = 0; i < foodEntries.length - 1; i++) {
      final pos1 = foodEntries[i].position!;
      final pos2 = foodEntries[i + 1].position!;

      final distance = _calculateDistance(
        pos1.latitude, pos1.longitude, 
        pos2.latitude, pos2.longitude,
      );
      totalDistance += distance;
    }
    return totalDistance;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) * 
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }
}