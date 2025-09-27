import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
import 'models/food_item.dart';

void main() {
  runApp(const FoodPassportApp());
}

class FoodPassportApp extends StatelessWidget {
  const FoodPassportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProfileService()),
        ChangeNotifierProvider(create: (context) => FoodStateService()),
      ],
      child: MaterialApp(
        title: 'Food Passport',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const UserFormScreen(),
        routes: {
          '/home': (context) => const HomeScreen(),
          '/camera': (context) => const CameraScreen(),
          '/journal': (context) => const FoodJournalScreen(),
          '/recipe': (context) => RecipeScreen(dishName: 'Recent Food'),
          '/culture': (context) => CulturalInsightsScreen(dishName: 'Recent Food'),
          '/map': (context) => const MapScreen(),
          '/emergency': (context) {
  final foodState = Provider.of<FoodStateService>(context, listen: false);
  return EmergencyAlertScreen(
    foodItem: foodState.currentFoodItem ?? FoodItem.fromRecognitionMap(
      {
        'foodName': 'Emergency Food',
        'calories': 0.0,
        'protein': 0.0,
        'carbs': 0.0,
        'fat': 0.0,
        'confidence': 0.0,
        'detectedAllergens': [],
        'source': 'emergency'
      },
      imagePath: '',
    ),
  );
},
          '/preferences': (context) => const PreferencesScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProfileService = Provider.of<UserProfileService>(context);
    final userProfile = userProfileService.userProfile; // Now this works!
    final foodState = Provider.of<FoodStateService>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(userProfile?.name != null 
            ? 'Welcome, ${userProfile!.name}!' 
            : 'Food Passport'),
        backgroundColor: Colors.blue,
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
            // Quick Action Card - Camera
            _buildActionCard(
              context,
              icon: Icons.camera_alt,
              title: 'Identify Food',
              subtitle: 'Take a photo to analyze food',
              color: Colors.green,
              onTap: () => Navigator.pushNamed(context, '/camera'),
            ),

            const SizedBox(height: 16),

            // Recent Food Detection (if any)
            if (foodState.currentFoodItem != null) ...[
              _buildRecentFoodCard(context, foodState.currentFoodItem!),
              const SizedBox(height: 16),
            ],

            // Feature Grid
            Row(
              children: [
                Expanded(child: _buildFeatureCard(
                  context, icon: Icons.menu_book, title: 'Food Journal',
                  onTap: () => Navigator.pushNamed(context, '/journal'),
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildFeatureCard(
                  context, icon: Icons.map, title: 'Food Map',
                  onTap: () => Navigator.pushNamed(context, '/map'),
                )),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _buildFeatureCard(
                  context, icon: Icons.emergency, title: 'Allergy Safety',
                  onTap: () => Navigator.pushNamed(context, '/emergency'),
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildFeatureCard(
                  context, icon: Icons.language, title: 'Cultural Guide',
                  onTap: () => Navigator.pushNamed(context, '/culture'),
                )),
              ],
            ),

            const Spacer(),

            // User Profile Summary
            if (userProfile != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dietary Profile',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      if (userProfile.allergies.isNotEmpty) ...[
                        Text('Allergies: ${userProfile.allergies.join(', ')}', 
                            style: const TextStyle(fontSize: 12)),
                      ],
                      if (userProfile.dietaryPreference != null) ...[
                        Text('Preference: ${userProfile.dietaryPreference!}', 
                            style: const TextStyle(fontSize: 12)),
                      ],
                    ],
                  ),
                ),
              ),
            ] else ...[
              Card(
                color: Colors.orange[50],
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text('Complete your profile for better food detection'),
                      ),
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
        backgroundColor: Colors.green,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required IconData icon, required String title, required String subtitle,
    required Color color, required VoidCallback onTap,
  }) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentFoodCard(BuildContext context, FoodItem foodItem) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.history, size: 16, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('Recently Identified', style: TextStyle(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 8),
            Text(foodItem.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('${foodItem.calories.round()} cal • ${foodItem.confidenceScore.toStringAsFixed(1)} confidence',
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Row(children: [
              if (foodItem.detectedAllergens.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withAlpha(51),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('${foodItem.detectedAllergens.length} allergens',
                      style: const TextStyle(fontSize: 10, color: Colors.orange)),
                ),
              ],
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/recipe'),
                child: const Text('View Details'),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, {
    required IconData icon, required String title, required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: Colors.blue),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
