import 'package:flutter/material.dart';
import 'services/food_journal_service.dart';
import 'animations/shimmer_loading.dart';

class FoodJournalScreen extends StatefulWidget {
  const FoodJournalScreen({super.key});

  @override
  State<FoodJournalScreen> createState() => _FoodJournalScreenState();
}

class _FoodJournalScreenState extends State<FoodJournalScreen> {
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

      setState(() {
        _foodEntries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load travel diary: $e';
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
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.travel_explore, color: Color(0xFFffd700)),
            SizedBox(width: 12),
            Text('Travel Food Diary 📖'),
          ],
        ),
        backgroundColor: theme.colorScheme.primaryContainer,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFFffd700)),
            onPressed: _refreshData,
            tooltip: 'Refresh Diary',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPassportHeader(theme),
            const SizedBox(height: 20),
            Expanded(
              child: _buildContent(theme),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.secondary,
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh Travel Diary',
      ),
    );
  }

  Widget _buildPassportHeader(ThemeData theme) {
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
              theme.colorScheme.primary,
              theme.colorScheme.primaryContainer
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
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: theme.colorScheme.secondary, width: 2),
                  ),
                  child: const Icon(Icons.book, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildTravelStat(
                      _isLoading ? '0' : _foodEntries.length.toString(),
                      'Culinary Stops',
                      Icons.location_on,
                      theme,
                    ),
                    _buildTravelStat(
                      _isLoading
                          ? '0'
                          : _calculateTotalCalories().toStringAsFixed(0),
                      'Calories Burned',
                      Icons.bolt,
                      theme,
                    ),
                    _buildTravelStat(
                      _isLoading ? '0' : _getUniqueCountries().length.toString(),
                      'Countries',
                      Icons.public,
                      theme,
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

  Widget _buildTravelStat(
      String value, String label, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: theme.colorScheme.secondary, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.8)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return _buildShimmerLoadingGrid();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorState();
    }

    if (_foodEntries.isEmpty) {
      return _buildEmptyDiaryState();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      backgroundColor: theme.colorScheme.primary,
      color: theme.colorScheme.secondary,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _foodEntries.length,
        itemBuilder: (context, index) {
          final entry = _foodEntries[index];
          return _buildTravelDiaryCard(entry);
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
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                  color: Theme.of(context).colorScheme.secondary, width: 2),
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
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.secondary),
            child: const Text('Retry Journey'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDiaryState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(
                  color: Theme.of(context).colorScheme.secondary, width: 3),
            ),
            child: const Icon(Icons.travel_explore,
                size: 50, color: Color(0xFF8b0000)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your Travel Diary is Empty!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF8b0000),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Start your culinary journey by scanning\nfood to collect travel memories!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/menuscan');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8b0000),
              foregroundColor: const Color(0xFFffd700),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt),
                SizedBox(width: 8),
                Text('Start Food Journey'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelDiaryCard(Map<String, dynamic> entry) {
    final foodColor = _getFoodColor(entry['foodName']);

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.secondary, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      const Icon(Icons.restaurant, size: 30, color: Colors.white),
                      const SizedBox(height: 4),
                      Text(
                        '${entry['calories']?.toStringAsFixed(0) ?? '0'} cal',
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
                    child: Icon(Icons.star, size: 16, color: foodColor),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry['foodName']?.toString() ?? 'Unknown Dish',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (entry['location'] != null &&
                      entry['location']['address'] != null)
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            entry['location']['address'].toString(),
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 10),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(entry['timestamp']),
                        style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Icon(Icons.verified, size: 12, color: foodColor),
                      const SizedBox(width: 4),
                      Text(
                        '${((entry['confidenceScore'] ?? 0) * 100).toStringAsFixed(0)}% confident',
                        style: TextStyle(
                            fontSize: 10,
                            color: foodColor,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
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

  Color _darkenColor(Color color, double factor) {
    assert(factor >= 0 && factor <= 1);
    return Color.fromARGB(
      color.alpha,
      (color.red * (1 - factor)).round(),
      (color.green * (1 - factor)).round(),
      (color.blue * (1 - factor)).round(),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  double _calculateTotalCalories() {
    return _foodEntries.fold(0.0, (sum, entry) {
      return sum + (entry['calories'] ?? 0.0);
    });
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
}