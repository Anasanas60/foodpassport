// ignore: avoid_web_libraries_in_flutter
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:typed_data';

// Import services
import 'package:foodpassport/services/advanced_food_recognition.dart';
import 'package:foodpassport/services/user_profile_service.dart';

// Import all your screens
import 'package:foodpassport/preferences_screen.dart';
import 'package:foodpassport/user_form_screen.dart';
import 'package:foodpassport/recipe_screen.dart';
import 'package:foodpassport/cultural_insights_screen.dart';
import 'package:foodpassport/food_journal_screen.dart';
import 'package:foodpassport/map_screen.dart';
import 'package:foodpassport/menu_scan_screen.dart';
import 'package:foodpassport/emergency_alert_screen.dart';
import 'package:foodpassport/passport_stamps_screen.dart';

// Import custom animations
import 'package:foodpassport/animations/custom_page_route.dart';

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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProfileService()..loadUserProfile()),
      ],
      child: MaterialApp(
        title: 'FoodPassport',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1a237e), // Passport navy blue
            primary: const Color(0xFF1a237e),
            secondary: const Color(0xFFffd700), // Gold accent
            background: const Color(0xFFf8f5f0), // Vintage paper color
          ),
          fontFamily: 'Inter',
        ),
        home: const MainNavigationScreen(),
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/journal':
              return SlideUpRoute(page: const FoodJournalScreen());
            case '/map':
              return SlideRightRoute(page: const MapScreen());
            case '/passport-stamps':
              return ScaleRoute(page: const PassportStampsScreen());
            case '/menuscan':
              return SlideUpRoute(page: const MenuScanScreen());
            case '/preferences':
              return SlideRightRoute(page: const PreferencesScreen());
            default:
              return FadeRoute(page: _getPageForRoute(settings.name ?? '/'));
          }
        },
      ),
    );
  }

  Widget _getPageForRoute(String routeName) {
    switch (routeName) {
      case '/': return const MainNavigationScreen();
      case '/preferences': return const PreferencesScreen();
      case '/userform': return const UserFormScreen();
      case '/recipe': return const RecipeScreen(dishName: "");
      case '/cultural': return const CulturalInsightsScreen(dishName: "");
      case '/journal': return const FoodJournalScreen();
      case '/map': return const MapScreen();
      case '/menuscan': return const MenuScanScreen();
      case '/emergency': return const EmergencyAlertScreen();
      case '/passport-stamps': return const PassportStampsScreen();
      default: return const MainNavigationScreen();
    }
  }
}

// Enhanced Main Navigation Screen with Travel Passport Theme
class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  // Screens for bottom navigation
  final List<Widget> _screens = [
    const HomeContentScreen(), // Camera/Scan main screen
    const FoodJournalScreen(), // Food journal
    const MapScreen(), // Food map
    const PassportStampsScreen(), // Stamps & achievements
  ];

  final List<Map<String, dynamic>> _screenThemes = [
    {
      'title': 'FoodPassport',
      'icon': Icons.camera_alt,
      'stamp': '🛂',
      'color': Color(0xFF1a237e),
    },
    {
      'title': 'Food Journal',
      'icon': Icons.restaurant_menu,
      'stamp': '📖',
      'color': Color(0xFF8b0000),
    },
    {
      'title': 'Food Map',
      'icon': Icons.map,
      'stamp': '🗺️',
      'color': Color(0xFF2e7d32),
    },
    {
      'title': 'My Stamps',
      'icon': Icons.star,
      'stamp': '⭐',
      'color': Color(0xFFff6f00),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildPassportAppBar(),
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildPassportNavigationBar(),
      floatingActionButton: _currentIndex == 0 ? _buildPassportFAB() : null,
    );
  }

  AppBar _buildPassportAppBar() {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Color(0xFFffd700), width: 2),
            ),
            child: Text(
              '🛂',
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(width: 12),
          Text(
            _screenThemes[_currentIndex]['title'],
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
      backgroundColor: _screenThemes[_currentIndex]['color'],
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(20),
        ),
      ),
      actions: _currentIndex == 0 ? _buildHomeActions() : null,
    );
  }

  List<Widget> _buildHomeActions() {
    return [
      IconButton(
        icon: Icon(Icons.person, color: Colors.white),
        onPressed: () => Navigator.push(context, SlideRightRoute(page: const UserFormScreen())),
        tooltip: 'Traveler Profile',
      ),
      IconButton(
        icon: Icon(Icons.settings, color: Colors.white),
        onPressed: () => Navigator.push(context, SlideRightRoute(page: const PreferencesScreen())),
        tooltip: 'Passport Settings',
      ),
    ];
  }

  Widget _buildPassportNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: _screenThemes[_currentIndex]['color'],
          unselectedItemColor: Colors.grey[600],
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
          items: _screenThemes.map((theme) {
            return BottomNavigationBarItem(
              icon: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _currentIndex == _screenThemes.indexOf(theme) 
                      ? theme['color'].withOpacity(0.1) 
                      : Colors.transparent,
                ),
                child: Icon(theme['icon']),
              ),
              label: theme['title'].toString().replaceAll('FoodPassport', 'Scanner'),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPassportFAB() {
    return FloatingActionButton(
      onPressed: () => Navigator.push(context, SlideUpRoute(page: const MenuScanScreen())),
      backgroundColor: Color(0xFF1a237e),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Color(0xFFffd700), width: 2),
      ),
      child: const Icon(Icons.camera_alt),
    );
  }
}

// ENHANCED Home Content Screen with Passport Theme (Preserving All Functionality)
class HomeContentScreen extends StatefulWidget {
  const HomeContentScreen({super.key});

  @override
  State<HomeContentScreen> createState() => _HomeContentScreenState();
}

class _HomeContentScreenState extends State<HomeContentScreen> {
  bool isAnalyzing = false;
  String? resultDish;
  bool hasAllergyWarning = false;
  XFile? selectedImage;
  String? pickedFrom;
  Uint8List? webImageBytes;
  Map<String, dynamic>? currentFoodData;

  final ImagePicker _picker = ImagePicker();

  // ✅ Get user data from UserProfileService
  String get _userLocation {
    final profileService = Provider.of<UserProfileService>(context, listen: true);
    return profileService.country ?? "Bangkok";
  }

  List<String> get _userAllergies {
    final profileService = Provider.of<UserProfileService>(context, listen: true);
    return profileService.allergies;
  }

  // ✅ Updated allergy check using UserProfileService
  bool _checkAllergyWarning(List<String> detectedAllergens) {
    final userAllergies = _userAllergies;
    if (userAllergies.isEmpty) return false;
    
    for (final detectedAllergen in detectedAllergens) {
      for (final userAllergy in userAllergies) {
        if (detectedAllergen.toLowerCase().contains(userAllergy.toLowerCase())) {
          return true;
        }
      }
    }
    return false;
  }

  // Test Advanced AI System - ENHANCED WITH PASSPORT THEME
  Future<void> _testAdvancedAI() async {
    print('🧪 Testing Advanced AI System...');
    
    try {
      final foodData = await AdvancedFoodRecognition.detectFood(
        XFile('test'), 
        userLocation: _userLocation
      );
      
      print('✅ AI Detection Successful!');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.verified, color: Colors.white),
                SizedBox(width: 8),
                Text('✅ Advanced AI Working! Detected: ${foodData['dishName']}'),
              ],
            ),
            backgroundColor: Color(0xFF1a237e),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ Advanced AI Test Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ AI Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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
      print('Image picker error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Advanced AI Food Detection - ENHANCED WITH PASSPORT THEME
  void _analyzeFoodWithAI() async {
    setState(() {
      isAnalyzing = true;
      resultDish = null;
      hasAllergyWarning = false;
      currentFoodData = null;
    });

    try {
      final foodData = await AdvancedFoodRecognition.detectFood(
        selectedImage!, 
        userLocation: _userLocation
      );
      
      final String detectedDish = foodData['dishName'];
      final List<String> ingredients = List<String>.from(foodData['ingredients']);
      final List<String> allergens = List<String>.from(foodData['allergens']);
      final double confidence = foodData['confidence'];
      
      bool warning = _checkAllergyWarning(allergens);
      
      if (mounted) {
        setState(() {
          isAnalyzing = false;
          resultDish = detectedDish;
          hasAllergyWarning = warning;
          currentFoodData = foodData;
        });
      }
      
      print('🎯 AI Detection Confidence: ${(confidence * 100).toStringAsFixed(1)}%');
      
    } catch (e) {
      print('Advanced food analysis error: $e');
      if (mounted) {
        setState(() {
          isAnalyzing = false;
          resultDish = "AI analysis failed. Please try again.";
          hasAllergyWarning = false;
        });
      }
    }
  }

  void _navigateToRecipeScreen() {
    if (currentFoodData != null && resultDish != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RecipeScreen(
            dishName: resultDish!,
            foodData: currentFoodData!,
          ),
        ),
      );
    } else {
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
            foodData: currentFoodData!,
          ),
        ),
      );
    } else {
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFf8f5f0),
            Color(0xFFe8e5e0),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // PASSPORT-STYLE HEADER
                Consumer<UserProfileService>(
                  builder: (context, profileService, child) {
                    return Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Color(0xFFffd700), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Color(0xFF1a237e),
                              shape: BoxShape.circle,
                              border: Border.all(color: Color(0xFFffd700), width: 2),
                            ),
                            child: Icon(Icons.airplane_ticket, color: Colors.white, size: 30),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FOOD PASSPORT',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1a237e),
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Welcome, ${profileService.name ?? "Explorer"}!',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '📍 ${_userLocation} • ⚠️ ${_userAllergies.length} allergies',
                                  style: TextStyle(
                                    color: Colors.grey[500],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 30),

                // MAIN SCANNER CARD WITH PASSPORT STYLING
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Color(0xFFffd700), width: 1),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.white, Color(0xFFf8f5f0)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        // SCANNER ICON
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Color(0xFF1a237e),
                            shape: BoxShape.circle,
                            border: Border.all(color: Color(0xFFffd700), width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF1a237e).withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Icon(Icons.camera_alt, size: 40, color: Colors.white),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        const Text(
                          'FOOD SCANNER AI',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1a237e),
                            letterSpacing: 1,
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        Text(
                          'Advanced AI food recognition for travelers',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        
                        const SizedBox(height: 24),

                        // AI TEST BUTTON
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF1a237e), Color(0xFF283593)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF1a237e).withOpacity(0.3),
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: _testAdvancedAI,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.psychology, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'TEST ADVANCED AI',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),

                        // IMAGE PREVIEW AREA
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
                            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // SCAN BUTTONS
                        if (!isAnalyzing && resultDish == null) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF8b0000), Color(0xFFc62828)],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () => _pickImage(ImageSource.camera),
                                    icon: Icon(Icons.camera_alt, color: Colors.white),
                                    label: Text('Take Photo', style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Color(0xFF1a237e)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ElevatedButton.icon(
                                    onPressed: () => _pickImage(ImageSource.gallery),
                                    icon: Icon(Icons.upload_file, color: Color(0xFF1a237e)),
                                    label: Text('Upload', style: TextStyle(color: Color(0xFF1a237e))),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        // LOADING INDICATOR
                        if (isAnalyzing) ...[
                          const SizedBox(height: 20),
                          Column(
                            children: [
                              CircularProgressIndicator(color: Color(0xFF1a237e)),
                              const SizedBox(height: 16),
                              Text(
                                '🧠 Advanced AI Analyzing...',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Using multi-API intelligence',
                                style: TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],

                        // RESULTS DISPLAY
                        if (resultDish != null && !isAnalyzing) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: hasAllergyWarning ? Colors.red[50] : Colors.green[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: hasAllergyWarning ? Colors.red : Colors.green,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '🎉 AI Identified: $resultDish',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: hasAllergyWarning ? Colors.red : Colors.green,
                                  ),
                                ),
                                if (currentFoodData?['confidence'] != null) ...[
                                  SizedBox(height: 8),
                                  Text(
                                    '🎯 Confidence: ${(currentFoodData!['confidence'] * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                                if (hasAllergyWarning) ...[
                                  SizedBox(height: 12),
                                  Container(
                                    padding: EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.red[100],
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '⚠️ WARNING: Contains ingredients you avoid!',
                                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                                SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    ElevatedButton(
                                      onPressed: _navigateToRecipeScreen,
                                      child: Text('👩‍🍳 Recipe & Ingredients'),
                                    ),
                                    ElevatedButton(
                                      onPressed: _navigateToCulturalScreen,
                                      child: Text('🌏 Culture & Origin'),
                                    ),
                                    if (hasAllergyWarning)
                                      ElevatedButton(
                                        onPressed: () => Navigator.push(context, FadeRoute(page: const EmergencyAlertScreen())),
                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                        child: Text('🚨 EMERGENCY ALERT'),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // QUICK ACTIONS WITH PASSPORT STYLING
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildPassportActionButton(
                      'Scan Menu',
                      Icons.menu_book,
                      Color(0xFF1a237e),
                      () => Navigator.push(context, SlideUpRoute(page: const MenuScanScreen())),
                    ),
                    _buildPassportActionButton(
                      'My Food Map',
                      Icons.map,
                      Color(0xFF2e7d32),
                      () {}, // Map is in bottom nav
                    ),
                    _buildPassportActionButton(
                      'Food Journal',
                      Icons.collections_bookmark,
                      Color(0xFF8b0000),
                      () {}, // Journal is in bottom nav
                    ),
                    _buildPassportActionButton(
                      'My Stamps',
                      Icons.star,
                      Color(0xFFff6f00),
                      () {}, // Stamps is in bottom nav
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

  Widget _buildPassportActionButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      width: 120,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color.withOpacity(0.3)),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 24, color: color),
                SizedBox(height: 8),
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}