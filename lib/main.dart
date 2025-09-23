// ignore: avoid_web_libraries_in_flutter
import 'package:firebase_core/firebase_core.dart';
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

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
        '/recipe': (context) => RecipeScreen(dishName: ""),
        '/cultural': (context) => CulturalInsightsScreen(dishName: ""),
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

  bool avoidNuts = false;
  bool avoidDairy = false;
  bool avoidGluten = false;
  bool isVegan = false;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera && !kIsWeb) {
      final image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          selectedImage = image;
          pickedFrom = "📸 Taken with Camera";
        });
        _simulateAIAnalysis();
      }
    } else if (source == ImageSource.camera && kIsWeb) {
      // Web: Use HTML5 camera capture
      final input = html.FileUploadInputElement(); // ✅ Now works
      input.accept = 'image/*';
      input.attributes['capture'] = 'environment';
      input.click();

      input.onChange.listen((event) async {
        if (input.files!.isNotEmpty) {
          final file = input.files![0];
          final reader = html.FileReader(); // ✅ Now works
          reader.readAsArrayBuffer(file);

          reader.onLoadEnd.listen((e) async {
            final buffer = reader.result as ByteBuffer;
            final tempDir = await getTemporaryDirectory();
            final path = '${tempDir.path}/${file.name}';
            final newFile = File(path);
            await newFile.writeAsBytes(buffer.asUint8List());

            if (mounted) {
              setState(() {
                selectedImage = XFile(newFile.path, name: file.name);
                pickedFrom = "📸 Taken with Camera";
              });

              _simulateAIAnalysis();
            }
          });
        }
      });
    } else {
      final image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          selectedImage = image;
          pickedFrom = "🖼️ Uploaded from Gallery";
        });
        _simulateAIAnalysis();
      }
    }
  }

  void _simulateAIAnalysis() async {
    setState(() {
      isAnalyzing = true;
      resultDish = null;
      hasAllergyWarning = false;
    });

    await Future.delayed(const Duration(seconds: 2));

    String detectedDish = "Pad Thai";
    List<String> detectedIngredients = ["Peanuts", "Fish Sauce", "Rice Noodles", "Egg"];

    bool warning = false;
    if (avoidNuts && detectedIngredients.contains("Peanuts")) warning = true;
    if (avoidDairy && detectedIngredients.contains("Milk")) warning = true;
    if (avoidGluten && detectedIngredients.contains("Wheat")) warning = true;
    if (isVegan && ["Fish Sauce", "Egg", "Milk"].any((ingredient) => detectedIngredients.contains(ingredient))) {
      warning = true;
    }

    if (mounted) {
      setState(() {
        isAnalyzing = false;
        resultDish = detectedDish;
        hasAllergyWarning = warning;
      });
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
              Icon(Icons.restaurant_menu, size: 80, color: Colors.deepOrange),
              const SizedBox(height: 20),
              Text(
                'FoodPassport',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                'Scan. Discover. Taste the World.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 20),

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
                    child: Image.file(
                      File(selectedImage!.path),
                      fit: BoxFit.cover,
                    ),
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
                  'Analyzing your dish...',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
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
                          '🎉 Dish Identified: $resultDish',
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
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
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RecipeScreen(dishName: resultDish!),
                                ),
                              ),
                              child: const Text('👩‍🍳 Recipe'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CulturalInsightsScreen(dishName: resultDish!),
                                ),
                              ),
                              child: const Text('🌏 Culture'),
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
                              pickedFrom = null;
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