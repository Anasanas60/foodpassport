import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/gamification_service.dart';

class PassportStampsScreen extends StatefulWidget {
  const PassportStampsScreen({super.key});

  @override
  State<PassportStampsScreen> createState() => _PassportStampsScreenState();
}

class _PassportStampsScreenState extends State<PassportStampsScreen> {
  @override
  Widget build(BuildContext context) {
    final gamification = Provider.of<GamificationService>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Culinary Passport'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Passport Overview Section
            _buildPassportOverview(colorScheme),
            
            const SizedBox(height: 24),
            
            // Achievements Section
            _buildAchievementsSection(gamification, colorScheme),
            
            const SizedBox(height: 24),
            
            // Journal Entries Snapshot
            _buildJournalSnapshot(colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildPassportOverview(ColorScheme colorScheme) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header with Icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withAlpha(25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.airplane_ticket, size: 24, color: colorScheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Passport Overview',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Your culinary journey around the world',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Countries Progress with Visual Map
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Countries Stamped:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF333333),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Explore 12 countries to complete your passport!',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '5/12',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress Bar with Gradient
            Container(
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: 5/12,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primary, const Color(0xFFFF8A80)], // FIXED: Replaced primaryVariant
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Mini World Map Visualization
            _buildWorldMapVisualization(colorScheme), // FIXED: Added colorScheme parameter
          ],
        ),
      ),
    );
  }

  Widget _buildWorldMapVisualization(ColorScheme colorScheme) { // FIXED: Added colorScheme parameter
    final List<Map<String, dynamic>> exploredCountries = [
      {'code': '🇮🇹', 'name': 'Italy', 'explored': true},
      {'code': '🇯🇵', 'name': 'Japan', 'explored': true},
      {'code': '🇫🇷', 'name': 'France', 'explored': true},
      {'code': '🇹🇭', 'name': 'Thailand', 'explored': true},
      {'code': '🇲🇽', 'name': 'Mexico', 'explored': true},
      {'code': '🇨🇳', 'name': 'China', 'explored': false},
      {'code': '🇮🇳', 'name': 'India', 'explored': false},
      {'code': '🇪🇸', 'name': 'Spain', 'explored': false},
      {'code': '🇬🇷', 'name': 'Greece', 'explored': false},
      {'code': '🇹🇷', 'name': 'Turkey', 'explored': false},
      {'code': '🇻🇳', 'name': 'Vietnam', 'explored': false},
      {'code': '🇰🇷', 'name': 'Korea', 'explored': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Explored Regions:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: exploredCountries.map((country) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: country['explored'] ? colorScheme.primary.withAlpha(25) : Colors.grey[100], // FIXED: colorScheme available
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: country['explored'] ? colorScheme.primary : Colors.grey[300]!, // FIXED: colorScheme available
                width: country['explored'] ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  country['code'],
                  style: TextStyle(
                    fontSize: 16,
                    color: country['explored'] ? colorScheme.primary : Colors.grey[500], // FIXED: colorScheme available
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  country['name'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: country['explored'] ? const Color(0xFF333333) : Colors.grey[600],
                  ),
                ),
                if (country['explored']) ...[
                  const SizedBox(width: 4),
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.primary, // FIXED: colorScheme available
                    size: 12,
                  ),
                ],
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildAchievementsSection(GamificationService gamification, ColorScheme colorScheme) {
    final List<Map<String, dynamic>> achievements = [
      {
        'title': 'Street Food Pro',
        'icon': Icons.food_bank,
        'description': 'Try 10 different street foods',
        'completed': true,
        'progress': 1.0,
        'color': colorScheme.primary,
        'xp': 50,
      },
      {
        'title': 'Menu Master',
        'icon': Icons.menu_book,
        'description': 'Translate 25 menu items',
        'completed': false,
        'progress': 0.6,
        'color': colorScheme.secondary,
        'xp': 75,
      },
      {
        'title': 'Allergy Aware',
        'icon': Icons.shield,
        'description': 'Successfully avoid allergens 50 times',
        'completed': true,
        'progress': 1.0,
        'color': const Color(0xFFFFA000), // Amber
        'xp': 100,
      },
      {
        'title': 'Regional Explorer: Italy',
        'icon': Icons.flag,
        'description': 'Discover 15 Italian dishes',
        'completed': true,
        'progress': 1.0,
        'color': const Color(0xFF4CAF50), // Green
        'xp': 150,
      },
      {
        'title': 'Spice Adventurer',
        'icon': Icons.local_fire_department,
        'description': 'Try 20 spicy dishes',
        'completed': false,
        'progress': 0.3,
        'color': const Color(0xFFFF5722), // Deep Orange
        'xp': 80,
      },
      {
        'title': 'Dessert Lover',
        'icon': Icons.cake,
        'description': 'Identify 30 different desserts',
        'completed': false,
        'progress': 0.8,
        'color': const Color(0xFFE91E63), // Pink
        'xp': 60,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Achievements',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Complete challenges to earn badges and XP',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.85,
          ),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            final isCompleted = achievement['completed'] as bool;
            
            return _buildAchievementBadge(
              title: achievement['title'],
              icon: achievement['icon'],
              description: achievement['description'],
              isCompleted: isCompleted,
              progress: achievement['progress'] as double,
              color: achievement['color'] as Color,
              xp: achievement['xp'] as int,
              colorScheme: colorScheme, // FIXED: Added colorScheme parameter
            );
          },
        ),
      ],
    );
  }

  Widget _buildAchievementBadge({
    required String title,
    required IconData icon,
    required String description,
    required bool isCompleted,
    required double progress,
    required Color color,
    required int xp,
    required ColorScheme colorScheme, // FIXED: Added required parameter
  }) {
    return Card(
      elevation: isCompleted ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isCompleted ? color.withAlpha(20) : Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Badge Icon with Status
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: isCompleted ? color : Colors.grey[400],
                    shape: BoxShape.circle,
                    boxShadow: isCompleted ? [
                      BoxShadow(
                        color: color.withAlpha(100),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ] : null,
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                if (isCompleted)
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.verified,
                        color: color,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Title
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isCompleted ? const Color(0xFF333333) : Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 4),
            
            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isCompleted ? Colors.grey[600] : Colors.grey[500],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            
            const SizedBox(height: 8),
            
            // XP Reward
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+$xp XP',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Progress or Checkmark
            if (isCompleted)
              Icon(
                Icons.check_circle,
                color: color,
                size: 20,
              )
            else
              Column(
                children: [
                  // Progress Text
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Progress Bar
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [color, Color.lerp(color, Colors.black, 0.2)!], // FIXED: Replaced withAlpha
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildJournalSnapshot(ColorScheme colorScheme) {
    final List<Map<String, dynamic>> recentEntries = [
      {
        'dish': 'Margherita Pizza',
        'date': '2 hours ago',
        'country': 'Italy',
        'image': 'https://images.unsplash.com/photo-1604068549290-dea0e4a305ca?w=150',
      },
      {
        'dish': 'Sushi Platter',
        'date': '1 day ago',
        'country': 'Japan',
        'image': 'https://images.unsplash.com/photo-1579584425555-c3ce17fd4351?w=150',
      },
      {
        'dish': 'Croissant',
        'date': '2 days ago',
        'country': 'France',
        'image': 'https://images.unsplash.com/photo-1555507032-40b1cf5a7c2c?w=150',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Journal Entries',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full journal
              },
              style: TextButton.styleFrom(
                foregroundColor: colorScheme.primary,
              ),
              child: const Text(
                'View All',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        ...recentEntries.map((entry) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Food Image
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(entry['image']),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry['dish'],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${entry['country']} • ${entry['date']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
              ),
            ],
          ),
        )),
      ],
    );
  }
}