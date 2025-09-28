import 'package:geolocator/geolocator.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/food_state_service.dart';
import 'services/user_profile_service.dart';
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
    _determinePositionAndLoadEntries();
  }

  Future<void> _determinePositionAndLoadEntries() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
            'Location permissions are permanently denied, cannot request.');
      }

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

  Future<void> _refreshData() async => _determinePositionAndLoadEntries();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foodState = Provider.of<FoodStateService>(context);
    final userProfileService = Provider.of<UserProfileService>(context);
    final userProfile = userProfileService.userProfile;
    final foodEntries = foodState.foodHistory.where((e) => e.position != null).toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.explore, color: theme.colorScheme.secondary),
            const SizedBox(width: 12),
            const Text('Food Discovery Map 🗺️'),
          ],
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: theme.colorScheme.onPrimary),
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
            Expanded(child: _buildContent(theme, foodEntries, foodState, userProfile)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/camera'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
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
        side: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onPrimary.withAlpha(40),
                    shape: BoxShape.circle,
                    border: Border.all(color: theme.colorScheme.onPrimary, width: 2),
                  ),
                  child: Icon(Icons.explore, color: theme.colorScheme.onPrimary, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FOOD DISCOVERY MAP',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onPrimary,
                          letterSpacing: 1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Track your culinary discoveries around the world',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onPrimary.withAlpha(204),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMapStat(foodEntries.length.toString(), 'Food Discoveries', Icons.restaurant, theme),
                  _buildMapStat(_getUniqueCuisines(foodEntries).length.toString(), 'Cuisines Tried', Icons.public, theme),
                  _buildMapStat(_getTotalDistance(foodEntries).toStringAsFixed(0), 'Km Traveled*', Icons.airplanemode_active, theme),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '*Estimated distance between food locations',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onPrimary.withAlpha(178),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapStat(String value, String label, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: theme.colorScheme.onPrimary.withAlpha(40), shape: BoxShape.circle),
          child: Icon(icon, color: theme.colorScheme.onPrimary, size: 18),
        ),
        const SizedBox(height: 6),
        Text(value, style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onPrimary)),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onPrimary.withAlpha(204)), textAlign: TextAlign.center),
      ],
    );
  }

  Widget _buildContent(ThemeData theme, List<FoodItem> foodEntries, FoodStateService foodState, userProfile) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(color: theme.colorScheme.primary));
    }
    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.error)));
    }
    if (foodEntries.isEmpty) {
      return Center(child: Text('No Food Discoveries Yet!', style: theme.textTheme.titleMedium));
    }
    return RefreshIndicator(
      onRefresh: _refreshData,
      backgroundColor: theme.colorScheme.primary,
      color: theme.colorScheme.onPrimary,
      child: ListView.builder(
        itemCount: foodEntries.length,
        itemBuilder: (context, index) {
          final foodItem = foodEntries[index];
          final hasAllergyRisk = foodItem.detectedAllergens.isNotEmpty &&
              userProfile != null &&
              foodItem.containsAllergens(userProfile.allergies);
          return _buildFoodMapCard(foodItem, index, theme, foodState, hasAllergyRisk);
        },
      ),
    );
  }

  Widget _buildFoodMapCard(FoodItem foodItem, int index, ThemeData theme, FoodStateService foodState, bool hasAllergyRisk) {
    final foodColor = _getFoodColor(foodItem.name);
    final position = foodItem.position!;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: hasAllergyRisk ? theme.colorScheme.error : theme.colorScheme.primary, width: hasAllergyRisk ? 2 : 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [theme.colorScheme.surface, foodColor.withAlpha(25)], begin: Alignment.centerLeft, end: Alignment.centerRight),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: foodColor, borderRadius: BorderRadius.circular(12), border: Border.all(color: theme.colorScheme.primary, width: 2)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(hasAllergyRisk ? Icons.warning : Icons.location_pin, color: Colors.white, size: 20),
              Text('${index + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
            ]),
          ),
          title: Text(foodItem.name, style: theme.textTheme.titleMedium?.copyWith(color: const Color(0xFF333333), fontWeight: FontWeight.bold)),
          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.pin_drop, size: 12, color: foodColor),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(
                _getLocationDescription(position),
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              Icon(Icons.explore, size: 12, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('${position.latitude.toStringAsFixed(4)}°N, ${position.longitude.toStringAsFixed(4)}°E', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600])),
            ]),
            Row(children: [
              Icon(Icons.restaurant, size: 12, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text('${foodItem.calories.round()} cal • ${_formatDate(foodItem.timestamp)}', style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]))
            ]),
            if (hasAllergyRisk)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '⚠️ Contains allergens',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error, fontWeight: FontWeight.bold),
                ),
              )
          ]),
          trailing: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.zoom_in_map, color: foodColor, size: 20),
            const SizedBox(height: 4),
            Text('View', style: theme.textTheme.bodySmall?.copyWith(color: foodColor, fontWeight: FontWeight.bold))
          ]),
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
    final userProfileService = Provider.of<UserProfileService>(context, listen: false);
    final userProfile = userProfileService.userProfile;
    final hasAllergyRisk = foodItem.detectedAllergens.isNotEmpty && userProfile != null && foodItem.containsAllergens(userProfile.allergies);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Theme.of(context).colorScheme.surface, const Color(0xFFF8F5F0)]),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: foodColor, shape: BoxShape.circle), child: Icon(hasAllergyRisk ? Icons.warning : Icons.explore, color: Colors.white, size: 20)),
                const SizedBox(width: 12),
                Expanded(child: Text(foodItem.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF333333)))),
              ]),
              const SizedBox(height: 20),
              _buildDiscoveryDetailRow('📍 Location', _getLocationDescription(position), Icons.pin_drop),
              _buildDiscoveryDetailRow('🌐 Coordinates', '${position.latitude.toStringAsFixed(6)}°N, ${position.longitude.toStringAsFixed(6)}°E', Icons.explore),
              _buildDiscoveryDetailRow('🔥 Calories', '${foodItem.calories.round()} calories', Icons.bolt),
              _buildDiscoveryDetailRow('💪 Protein', '${foodItem.protein.round()}g', Icons.fitness_center),
              _buildDiscoveryDetailRow('🍚 Carbs', '${foodItem.carbs.round()}g', Icons.grain),
              _buildDiscoveryDetailRow('🥑 Fat', '${foodItem.fat.round()}g', Icons.oil_barrel),
              if (foodItem.area != null) _buildDiscoveryDetailRow('🌍 Cuisine', foodItem.area!, Icons.public),
              _buildDiscoveryDetailRow('📅 Discovery Date', _formatDate(foodItem.timestamp), Icons.calendar_today),
              _buildDiscoveryDetailRow('🔍 Source', foodItem.source, Icons.psychology),
              _buildDiscoveryDetailRow('🎯 Confidence', '${(foodItem.confidenceScore * 100).toStringAsFixed(0)}% certain', Icons.verified),
              if (hasAllergyRisk) _buildDiscoveryDetailRow('⚠️ Allergy Risk', 'Contains your allergens!', Icons.warning),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      foodState.setCurrentFood(foodItem);
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => RecipeScreen(dishName: foodItem.name)));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                    child: const Text('View Details'),
                  ),
                ),
              ]),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _buildDiscoveryDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 120, child: Row(children: [Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary), const SizedBox(width: 6), Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12))])),
        const SizedBox(width: 8),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 12))),
      ]),
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
    if (position.latitude > 48.0 && position.latitude < 60.0 && position.longitude > -10.0 && position.longitude < 5.0) {
      return 'United Kingdom';
    } else if (position.latitude > 35.0 && position.latitude < 45.0 && position.longitude > 135.0 && position.longitude < 145.0) {
      return 'Japan';
    } else if (position.latitude > 10.0 && position.latitude < 20.0 && position.longitude > 95.0 && position.longitude < 105.0) {
      return 'Thailand';
    } else if (position.latitude > 40.0 && position.latitude < 50.0 && position.longitude > -125.0 && position.longitude < -65.0) {
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
    final cuisines = foodEntries.where((entry) => entry.area != null).map((entry) => entry.area!).toSet().toList();
    return cuisines;
  }

  double _getTotalDistance(List<FoodItem> foodEntries) {
    double totalDistance = 0.0;
    for (int i = 0; i < foodEntries.length - 1; i++) {
      final pos1 = foodEntries[i].position!;
      final pos2 = foodEntries[i + 1].position!;

      totalDistance += _calculateDistance(pos1.latitude, pos1.longitude, pos2.latitude, pos2.longitude);
    }
    return totalDistance;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }
}

// In your FoodItem model file please add this extension for allergens check
extension FoodItemExtension on FoodItem {
  bool containsAllergens(List<String> allergies) {
    return detectedAllergens.any((allergen) => allergies.contains(allergen));
  }
}
