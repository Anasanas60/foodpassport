import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/passport_stamp.dart';
import '../models/user_achievements.dart';
import '../services/achievement_service.dart';
import '../services/food_state_service.dart';
import 'animations/shimmer_loading.dart';

class PassportStampsScreen extends StatefulWidget {
  const PassportStampsScreen({super.key});

  @override
  State<PassportStampsScreen> createState() => _PassportStampsScreenState();
}

class _PassportStampsScreenState extends State<PassportStampsScreen> {
  List<PassportStamp> _earnedStamps = [];
  UserAchievements _userStats = UserAchievements.initial();
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

      // Simulate loading delay
      await Future.delayed(const Duration(milliseconds: 800));
      
      // In a real app, you'd load from database
      // For now, we'll use mock data that simulates achievements
      _loadMockAchievements();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _loadMockAchievements() {
    // Mock earned stamps based on user activity
    final foodState = Provider.of<FoodStateService>(context, listen: false);
    final foodHistory = foodState.foodHistory;
    
    // Calculate mock stats based on actual food history
    final uniqueFoods = foodHistory.map((f) => f.name).toSet().length;
    final totalCalories = foodHistory.fold(0.0, (sum, f) => sum + f.calories).round();
    final uniqueCuisines = foodHistory.where((f) => f.area != null).map((f) => f.area!).toSet().length;
    
    _userStats = UserAchievements(
      totalPoints: uniqueFoods * 10 + totalCalories ~/ 100,
      level: _calculateLevel(uniqueFoods * 10 + totalCalories ~/ 100),
      foodsDiscovered: uniqueFoods,
      cuisinesTried: uniqueCuisines,
      totalCalories: totalCalories,
      currentStreak: 3, // Mock streak
      bestStreak: 7,
      lastActivity: DateTime.now(),
      cuisineCounts: {},
      achievementProgress: {},
    );

    // Mock earned stamps based on progress
    _earnedStamps = [];
    
    if (uniqueFoods >= 1) {
      _earnedStamps.add(PassportStamp(
        id: 'first_food',
        title: 'First Discovery!',
        description: 'Scan your first food item',
        type: StampType.milestone,
        category: StampCategory.beginner,
        points: 50,
        earnedDate: DateTime.now().subtract(const Duration(days: 5)),
        icon: '🆕',
        color: Colors.blue,
      ));
    }
    
    if (uniqueFoods >= 5) {
      _earnedStamps.add(PassportStamp(
        id: 'food_explorer',
        title: 'Food Explorer',
        description: 'Discover 5 different foods',
        type: StampType.milestone,
        category: StampCategory.beginner,
        points: 100,
        earnedDate: DateTime.now().subtract(const Duration(days: 2)),
        icon: '🔍',
        color: Colors.green,
      ));
    }
    
    if (totalCalories >= 1000) {
      _earnedStamps.add(PassportStamp(
        id: 'calorie_counter',
        title: 'Calorie Counter',
        description: 'Log 1,000 total calories',
        type: StampType.nutrition,
        category: StampCategory.beginner,
        points: 80,
        earnedDate: DateTime.now().subtract(const Duration(days: 1)),
        icon: '🔥',
        color: Colors.orange,
      ));
    }
  }

  int _calculateLevel(int points) {
    const thresholds = [0, 100, 300, 600, 1000, 1500];
    for (int i = thresholds.length - 1; i >= 0; i--) {
      if (points >= thresholds[i]) return i + 1;
    }
    return 1;
  }

  List<PassportStamp> get _availableStamps {
    final earnedIds = _earnedStamps.map((s) => s.id).toSet();
    return AchievementService._allStamps
        .where((stamp) => !earnedIds.contains(stamp.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.airplane_ticket, color: Color(0xFFffd700)),
            SizedBox(width: 12),
            Text('Food Passport 🛂'),
          ],
        ),
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: _isLoading ? _buildLoadingState(theme) : _buildContent(theme),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        child: const Icon(Icons.refresh),
        tooltip: 'Refresh Passport',
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFF8B4513),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.airplane_ticket, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(color: Color(0xFF8B4513)),
          const SizedBox(height: 20),
          Text(
            'Loading your culinary passport...',
            style: TextStyle(fontSize: 16, color: theme.colorScheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _loadData,
      backgroundColor: const Color(0xFF8B4513),
      color: Colors.white,
      child: CustomScrollView(
        slivers: [
          _buildPassportHeader(theme),
          _buildLevelProgressSection(theme),
          _buildEarnedStampsSection(theme),
          _buildAvailableStampsSection(theme),
          _buildStatisticsSection(theme),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildPassportHeader(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8B4513), Color(0xFFA0522D)],
          ),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Level Badge
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lv${_userStats.level}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _userStats.levelTitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(_earnedStamps.length.toString(), 'Stamps', Icons.star),
                  _buildStatItem(_userStats.foodsDiscovered.toString(), 'Foods', Icons.restaurant),
                  _buildStatItem(_userStats.totalPoints.toString(), 'Points', Icons.emoji_events),
                  _buildStatItem('${_userStats.currentStreak}d', 'Streak', Icons.local_fire_department),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(40),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.white, size: 20),
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
          style: const TextStyle(fontSize: 10, color: Colors.white70),
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildLevelProgressSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF8B4513), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: Color(0xFF8B4513)),
                    const SizedBox(width: 8),
                    Text(
                      'LEVEL PROGRESS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  value: _userStats.levelProgress,
                  backgroundColor: Colors.grey[300],
                  color: const Color(0xFF8B4513),
                  borderRadius: BorderRadius.circular(10),
                  minHeight: 12,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Lv${_userStats.level} ${_userStats.levelTitle}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${_userStats.pointsToNextLevel} pts to next level',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
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

  SliverToBoxAdapter _buildEarnedStampsSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('🏆 EARNED STAMPS', const Color(0xFF2e7d32)),
            const SizedBox(height: 16),
            Text(
              '${_earnedStamps.length} stamps collected • ${_earnedStamps.fold(0, (sum, stamp) => sum + stamp.points)} total points',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            _earnedStamps.isEmpty
                ? _buildEmptyState('No stamps earned yet!\nStart scanning foods to earn your first stamps!')
                : _buildStampsGrid(_earnedStamps, true, theme),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildAvailableStampsSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('🎯 AVAILABLE STAMPS', const Color(0xFF8b0000)),
            const SizedBox(height: 16),
            Text(
              '${_availableStamps.length} stamps to unlock • Keep exploring!',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            _availableStamps.isEmpty
                ? _buildEmptyState('All stamps earned! 🎉\nYou are a true culinary master!')
                : _buildStampsGrid(_availableStamps, false, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFffd700)),
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildStampsGrid(List<PassportStamp> stamps, bool isEarned, ThemeData theme) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: stamps.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) => _buildStampCard(stamps[index], isEarned, theme),
    );
  }

  Widget _buildStampCard(PassportStamp stamp, bool isEarned, ThemeData theme) {
    return Card(
      elevation: isEarned ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isEarned ? stamp.color : Colors.grey.shade300,
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
                  colors: [stamp.color, _darkenColor(stamp.color, 0.2)],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[100]!, Colors.grey[200]!],
                ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Stamp Icon
              Text(
                stamp.icon,
                style: const TextStyle(fontSize: 32),
              ),
              const SizedBox(height: 8),
              
              // Stamp Title
              Text(
                stamp.title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isEarned ? Colors.white : Colors.grey[800],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
              const SizedBox(height: 4),
              
              // Points Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isEarned ? Colors.white.withAlpha(40) : Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${stamp.points} pts',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isEarned ? Colors.white : Colors.grey[700],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isEarned ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isEarned ? 'EARNED' : 'LOCKED',
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              
              // Earned Date
              if (isEarned) ...[
                const SizedBox(height: 4),
                Text(
                  stamp.formattedDate,
                  style: TextStyle(
                    color: Colors.white70,
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

  SliverToBoxAdapter _buildStatisticsSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF8B4513), width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.analytics, color: Color(0xFF8B4513)),
                    SizedBox(width: 8),
                    Text(
                      'CULINARY STATISTICS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B4513),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildStatRow('Total Foods Discovered', _userStats.foodsDiscovered.toString(), Icons.restaurant),
                _buildStatRow('Unique Cuisines Tried', _userStats.cuisinesTried.toString(), Icons.public),
                _buildStatRow('Total Calories Logged', '${_userStats.totalCalories} cal', Icons.bolt),
                _buildStatRow('Current Streak', '${_userStats.currentStreak} days', Icons.local_fire_department),
                _buildStatRow('Best Streak', '${_userStats.bestStreak} days', Icons.emoji_events),
                _buildStatRow('Total Points', _userStats.totalPoints.toString(), Icons.workspace_premium),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF8B4513)),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF8B4513), width: 2),
            ),
            child: const Icon(Icons.auto_awesome, size: 40, color: Color(0xFF8B4513)),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Color _darkenColor(Color color, double factor) {
    return Color.fromARGB(
      color.alpha,
      (color.red * (1 - factor)).round(),
      (color.green * (1 - factor)).round(),
      (color.blue * (1 - factor)).round(),
    );
  }
}