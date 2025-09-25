import 'package:flutter/material.dart';
import 'services/food_journal_service.dart'; // Import the correct service
import 'animations/shimmer_loading.dart';

// REMOVED the duplicate FoodJournalService class - it's now imported from services/

class FoodJournalScreen extends StatefulWidget {
  const FoodJournalScreen({super.key});

  @override
  State<FoodJournalScreen> createState() => _FoodJournalScreenState();
}

class _FoodJournalScreenState extends State<FoodJournalScreen> {
  final FoodJournalService _journalService = FoodJournalService(); // Now uses the correct service
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
      
      setState(() {
        _foodEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load food entries: $e';
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
        title: const Text('My Food Passport 🛂'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Collected Stamps', 
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
            ),
            const SizedBox(height: 10),
            
            // Statistics summary with shimmer
            _buildStatisticsSummary(),
            const SizedBox(height: 20),
            
            // Content area with shimmer
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh Food Journal',
      ),
    );
  }

  Widget _buildStatisticsSummary() {
    return ShimmerLoading(
      isLoading: _isLoading,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    _isLoading ? '0' : _foodEntries.length.toString(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text('Foods Tried'),
                ],
              ),
              Column(
                children: [
                  Text(
                    _isLoading ? '0' : _calculateTotalCalories().toStringAsFixed(0),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text('Total Calories'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return _buildShimmerLoadingGrid();
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage, style: const TextStyle(color: Colors.red)),
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
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.restaurant_menu, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No food entries yet!\nScan some food to start your journey.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: _foodEntries.length,
        itemBuilder: (context, index) {
          final entry = _foodEntries[index];
          return _buildFoodStampCard(entry);
        },
      ),
    );
  }

  // NEW: Beautiful shimmer loading grid
  Widget _buildShimmerLoadingGrid() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: 6, // Show 6 shimmer cards
      itemBuilder: (context, index) {
        return ShimmerLoading(
          isLoading: true,
          child: Card(
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey[300],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFoodStampCard(Map<String, dynamic> entry) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Food image or icon
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: _getFoodColor(entry['foodName']),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.restaurant, size: 30, color: Colors.white),
                  const SizedBox(height: 4),
                  Text(
                    '${entry['calories']?.toStringAsFixed(0) ?? '0'} cal',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          
          // Food details
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['foodName']?.toString() ?? 'Unknown Food',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (entry['location'] != null && entry['location']['address'] != null)
                  Text(
                    entry['location']['address'].toString(),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                Text(
                  _formatDate(entry['timestamp']),
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${entry['confidenceScore']?.toStringAsFixed(1) ?? '0.0'}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
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

  double _calculateTotalCalories() {
    return _foodEntries.fold(0.0, (sum, entry) {
      return sum + (entry['calories'] ?? 0.0);
    });
  }
}