import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import FoodItem model with alias to avoid conflicts
import 'models/food_item.dart' as models;

import 'services/user_profile_service.dart';
import 'services/food_state_service.dart';

import 'user_form_screen.dart';
import 'camera_screen.dart';
import 'food_journal_screen.dart'; // Import normally for FoodJournalScreen
import 'recipe_screen.dart';
import 'cultural_insights_screen.dart';
import 'map_screen.dart';
import 'emergency_alert_screen.dart';
import 'preferences_screen.dart';

void main() {
  runApp(const FoodPassportApp());
}

class FoodPassportApp extends StatelessWidget {
  const FoodPassportApp({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFFFF6F61); // Coral Orange
    final Color secondaryColor = const Color(0xFF8BC34A); // Mint Green
    final Color backgroundColor = const Color(0xFFF8F8F8); // Light gray

    final ColorScheme colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      primary: primaryColor,
      secondary: secondaryColor,
      surface: backgroundColor,
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
            elevation: 4,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.white),
          ),
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          textTheme: const TextTheme(
            headlineSmall: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
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
            elevation: 3,
            color: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          iconTheme: IconThemeData(color: colorScheme.primary),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        home: const UserFormScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/camera': (context) => const CameraScreen(),
          '/journal': (context) => const FoodJournalScreen(),
          '/recipe': (context) => const RecipeScreen(dishName: 'Recent Food'),
          '/culture': (context) => const CulturalInsightsScreen(dishName: 'Recent Food'),
          '/map': (context) => const MapScreen(),
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
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfileService = Provider.of<UserProfileService>(context);
    final userProfile = userProfileService.userProfile;
    final foodState = Provider.of<FoodStateService>(context);

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(userProfile?.name != null ? 'Welcome, ${userProfile!.name}!' : 'Food Passport'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/preferences'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildActionCard(
              context,
              icon: Icons.camera_alt,
              title: 'Identify Food',
              subtitle: 'Take a photo to analyze food',
              color: colorScheme.secondary,
              onTap: () => Navigator.pushNamed(context, '/camera'),
            ),
            const SizedBox(height: 16),
            if (foodState.currentFoodItem != null) ...[
              _buildRecentFoodCard(context, foodState.currentFoodItem!),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                      context, icon: Icons.menu_book, title: 'Food Journal', onTap: () => Navigator.pushNamed(context, '/journal')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFeatureCard(context, icon: Icons.map, title: 'Food Map', onTap: () => Navigator.pushNamed(context, '/map')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(context, icon: Icons.emergency, title: 'Allergy Safety', onTap: () => Navigator.pushNamed(context, '/emergency')),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFeatureCard(context, icon: Icons.language, title: 'Cultural Guide', onTap: () => Navigator.pushNamed(context, '/culture')),
                ),
              ],
            ),
            const Spacer(),
            if (userProfile != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Dietary Profile', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      if (userProfile.allergies.isNotEmpty)
                        Text('Allergies: ${userProfile.allergies.join(', ')}', style: const TextStyle(fontSize: 12)),
                      if (userProfile.dietaryPreference != null)
                        Text('Preference: ${userProfile.dietaryPreference!}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                color: colorScheme.primary.withAlpha((0.5 * 255).round()),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Color(0xFFFF6F61)),
                      SizedBox(width: 12),
                      Expanded(child: Text('Complete your profile for better food detection')),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/camera'),
        backgroundColor: colorScheme.secondary,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context,
      {required IconData icon, required String title, required String subtitle, required Color color, required VoidCallback onTap}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withAlpha(51), shape: BoxShape.circle), child: Icon(icon, color: color)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: Theme.of(context).textTheme.labelLarge),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600]))
                ]),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentFoodCard(BuildContext context, models.FoodItem foodItem) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(Icons.history, size: 16, color: colorScheme.primary),
              const SizedBox(width: 8),
              Text('Recently Identified', style: Theme.of(context).textTheme.labelLarge),
            ]),
            const SizedBox(height: 8),
            Text(foodItem.name, style: Theme.of(context).textTheme.labelLarge),
            const SizedBox(height: 4),
            Text('${foodItem.calories.round()} cal • ${foodItem.confidenceScore.toStringAsFixed(1)} confidence',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(children: [
              if (foodItem.detectedAllergens.isNotEmpty)
                Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.orange.withAlpha(51), borderRadius: BorderRadius.circular(4)),
                    child: Text('${foodItem.detectedAllergens.length} allergens', style: const TextStyle(fontSize: 10, color: Colors.orange))),
              const Spacer(),
              TextButton(onPressed: () => Navigator.pushNamed(context, '/recipe'), child: const Text('View Details')),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 32, color: colorScheme.primary),
            const SizedBox(height: 8),
            Text(title, textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}
