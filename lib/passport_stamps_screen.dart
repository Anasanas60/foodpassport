import 'package:flutter/material.dart';
import 'services/food_journal_service.dart';
import 'services/database_service.dart';
import 'animations/shimmer_loading.dart';

class PassportStampsScreen extends StatefulWidget {
  const PassportStampsScreen({super.key});

  @override
  State<PassportStampsScreen> createState() => _PassportStampsScreenState();
}

class _PassportStampsScreenState extends State<PassportStampsScreen> {
  final FoodJournalService _journalService = FoodJournalService();
  final DatabaseService _dbService = DatabaseService();
  List<Map<String, dynamic>> _stamps = [];
  List<Map<String, dynamic>> _foodEntries = [];
  Map<String, dynamic>? _userStats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Use DatabaseService directly since FoodJournalService doesn't have these methods
      final stamps = await _dbService.getPassportStamps();
      final entries = await _journalService.getFoodEntries();
      final stats = await _dbService.getUserStats();

      setState(() {
        _stamps = stamps;
        _foodEntries = entries;
        _userStats = stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Passport Stamps 🛂'),
        backgroundColor: Colors.amber[700],
        elevation: 0,
      ),
      body: _isLoading 
          ? _buildLoadingState()
          : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh Stamps',
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading your passport achievements...'),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: CustomScrollView(
        slivers: [
          // Header with statistics - WITH SHIMMER
          _buildStatsHeader(),
          
          // Earned Stamps Section - WITH SHIMMER
          _buildEarnedStampsSection(),
          
          // Available Achievements Section - WITH SHIMMER
          _buildAvailableAchievementsSection(),
          
          // Progress Section - WITH SHIMMER
          _buildProgressSection(),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildStatsHeader() {
    final totalFoods = _foodEntries.length;
    final earnedStamps = _stamps.length;
    final totalCalories = _userStats?['total_calories'] ?? 0;
    final currentStreak = _userStats?['current_streak'] ?? 0;

    return SliverToBoxAdapter(
      child: ShimmerLoading(
        isLoading: _isLoading,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.amber[700]!, Colors.orange[700]!],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Passport Icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.airplane_ticket, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 16),
                
                // Stats Grid
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      _isLoading ? '0' : earnedStamps.toString(), 
                      'Stamps Earned', 
                      Icons.star
                    ),
                    _buildStatItem(
                      _isLoading ? '0' : totalFoods.toString(), 
                      'Foods Tried', 
                      Icons.restaurant
                    ),
                    _buildStatItem(
                      _isLoading ? '0' : currentStreak.toString(), 
                      'Day Streak', 
                      Icons.local_fire_department
                    ),
                    _buildStatItem(
                      _isLoading ? '0' : totalCalories.toStringAsFixed(0), 
                      'Total Calories', 
                      Icons.bolt
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

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  SliverToBoxAdapter _buildEarnedStampsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🏆 Earned Stamps',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _isLoading ? 'Loading achievements...' : '${_stamps.length} achievements unlocked',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            // Earned stamps grid WITH SHIMMER
            _isLoading ? _buildShimmerStampsGrid(true) : _buildStampsGrid(_stamps, true),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildAvailableAchievementsSection() {
    final availableAchievements = _getAvailableAchievements();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 Next Achievements',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _isLoading ? 'Checking progress...' : '${availableAchievements.length} achievements to unlock',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            // Available achievements grid WITH SHIMMER
            _isLoading ? _buildShimmerStampsGrid(false) : _buildStampsGrid(availableAchievements, false),
          ],
        ),
      ),
    );
  }

  Widget _buildStampsGrid(List<Map<String, dynamic>> stamps, bool isEarned) {
    if (stamps.isEmpty) {
      return _buildEmptyState(
        isEarned 
          ? 'No stamps earned yet!\nStart scanning food to earn your first stamp.'
          : 'All achievements unlocked!\nYou are a Food Passport Master! 🎉'
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: stamps.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => _buildStampCard(stamps[index], isEarned),
    );
  }

  // NEW: Shimmer loading grid for stamps
  Widget _buildShimmerStampsGrid(bool isEarned) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.9,
      ),
      itemCount: 4, // Show 4 shimmer stamp cards
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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

  SliverToBoxAdapter _buildProgressSection() {
    return SliverToBoxAdapter(
      child: ShimmerLoading(
        isLoading: _isLoading,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '📈 Your Progress',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildProgressItem('Food Variety', _getUniqueFoodsCount(), 10, Icons.restaurant),
                  _buildProgressItem('Total Calories', _userStats?['total_calories']?.toInt() ?? 0, 5000, Icons.bolt),
                  _buildProgressItem('Current Streak', _userStats?['current_streak'] ?? 0, 7, Icons.local_fire_department),
                  _buildProgressItem('Best Streak', _userStats?['best_streak'] ?? 0, 30, Icons.emoji_events),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressItem(String label, int current, int target, IconData icon) {
    final percentage = target > 0 ? (current / target).clamp(0.0, 1.0) : 0.0;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.amber[700]),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              const Spacer(),
              Text('$current/$target', style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            color: percentage >= 1.0 ? Colors.green : Colors.amber[700],
          ),
        ],
      ),
    );
  }

  Widget _buildStampCard(Map<String, dynamic> stamp, bool isEarned) {
    final stampColor = _getStampColor(stamp['category']);
    
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isEarned ? stampColor : Colors.grey[100],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Stamp Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isEarned ? Colors.white : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStampIcon(stamp['type'] ?? stamp['stamp_type']),
                size: 30,
                color: isEarned ? stampColor : Colors.grey[500],
              ),
            ),
            const SizedBox(height: 8),
            
            // Title
            Text(
              stamp['title']?.toString() ?? 'Unknown',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isEarned ? Colors.white : Colors.grey[700],
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
            
            // Description or Locked status
            if (isEarned) ...[
              const SizedBox(height: 4),
              Text(
                stamp['description']?.toString() ?? '',
                style: TextStyle(
                  color: isEarned 
                      ? Color.alphaBlend(Colors.white.withAlpha(204), stampColor) // 80% opacity equivalent
                      : Colors.grey[600]!,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ] else ...[
              const SizedBox(height: 4),
              Text(
                'Locked',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            
            // Earned Date
            if (isEarned && stamp['earned_date'] != null) ...[
              const SizedBox(height: 4),
              Text(
                _formatDate(DateTime.fromMillisecondsSinceEpoch(stamp['earned_date'])),
                style: TextStyle(
                  color: isEarned 
                      ? Color.alphaBlend(Colors.white.withAlpha(153), stampColor) // 60% opacity equivalent
                      : Colors.grey[600]!,
                  fontSize: 9,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Icon(Icons.emoji_events, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 16),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAvailableAchievements() {
    final earnedTypes = _stamps.map((s) => s['stamp_type']).toSet();
    
    return [
      {
        'type': 'thai_expert',
        'title': 'Thai Food Expert',
        'description': 'Try 10 different Thai dishes',
        'category': 'cuisine',
      },
      {
        'type': 'calorie_master',
        'title': 'Calorie Master',
        'description': 'Log 5,000 total calories',
        'category': 'health',
      },
      {
        'type': 'world_traveler',
        'title': 'World Traveler',
        'description': 'Foods from 3 different countries',
        'category': 'travel',
      },
      {
        'type': 'streak_champion',
        'title': 'Streak Champion',
        'description': '7-day logging streak',
        'category': 'consistency',
      },
    ].where((achievement) => !earnedTypes.contains(achievement['type'])).toList();
  }

  int _getUniqueFoodsCount() {
    return _foodEntries.map((e) => e['foodName'].toString().toLowerCase()).toSet().length;
  }

  Color _getStampColor(String? category) {
    final colors = {
      'milestone': Colors.blue,
      'variety': Colors.green,
      'cuisine': Colors.orange,
      'health': Colors.red,
      'travel': Colors.purple,
      'consistency': Colors.teal,
    };
    return colors[category] ?? Colors.amber;
  }

  IconData _getStampIcon(String? type) {
    final icons = {
      'first_food': Icons.restaurant,
      'food_explorer': Icons.explore,
      'thai_expert': Icons.spa,
      'calorie_master': Icons.bolt,
      'world_traveler': Icons.public,
      'streak_champion': Icons.local_fire_department,
    };
    return icons[type] ?? Icons.star;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}