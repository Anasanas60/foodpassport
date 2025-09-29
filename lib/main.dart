import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'services/user_profile_service.dart';
import 'services/food_state_service.dart';

import 'camera_screen.dart';
import 'utils/allergen_checker.dart';
import 'utils/logger.dart';

import 'package:foodpassport/config/app_theme.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupLogging();
  await dotenv.load(fileName: ".env");
  await AllergenChecker.loadAllergenData();
  cameras = await availableCameras();
  runApp(const FoodPassportApp());
}

class FoodPassportApp extends StatelessWidget {
  const FoodPassportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProfileService()),
        ChangeNotifierProvider(create: (_) => FoodStateService()),
      ],
      child: MaterialApp(
        title: 'Food Passport',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: CameraScreen(camera: cameras.first),
        // Add other routes here
        routes: {},
      ),
    );
  }
}
