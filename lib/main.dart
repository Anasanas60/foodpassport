// ignore: avoid_web_libraries_in_flutter
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:foodpassport/services/advanced_food_recognition.dart';

// Import all your screens
import 'package:foodpassport/preferences_screen.dart';
import 'package:foodpassport/user_form_screen.dart';
import 'package:foodpassport/recipe_screen.dart';
import 'package:foodpassport/cultural_insights_screen.dart';
import 'package:foodpassport/food_journal_screen.dart';
import 'package:foodpassport/map_screen.dart';
import 'package:foodpassport/menu_scan_screen.dart';
import 'package:foodpassport/emergency_alert_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBiuyyfkgQk8ljG4FCxpivSkNYqNsiX9Sg",
      appId: "1:1234567890:web:abcdef123456",
      messagingSenderId: "387382766417",
      projectId: "foodpassport-a4992",
    ),
  );
  runApp(const FoodPassportApp());
}

class FoodPassportApp extends StatelessWidget {
  const FoodPassportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/preferences': (context) => const PreferencesScreen(),
        '/userform': (context) => const UserFormScreen(),
        '/recipe': (context) => const RecipeScreen(dishName: ""),
        '/cultural': (context) => const CulturalInsightsScreen(dishName: ""),
        '/journal': (context) => const FoodJournalScreen(),
        '/map': (context) => const MapScreen(),
        '/menuscan': (context) => const MenuScanScreen(),
        '/emergency': (context) => const EmergencyAlertScreen(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userName = "Guest";
  String userLanguage = "English";
  int userAge = 25;
  String userLocation = "Bangkok";
  bool isAnalyzing = false;
  String? resultDish;
  bool hasAllergyWarning = false;
  XFile? selectedImage;
  String? pickedFrom;
  Uint8List? webImageBytes;
  Map<String, dynamic>? currentFoodData;

  bool avoidNuts = false;
  bool avoidDairy = false;
  bool avoidGluten = false;
  bool isVegan = false;

  final ImagePicker _picker = ImagePicker();

  // Test Advanced AI System
  Future<void> _testAdvancedAI() async {
    ('🧪 Testing Advanced AI System...');
    
    try {
      // Create a mock XFile for testing
      final foodData = await AdvancedFoodRecognition.detectFood(
        XFile('test'), 
        userLocation: userLocation
      );
      
      ('✅ AI Detection Successful!');
      ('🍜 Dish: ${foodData['dishName']}');
      ('🎯 Confidence: ${(foodData['confidence'] * 100).toStringAsFixed(1)}%');
      ('📋 Ingredients: ${foodData['ingredients'].length} items');
      ('⚠️ Allergens: ${foodData['allergens']}');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Advanced AI Working! Detected: ${foodData['dishName']}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      ('❌ Advanced AI Test Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ AI Error: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 600,
        imageQuality: 50,
      );

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            webImageBytes = bytes;
            selectedImage = image;
            pickedFrom = source == ImageSource.camera ? "📸 Taken with Camera" : "🖼️ Uploaded from Gallery";
          });
        } else {
          setState(() {
            webImageBytes = null;
            selectedImage = image;
            pickedFrom = source == ImageSource.camera ? "📸 Taken with Camera" : "🖼️ Uploaded from Gallery";
          });
        }
        _analyzeFoodWithAI();
      }
    } catch (e) {
      ('Image picker error: $e');
      if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }
  }

  // Advanced AI Food Detection
  void _analyzeFoodWithAI() async {
    setState(() {
      isAnalyzing = true;
      resultDish = null;
      hasAllergyWarning = false;
      currentFoodData = null;
    });

    try {
      // ADVANCED AI FOOD DETECTION
      final foodData = await AdvancedFoodRecognition.detectFood(
        selectedImage!, 
        userLocation: userLocation
      );
      
      final String detectedDish = foodData['dishName'];
      final List<String> ingredients = List<String>.from(foodData['ingredients']);
      final List<String> allergens = List<String>.from(foodData['allergens']);
      final double confidence = foodData['confidence'];
      
      // Check against user preferences
      bool warning = _checkAllergyWarning(allergens);
      
      if (mounted) {
        setState(() {
          isAnalyzing = false;
          resultDish = detectedDish;
          hasAllergyWarning = warning;
          currentFoodData = foodData;
        });
      }
      
      // Log AI confidence level
      ('🎯 AI Detection Confidence: ${(confidence * 100).toStringAsFixed(1)}%');
      ('🍜 Detected Dish: $detectedDish');
      ('📋 Ingredients: $ingredients');
      ('⚠️ Allergens: $allergens');
      
    } catch (e) {
      ('Advanced food analysis error: $e');
      if (mounted) {
        setState(() {
          isAnalyzing = false;
          resultDish = "AI analysis failed. Please try again.";
          hasAllergyWarning = false;
        });
      }
    }
  }

  bool _checkAllergyWarning(List<String> allergens) {
    if (avoidNuts && allergens.any((allergen) => allergen.contains('nut'))) return true;
    if (avoidDairy && allergens.any((allergen) => allergen.contains('dairy'))) return true;
    if (avoidGluten && allergens.any((allergen) => allergen.contains('gluten'))) return true;
    if (isVegan && allergens.any((allergen) => ['egg', 'dairy', 'fish', 'meat'].any((v) => allergen.contains(v)))) {
      return true;
    }
    return false;
  }

  // FIXED: Enhanced navigation with real data
  void _navigateToRecipeScreen() {
    if (currentFoodData != null && resultDish != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeScreen(
            dishName: resultDish!,
            foodData: currentFoodData!, // Now this should work
          ),
        ),
      );
    } else {
      // Fallback if no data available
      Navigator.pushNamed(context, '/recipe');
    }
  }

  void _navigateToCulturalScreen() {
    if (currentFoodData != null && resultDish != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CulturalInsightsScreen(
            dishName: resultDish!,
            foodData: currentFoodData!, // Now this should work
          ),
        ),
      );
    } else {
      // Fallback if no data available
      Navigator.pushNamed(context, '/cultural');
    }
  }

  Widget _buildImagePreview() {
    if (kIsWeb && webImageBytes != null) {
      return Image.memory(webImageBytes!, fit: BoxFit.cover);
    } else if (!kIsWeb && selectedImage != null) {
      return Image.file(File(selectedImage!.path), fit: BoxFit.cover);
    } else {
      return Container(
        color: Colors.grey[200],
        child: Icon(Icons.photo, size: 60, color: Colors.grey[400]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello, $userName! 👋', style: const TextStyle(fontSize: 20)),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/userform'),
            tooltip: 'User Info',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final result = await Navigator.pushNamed(context, '/preferences');
              if (result is Map<String, dynamic>) {
                setState(() {
                  userName = result['userName'] ?? userName;
                  avoidNuts = result['avoidNuts'] ?? avoidNuts;
                  avoidDairy = result['avoidDairy'] ?? avoidDairy;
                  avoidGluten = result['avoidGluten'] ?? avoidGluten;
                  isVegan = result['isVegan'] ?? isVegan;
                });
              }
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             const Icon(Icons.restaurant_menu, size: 80, color: Colors.deepOrange),
              const SizedBox(height: 20),
              const Text(
                'FoodPassport AI',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Advanced AI Food Recognition & Analysis',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Advanced AI Test Button
              ElevatedButton(
                onPressed: _testAdvancedAI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: const Text('🧠 Test Advanced AI', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 10),

              if (selectedImage != null) ...[
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: _buildImagePreview(),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  pickedFrom ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                const SizedBox(height: 20),
              ],

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/menuscan'),
                    icon: const Icon(Icons.menu_book, size: 20),
                    label: const Text('Scan Menu'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/map'),
                    icon: const Icon(Icons.map, size: 20),
                    label: const Text('My Food Map'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/journal'),
                    icon: const Icon(Icons.collections_bookmark, size: 20),
                    label: const Text('My Journal'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              if (!isAnalyzing && resultDish == null) ...[
                ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Take Photo', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Upload Photo', style: TextStyle(fontSize: 18)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],

              if (isAnalyzing) ...[
                const CircularProgressIndicator(color: Colors.deepOrange),
                const SizedBox(height: 20),
                const Text(
                  '🧠 Advanced AI Analyzing...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Using multi-API intelligence',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],

              if (resultDish != null && !isAnalyzing) ...[
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🎉 AI Identified: $resultDish',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        if (currentFoodData?['confidence'] != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '🎯 Confidence: ${(currentFoodData!['confidence'] * 100).toStringAsFixed(1)}%',
                            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                          ),
                        ],
                        const SizedBox(height: 16),
                        if (hasAllergyWarning) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red[50],
                              border: Border.all(color: Colors.red, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '⚠️ WARNING: Contains ingredients you avoid!',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/emergency'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('🚨 EMERGENCY ALERT', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Wrap(
                          spacing: 12,
                          children: [
                            ElevatedButton(
                              onPressed: _navigateToRecipeScreen,
                              child: const Text('👩‍🍳 Recipe & Ingredients'),
                            ),
                            ElevatedButton(
                              onPressed: _navigateToCulturalScreen,
                              child: const Text('🌏 Culture & Origin'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () => setState(() {
                              resultDish = null;
                              hasAllergyWarning = false;
                              selectedImage = null;
                              webImageBytes = null;
                              pickedFrom = null;
                              currentFoodData = null;
                            }),
                            child: const Text('Try Another Dish →'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}