import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

import 'services/user_profile_service.dart';
import 'services/food_state_service.dart';

import 'camera_screen.dart';

late List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(const FoodPassportApp());
}

class FoodPassportApp extends StatelessWidget {
  const FoodPassportApp({super.key});

  @override
  Widget build(BuildContext context) {
    const coralOrange = Color(0xFFFF6F61);
    const mintGreen = Color(0xFF8BC34A);
    const lightBackground = Color(0xFFF8F8F8);

    final colorScheme = ColorScheme.fromSeed(
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
        ChangeNotifierProvider(create: (_) => UserProfileService()),
        ChangeNotifierProvider(create: (_) => FoodStateService()),
      ],
      child: MaterialApp(
        title: 'Food Passport',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: colorScheme,
          scaffoldBackgroundColor: colorScheme.surface,
        ),
        home: CameraScreen(camera: cameras.first),
        // Add other routes here
        routes: {},
      ),
    );
  }
}
