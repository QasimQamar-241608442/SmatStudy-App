import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart'; 
import 'features/auth/splash_screen.dart'; 
import 'features/auth/login_screen.dart';
import 'features/auth/registration_screen.dart';
import 'features/auth/auth_wrapper.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SmartStudyApp());
}

// This is the class your app was looking for!
class SmartStudyApp extends StatelessWidget {
  const SmartStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartStudy',
      theme: AppTheme.lightTheme, // Applies your global design system
      debugShowCheckedModeBanner: false, // Removes the red "DEBUG" banner
      home: const AuthWrapper(), // Sets the initial screen
    );
  }
}