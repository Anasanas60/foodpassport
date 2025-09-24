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
        _errorMessage = 'Failed to load food locations: $e';
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
      appBar: AppBar(
        title: const Text('My Food Map 🗺️'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh Map',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with statistics
            _buildHeader(),
            const SizedBox(height: 20),
            
            // Content area
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh Food Map',
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Food Discovery Journey',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          '${_foodEntries.length} foods with location data',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        if (_foodEntries.isNotEmpty) ...[
          Text(
            'Countries visited: ${_getUniqueCountries().length}',
            style: const TextStyle(fontSize: 14, color: Colors.green),
          ),
        ],
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading your food journey...'),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadFoodEntries,
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_foodEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.explore, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No food locations yet!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Scan some food with location enabled\nto see your journey on the map!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Navigate to camera screen
                Navigator.pushNamed(context, '/menu-scan');
              },
              child: const Text('Scan Food with Location'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        itemCount: _foodEntries.length,
        itemBuilder: (context, index) {
          final entry = _foodEntries[index];
          return _buildLocationCard(entry);
        },
      ),
    );
  }

  Widget _buildLocationCard(Map<String, dynamic> entry) {
    final location = entry['location'];
    final latitude = location['latitude'];
    final longitude = location['longitude'];
    final address = location['address'] ?? 'Unknown location';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getFoodColor(entry['foodName']),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.restaurant, color: Colors.white),
        ),
        title: Text(
          entry['foodName']?.toString() ?? 'Unknown Food',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(address),
            const SizedBox(height: 4),
            Text(
              '${entry['calories']?.toStringAsFixed(0) ?? 'N/A'} cal • ${_formatDate(entry['timestamp'])}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.location_pin, color: Colors.red, size: 20),
            Text(
              '${latitude.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 10),
            ),
            Text(
              '${longitude.toStringAsFixed(4)}',
              style: const TextStyle(fontSize: 10),
            ),
          ],
        ),
        onTap: () {
          _showFoodDetails(entry);
        },
      ),
    );
  }

  void _showFoodDetails(Map<String, dynamic> entry) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(entry['foodName']?.toString() ?? 'Food Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (entry['location'] != null) ...[
                _buildDetailRow('📍 Location', entry['location']['address'] ?? 'Unknown'),
                _buildDetailRow('🌐 Coordinates', 
                  '${entry['location']['latitude']?.toStringAsFixed(6)}, ${entry['location']['longitude']?.toStringAsFixed(6)}'),
              ],
              _buildDetailRow('🔥 Calories', '${entry['calories']?.toStringAsFixed(0) ?? 'N/A'}'),
              _buildDetailRow('💪 Protein', '${entry['protein']?.toStringAsFixed(1) ?? 'N/A'}g'),
              _buildDetailRow('🍚 Carbs', '${entry['carbs']?.toStringAsFixed(1) ?? 'N/A'}g'),
              _buildDetailRow('🥑 Fat', '${entry['fat']?.toStringAsFixed(1) ?? 'N/A'}g'),
              _buildDetailRow('📅 Date', _formatDate(entry['timestamp'])),
              _buildDetailRow('🔍 Source', entry['source']?.toString() ?? 'Unknown'),
              _buildDetailRow('🎯 Confidence', '${((entry['confidenceScore'] ?? 0) * 100).toStringAsFixed(0)}%'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Color _getFoodColor(String? foodName) {
    final colors = [
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.red,
      Colors.teal,
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
      // Simple extraction - you might want to enhance this
      if (address.contains(',')) {
        return address.split(',').last.trim();
      }
      return address;
    }).where((country) => country.isNotEmpty).toSet().toList();
    
    return countries;
  }
}