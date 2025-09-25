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
      backgroundColor: const Color(0xFFf8f5f0),
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.airplane_ticket, color: Color(0xFFffd700)),
            SizedBox(width: 12),
            Text('Travel Visa Stamps 🛂'),
          ],
        ),
        backgroundColor: const Color(0xFF1a237e),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: _isLoading 
          ? _buildLoadingState()
          : _buildContent(),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        backgroundColor: const Color(0xFF1a237e),
        foregroundColor: const Color(0xFFffd700),
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh Stamps',
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFF1a237e),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFffd700), width: 2),
            ),
            child: const Icon(Icons.airplane_ticket, color: Colors.white, size: 30),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading your travel achievements...',
            style: TextStyle(fontSize: 16, color: Color(0xFF1a237e)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _loadData,
      backgroundColor: const Color(0xFF1a237e),
      color: const Color(0xFFffd700),
      child: CustomScrollView(
        slivers: [
          _buildPassportHeader(),
          _buildVisaStampsSection(),
          _buildAvailableVisasSection(),
          _buildTravelProgressSection(),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildPassportHeader() {
    final totalFoods = _foodEntries.length;
    final earnedStamps = _stamps.length;
    final totalCalories = _userStats?['total_calories'] ?? 0;
    final currentStreak = _userStats?['current_streak'] ?? 0;

    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1a237e), Color(0xFF283593)],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0x1AFFFFFF), // Replaced withOpacity(0.1)
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFffd700), width: 2),
                ),
                child: const Icon(Icons.airplane_ticket, size: 40, color: Colors.white),
              ),
              const SizedBox(height: 16),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTravelStatItem(
                    _isLoading ? '0' : earnedStamps.toString(), 
                    'Visas Collected', 
                    Icons.airplane_ticket
                  ),
                  _buildTravelStatItem(
                    _isLoading ? '0' : totalFoods.toString(), 
                    'Culinary Stops', 
                    Icons.restaurant
                  ),
                  _buildTravelStatItem(
                    _isLoading ? '0' : currentStreak.toString(), 
                    'Travel Days', 
                    Icons.local_fire_department
                  ),
                  _buildTravelStatItem(
                    _isLoading ? '0' : totalCalories.toStringAsFixed(0), 
                    'Calories', 
                    Icons.bolt
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTravelStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0x33FFFFFF), // Replaced withOpacity(0.2)
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFffd700), size: 20),
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.white70)),
      ],
    );
  }

  SliverToBoxAdapter _buildVisaStampsSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1a237e),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFffd700)),
                  ),
                  child: const Text(
                    '🛂 COLLECTED VISAS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _isLoading ? 'Loading travel achievements...' : '${_stamps.length} visas in your passport',
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 20),
            _isLoading ? _buildShimmerStampsGrid(true) : _buildVisaStampsGrid(_stamps, true),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildAvailableVisasSection() {
    final availableAchievements = _getAvailableAchievements();

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8b0000),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFffd700)),
                  ),
                  child: const Text(
                    '🎯 NEXT DESTINATIONS',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _isLoading ? 'Checking travel progress...' : '${availableAchievements.length} visas to unlock',
              style: const TextStyle(fontSize: 14, color: Color(0xFF666666)),
            ),
            const SizedBox(height: 20),
            _isLoading ? _buildShimmerStampsGrid(false) : _buildVisaStampsGrid(availableAchievements, false),
          ],
        ),
      ),
    );
  }

  Widget _buildVisaStampsGrid(List<Map<String, dynamic>> stamps, bool isEarned) {
    if (stamps.isEmpty) {
      return _buildEmptyPassportState(
        isEarned 
          ? 'No visas collected yet!\nStart your culinary journey to earn your first stamp.'
          : 'All destinations visited!\nYou are a Culinary Explorer! 🎉'
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: stamps.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => _buildVisaStampCard(stamps[index], isEarned),
    );
  }

  Widget _buildShimmerStampsGrid(bool isEarned) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
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

  SliverToBoxAdapter _buildTravelProgressSection() {
    return SliverToBoxAdapter(
      child: ShimmerLoading(
        isLoading: _isLoading,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: const BorderSide(color: Color(0xFFffd700), width: 1),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.travel_explore, color: Color(0xFF1a237e)),
                        SizedBox(width: 8),
                        Text(
                          'TRAVEL PROGRESS PASSPORT',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1a237e),
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildProgressItem('Culinary Variety', _getUniqueFoodsCount(), 10, Icons.restaurant),
                    _buildProgressItem('Calorie Journey', _userStats?['total_calories']?.toInt() ?? 0, 5000, Icons.bolt),
                    _buildProgressItem('Travel Streak', _userStats?['current_streak'] ?? 0, 7, Icons.local_fire_department),
                    _buildProgressItem('Expedition Record', _userStats?['best_streak'] ?? 0, 30, Icons.emoji_events),
                  ],
                ),
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
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF1a237e)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              ),
              Text('$current/$target', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: Colors.grey[300],
            color: percentage >= 1.0 ? Colors.green : const Color(0xFF1a237e),
            borderRadius: BorderRadius.circular(10),
          ),
        ],
      ),
    );
  }

  Widget _buildVisaStampCard(Map<String, dynamic> stamp, bool isEarned) {
    final stampColor = _getStampColor(stamp['category']);
    
    return Card(
      elevation: isEarned ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isEarned ? stampColor : Colors.grey.shade300,
          width: isEarned ? 2 : 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isEarned 
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [stampColor, _darkenColor(stampColor, 0.2)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFf5f5f5), Color(0xFFfafafa)],
                ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isEarned ? Colors.white : const Color(0xFFe0e0e0),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isEarned ? stampColor : const Color(0xFFbdbdbd),
                    width: 2,
                  ),
                ),
                child: Icon(
                  _getStampIcon(stamp['type'] ?? stamp['stamp_type']),
                  size: 24,
                  color: isEarned ? stampColor : const Color(0xFF757575),
                ),
              ),
              const SizedBox(height: 8),
              
              Text(
                stamp['title']?.toString() ?? 'Unknown Visa',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isEarned ? Colors.white : const Color(0xFF424242),
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isEarned ? const Color(0x33FFFFFF) : const Color(0xFFe0e0e0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isEarned ? 'APPROVED' : 'PENDING',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: isEarned ? Colors.white : const Color(0xFF616161),
                    letterSpacing: 1,
                  ),
                ),
              ),
              
              if (isEarned && stamp['earned_date'] != null) ...[
                const SizedBox(height: 4),
                Text(
                  _formatDate(DateTime.fromMillisecondsSinceEpoch(stamp['earned_date'])),
                  style: const TextStyle(
                    color: Color(0xCCFFFFFF), // 80% opacity white
                    fontSize: 8,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPassportState(String message) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFf8f5f0),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFffd700), width: 2),
            ),
            child: const Icon(Icons.airplane_ticket, size: 40, color: Color(0xFF1a237e)),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF666666), fontSize: 14),
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
        'title': 'Thai Cuisine Visa',
        'description': 'Try 10 different Thai dishes',
        'category': 'cuisine',
      },
      {
        'type': 'calorie_master',
        'title': 'Calorie Expedition',
        'description': 'Log 5,000 total calories',
        'category': 'health',
      },
      {
        'type': 'world_traveler',
        'title': 'Global Food Visa',
        'description': 'Foods from 3 different countries',
        'category': 'travel',
      },
      {
        'type': 'streak_champion',
        'title': '7-Day Travel Visa',
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
      'milestone': Color(0xFF1a237e),
      'variety': Color(0xFF2e7d32),
      'cuisine': Color(0xFF8b0000),
      'health': Color(0xFFff6f00),
      'travel': Color(0xFF4a148c),
      'consistency': Color(0xFF00695c),
    };
    return colors[category] ?? Color(0xFF1a237e);
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