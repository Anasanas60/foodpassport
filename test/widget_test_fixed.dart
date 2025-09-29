import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:foodpassport/services/user_profile_service.dart';
import 'package:foodpassport/services/food_state_service.dart';
import 'package:foodpassport/food_journal_screen.dart';
import 'package:foodpassport/models/food_item.dart';

void main() {

  group('Food Passport App Tests', () {


    testWidgets('Food journal screen displays empty state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UserProfileService()),
            ChangeNotifierProvider(create: (_) => FoodStateService()),
          ],
          child: const MaterialApp(
            home: FoodJournalScreen(),
          ),
        ),
      );

      // Verify empty state is shown
      expect(find.text('Your Food Journal is Empty'), findsOneWidget);
      expect(find.text('Scan Your First Dish'), findsOneWidget);
    });

    testWidgets('Food journal screen displays entries', (WidgetTester tester) async {
      // Create mock food item
      final mockFoodItem = FoodItem(
        id: 'test-id',
        name: 'Pad Thai',
        calories: 450.0,
        protein: 20.0,
        carbs: 60.0,
        fat: 15.0,
        confidenceScore: 0.85,
        source: 'Nutritionix API',
        detectedAllergens: ['peanuts'],
        timestamp: DateTime.now(),
        imagePath: '',
      );

      final foodStateService = FoodStateService();
      foodStateService.addToHistory(mockFoodItem);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UserProfileService()),
            ChangeNotifierProvider(create: (_) => foodStateService),
          ],
          child: const MaterialApp(
            home: FoodJournalScreen(),
          ),
        ),
      );

      // Verify food entry is displayed
      expect(find.text('Pad Thai'), findsOneWidget);
      expect(find.text('450 cal'), findsOneWidget);
      expect(find.text('Allergy'), findsOneWidget);
    });



    testWidgets('Analytics button is shown when entries exist', (WidgetTester tester) async {
      final mockFoodItem = FoodItem(
        id: 'test-id-2',
        name: 'Test Dish',
        calories: 300.0,
        protein: 15.0,
        carbs: 40.0,
        fat: 10.0,
        confidenceScore: 0.8,
        source: 'Test',
        detectedAllergens: [],
        timestamp: DateTime.now(),
        imagePath: '',
      );

      final foodStateService = FoodStateService();
      foodStateService.addToHistory(mockFoodItem);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => UserProfileService()),
            ChangeNotifierProvider(create: (_) => foodStateService),
          ],
          child: const MaterialApp(
            home: FoodJournalScreen(),
          ),
        ),
      );

      // Verify analytics button is present
      expect(find.byIcon(Icons.analytics), findsOneWidget);
    });
  });
}
