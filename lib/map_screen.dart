import 'dart:math';
import 'package:flutter/material.dart';
import 'services/food_journal_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FoodJournalService _journalService = FoodJournalService();
  List<Map<String, dynamic>> _foodEntries = [];
  bool _isLoading = true;
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

      final entries = await _journalService.getFoodEntries();
      
      // Filter entries that have location data
      final entriesWithLocation = entries.where((entry) => 
        entry['location'] != null && 
        entry['location']['latitude'] != null &&
        entry['location']['longitude'] != null
      ).toList();

      setState(() {
        _foodEntries = entriesWithLocation;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load expedition map: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await _loadFoodEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf8f5f0),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.explore, color: Color(0xFFffd700)),
            SizedBox(width: 12),
            Text('Adventure Food Map 🗺️'),
          ],
        ),
        backgroundColor: const Color(0xFF2e7d32),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFffd700)),
            onPressed: _refreshData,
            tooltip: 'Refresh Expedition Map',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAdventureHeader(),
            const SizedBox(height: 20),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        backgroundColor: const Color(0xFF2e7d32),
        foregroundColor: const Color(0xFFffd700),
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh Adventure Map',
      ),
    );
  }

  Widget _buildAdventureHeader() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFffd700), width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2e7d32), Color(0xFF388e3c)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0x1AFFFFFF),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFffd700), width: 2),
                    ),
                    child: const Icon(Icons.explore, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'FOOD EXPEDITION MAP',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Track your culinary journey across the world',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
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
                  _buildExpeditionStat(
                    _foodEntries.length.toString(),
                    'Food Discoveries',
                    Icons.restaurant,
                  ),
                  _buildExpeditionStat(
                    _getUniqueCountries().length.toString(),
                    'Countries Explored',
                    Icons.public,
                  ),
                  _buildExpeditionStat(
                    _getTotalDistance().toStringAsFixed(0),
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
                  color: Colors.white.withOpacity(0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpeditionStat(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0x33FFFFFF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFffd700), size: 18),
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
            color: Colors.white.withOpacity(0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildLoadingExpedition();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorExpedition();
    }

    if (_foodEntries.isEmpty) {
      return _buildEmptyExpedition();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      backgroundColor: const Color(0xFF2e7d32),
      color: const Color(0xFFffd700),
      child: ListView.builder(
        itemCount: _foodEntries.length,
        itemBuilder: (context, index) {
          final entry = _foodEntries[index];
          return _buildExpeditionCard(entry, index);
        },
      ),
    );
  }

  Widget _buildLoadingExpedition() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF2e7d32),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFffd700), width: 2),
            ),
            child: const Icon(Icons.explore, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          const Text(
            'Charting Your Expedition...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2e7d32),
            ),
          ),
          const SizedBox(height: 10),
          const CircularProgressIndicator(color: Color(0xFF2e7d32)),
        ],
      ),
    );
  }

  Widget _buildErrorExpedition() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF2e7d32),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFffd700), width: 2),
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
              backgroundColor: const Color(0xFF2e7d32),
              foregroundColor: const Color(0xFFffd700),
            ),
            child: const Text('Retry Expedition'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyExpedition() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFf8f5f0),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFffd700), width: 3),
            ),
            child: const Icon(Icons.explore_off, size: 60, color: Color(0xFF2e7d32)),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Expedition Data Yet!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2e7d32),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Start your food exploration journey\nby scanning dishes with location enabled',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/menuscan');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2e7d32),
              foregroundColor: const Color(0xFFffd700),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt),
                SizedBox(width: 8),
                Text('Begin Exploration'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpeditionCard(Map<String, dynamic> entry, int index) {
    final location = entry['location'];
    final latitude = location['latitude'];
    final longitude = location['longitude'];
    final address = location['address'] ?? 'Unknown location';
    final foodColor = _getFoodColor(entry['foodName']);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFffd700), width: 1),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Colors.white, foodColor.withOpacity(0.1)],
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
              border: Border.all(color: const Color(0xFFffd700), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_pin, color: Colors.white, size: 20),
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
            entry['foodName']?.toString() ?? 'Unknown Discovery',
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
                      address,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.explore, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${latitude.toStringAsFixed(4)}°N, ${longitude.toStringAsFixed(4)}°E',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.restaurant, size: 12, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    '${entry['calories']?.toStringAsFixed(0) ?? 'N/A'} cal • ${_formatDate(entry['timestamp'])}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
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
              ),
            ],
          ),
          onTap: () {
            _showExpeditionDetails(entry);
          },
        ),
      ),
    );
  }

  void _showExpeditionDetails(Map<String, dynamic> entry) {
    final location = entry['location'];
    final foodColor = _getFoodColor(entry['foodName']);

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFffd700), width: 2),
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
            padding: const EdgeInsets.all(20.0),
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
                      child: const Icon(Icons.explore, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry['foodName']?.toString() ?? 'Expedition Discovery',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                _buildExpeditionDetailRow('📍 Location', location['address'] ?? 'Unknown', Icons.pin_drop),
                _buildExpeditionDetailRow('🌐 Coordinates', 
                  '${location['latitude']?.toStringAsFixed(6)}°N, ${location['longitude']?.toStringAsFixed(6)}°E', 
                  Icons.explore),
                _buildExpeditionDetailRow('🔥 Calories', '${entry['calories']?.toStringAsFixed(0) ?? 'N/A'} calories', Icons.bolt),
                _buildExpeditionDetailRow('💪 Protein', '${entry['protein']?.toStringAsFixed(1) ?? 'N/A'}g', Icons.fitness_center),
                _buildExpeditionDetailRow('🍚 Carbs', '${entry['carbs']?.toStringAsFixed(1) ?? 'N/A'}g', Icons.grain),
                _buildExpeditionDetailRow('🥑 Fat', '${entry['fat']?.toStringAsFixed(1) ?? 'N/A'}g', Icons.oil_barrel),
                _buildExpeditionDetailRow('📅 Expedition Date', _formatDate(entry['timestamp']), Icons.calendar_today),
                _buildExpeditionDetailRow('🔍 Discovery Source', entry['source']?.toString() ?? 'AI Explorer', Icons.psychology),
                _buildExpeditionDetailRow('🎯 Confidence', '${((entry['confidenceScore'] ?? 0) * 100).toStringAsFixed(0)}% certain', Icons.verified),
                
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2e7d32),
                      foregroundColor: const Color(0xFFffd700),
                    ),
                    child: const Text('Continue Expedition'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpeditionDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Row(
              children: [
                Icon(icon, size: 14, color: const Color(0xFF2e7d32)),
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
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Color _getFoodColor(String? foodName) {
    final colors = [
      const Color(0xFF1a237e),
      const Color(0xFF2e7d32),
      const Color(0xFF8b0000),
      const Color(0xFFff6f00),
      const Color(0xFF4a148c),
      const Color(0xFF00695c),
    ];
    final index = (foodName?.hashCode ?? 0).abs() % colors.length;
    return colors[index];
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    return '${date.day}/${date.month}/${date.year}';
  }

  List<String> _getUniqueCountries() {
    final countries = _foodEntries.map((entry) {
      final address = entry['location']?['address']?.toString() ?? '';
      if (address.contains(',')) {
        return address.split(',').last.trim();
      }
      return address;
    }).where((country) => country.isNotEmpty).toSet().toList();
    
    return countries;
  }

  double _getTotalDistance() {
    // Simple estimation - calculate total distance between consecutive points
    double totalDistance = 0.0;
    for (int i = 0; i < _foodEntries.length - 1; i++) {
      final loc1 = _foodEntries[i]['location'];
      final loc2 = _foodEntries[i + 1]['location'];
      
      if (loc1 != null && loc2 != null) {
        final lat1 = loc1['latitude'] ?? 0.0;
        final lon1 = loc1['longitude'] ?? 0.0;
        final lat2 = loc2['latitude'] ?? 0.0;
        final lon2 = loc2['longitude'] ?? 0.0;
        
        // Simple distance calculation (approximation)
        final distance = _calculateDistance(lat1, lon1, lat2, lon2);
        totalDistance += distance;
      }
    }
    return totalDistance;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Haversine formula approximation
    const earthRadius = 6371.0; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }
}