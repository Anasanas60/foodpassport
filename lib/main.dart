import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import FoodItem model with alias to avoid conflicts
import 'models/food_item.dart' as models;

import 'services/user_profile_service.dart';
import 'services/food_state_service.dart';

import 'user_form_screen.dart';
import 'camera_screen.dart';
import 'food_journal_screen.dart';
import 'recipe_screen.dart';
import 'cultural_insights_screen.dart';
import 'map_screen.dart';
import 'emergency_alert_screen.dart';
import 'preferences_screen.dart';
import 'passport_stamps_screen.dart';
import 'menu_scan_screen.dart';

void main() {
  runApp(const FoodPassportApp());
}

class FoodPassportApp extends StatelessWidget {
  const FoodPassportApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Color scheme from UI mission
    final Color coralOrange = const Color(0xFFFF6F61);
    final Color mintGreen = const Color(0xFF8BC34A);
    final Color lightBackground = const Color(0xFFF8F8F8);

    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: coralOrange,
      primary: coralOrange,
      secondary: mintGreen,
      surface: lightBackground,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      brightness: Brightness.light,
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProfileService()),
        ChangeNotifierProvider(create: (context) => FoodStateService()),
      ],
      child: MaterialApp(
        title: 'Food Passport',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: colorScheme.surface,
          appBarTheme: AppBarTheme(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: colorScheme.primary,
            unselectedItemColor: Colors.grey,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            displaySmall: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
            headlineSmall: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
            titleMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF333333),
            ),
            bodyMedium: TextStyle(
              fontSize: 14,
              color: Color(0xFF333333),
            ),
            labelLarge: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          cardTheme: CardThemeData(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            color: Colors.white,
            margin: EdgeInsets.zero,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: colorScheme.primary),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          iconTheme: IconThemeData(color: colorScheme.primary),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        home: const HomeScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/camera': (context) => const CameraScreen(),
          '/journal': (context) => const FoodJournalScreen(),
          '/recipe': (context) => const RecipeScreen(dishName: 'Recent Food'),
          '/culture': (context) => const CulturalInsightsScreen(dishName: 'Recent Food'),
          '/map': (context) => const MapScreen(),
          '/passport': (context) => const PassportStampsScreen(),
          '/menu-scan': (context) => const MenuScanScreen(),
          '/emergency': (context) {
            final foodState = Provider.of<FoodStateService>(context, listen: false);
            return EmergencyAlertScreen(
              foodItem: foodState.currentFoodItem ??
                  models.FoodItem.fromRecognitionMap(
                    {
                      'foodName': 'Emergency Food',
                      'calories': 0.0,
                      'protein': 0.0,
                      'carbs': 0.0,
                      'fat': 0.0,
                      'confidence': 0.0,
                      'detectedAllergens': [],
                      'source': 'emergency',
                    },
                    imagePath: '',
                  ),
            );
          },
          '/preferences': (context) => const PreferencesScreen(),
          '/profile-setup': (context) => const UserFormScreen(),
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int _carouselIndex = 0;

  // Enhanced carousel items with country flags
  final List<Map<String, dynamic>> _carouselItems = [
    {
      'image': 'https://images.unsplash.com/photo-1565299624946-b28f40a0ca4b?w=500',
      'title': 'Italian Pasta',
      'country': 'Italy',
      'flag': '🇮🇹',
    },
    {
      'image': 'https://images.unsplash.com/photo-1563612116625-3012372fccce?w=500',
      'title': 'Japanese Sushi',
      'country': 'Japan',
      'flag': '🇯🇵',
    },
    {
      'image': 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=500',
      'title': 'French Croissant',
      'country': 'France',
      'flag': '🇫🇷',
    },
    {
      'image': 'https://images.unsplash.com/photo-1563245372-f21724e3856d?w=500',
      'title': 'Mexican Tacos',
      'country': 'Mexico',
      'flag': '🇲🇽',
    },
    {
      'image': 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=500',
      'title': 'Indian Curry',
      'country': 'India',
      'flag': '🇮🇳',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final userProfileService = Provider.of<UserProfileService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              'foodpassport',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {
              // Handle notifications
              _showNotificationSheet(context);
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, colorScheme, userProfileService),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Your Culinary Journey Carousel
            _buildCulinaryJourneyCarousel(context),
            
            const SizedBox(height: 20),
            
            // Scan Menu Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/camera'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Scan Menu',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Quick Tools Section
            _buildQuickToolsSection(context),
            
            const SizedBox(height: 24),
            
            // Your Passport Section
            _buildPassportSection(context),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(colorScheme),
    );
  }

  Widget _buildDrawer(BuildContext context, ColorScheme colorScheme, UserProfileService userProfileService) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.restaurant,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 8),
                Text(
                  'Food Passport',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Your Culinary Companion',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.home, color: colorScheme.primary),
            title: Text('Home'),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
              });
            },
          ),
          ListTile(
            leading: Icon(Icons.explore, color: colorScheme.primary),
            title: Text('Explore'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/map');
            },
          ),
          ListTile(
            leading: Icon(Icons.airplane_ticket, color: colorScheme.primary),
            title: Text('My Passport'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/passport');
            },
          ),
          ListTile(
            leading: Icon(Icons.menu_book, color: colorScheme.primary),
            title: Text('Food Journal'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/journal');
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.settings, color: colorScheme.primary),
            title: Text('Settings & Preferences'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, '/preferences');
            },
          ),
          ListTile(
            leading: Icon(Icons.help, color: colorScheme.primary),
            title: Text('Help & Support'),
            onTap: () {
              // Handle help navigation
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.info, color: colorScheme.primary),
            title: Text('About'),
            onTap: () {
              // Handle about navigation
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notifications',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildNotificationItem(
                context,
                Icons.celebration,
                'Achievement Unlocked!',
                'Street Food Explorer - You\'ve identified 5 street foods',
                Colors.orange,
              ),
              _buildNotificationItem(
                context,
                Icons.restaurant,
                'New Feature',
                'Cultural Insights now available for Italian cuisine',
                Theme.of(context).colorScheme.primary,
              ),
              _buildNotificationItem(
                context,
                Icons.update,
                'App Update',
                'Version 2.1.0 is now available',
                Colors.blue,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(BuildContext context, IconData icon, String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCulinaryJourneyCarousel(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Your Culinary Journey',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: PageView.builder(
            onPageChanged: (index) {
              setState(() {
                _carouselIndex = index;
              });
            },
            itemCount: _carouselItems.length,
            itemBuilder: (context, index) {
              final item = _carouselItems[index];
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  image: DecorationImage(
                    image: NetworkImage(item['image']),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  item['flag'],
                                  style: const TextStyle(fontSize: 16),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  item['country'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item['flag'],
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.flag,
                                color: Theme.of(context).colorScheme.primary,
                                size: 12,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _carouselItems.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _carouselIndex == index 
                    ? Theme.of(context).colorScheme.primary 
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickToolsSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    final List<Map<String, dynamic>> quickTools = [
      {
        'icon': Icons.restaurant,
        'title': 'AI Dish ID',
        'route': '/camera',
        'color': colorScheme.primary,
      },
      {
        'icon': Icons.translate,
        'title': 'Menu Translate', 
        'route': '/menu-scan',
        'color': colorScheme.secondary,
      },
      {
        'icon': Icons.shield,
        'title': 'Allergy Check',
        'route': '/emergency',
        'color': Colors.orange,
      },
      {
        'icon': Icons.menu_book,
        'title': 'Food Dictionary',
        'route': '/journal',
        'color': Colors.purple,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Tools',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: quickTools.length,
            itemBuilder: (context, index) {
              final tool = quickTools[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pushNamed(context, tool['route']),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: tool['color'].withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            tool['icon'],
                            color: tool['color'],
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tool['title'],
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPassportSection(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Passport',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.star,
                      size: 40,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '3/10 Countries Explored',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Continue your culinary adventure!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  // Progress bar
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: 0.3, // 3 out of 10 countries
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [colorScheme.primary, colorScheme.primaryContainer],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/passport'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      side: BorderSide(color: colorScheme.primary),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    child: const Text('View Full Passport'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(ColorScheme colorScheme) {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
        // Navigate to different screens
        switch (index) {
          case 0:
            // Already on home
            break;
          case 1:
            Navigator.pushNamed(context, '/map');
            break;
          case 2:
            Navigator.pushNamed(context, '/camera');
            break;
          case 3:
            Navigator.pushNamed(context, '/passport');
            break;
          case 4:
            Navigator.pushNamed(context, '/preferences');
            break;
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.explore_outlined),
          activeIcon: Icon(Icons.explore),
          label: 'Explore',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt_outlined),
          activeIcon: Icon(Icons.camera_alt),
          label: 'Scan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.airplane_ticket_outlined),
          activeIcon: Icon(Icons.airplane_ticket),
          label: 'Passport',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outlined),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}