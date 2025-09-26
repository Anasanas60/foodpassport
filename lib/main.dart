import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/user_profile_service.dart';
import 'user_form_screen.dart';

void main() {
  runApp(const FoodPassportApp());
}

class FoodPassportApp extends StatelessWidget {
  const FoodPassportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserProfileService(),
      child: MaterialApp(
        title: 'Food Passport',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const UserFormScreen(),
      ),
    );
  }
}