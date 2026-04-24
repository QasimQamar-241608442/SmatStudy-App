import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart'; // Importing your design system
import 'features/auth/splash_screen.dart'; 
import 'features/auth/login_screen.dart';
import 'features/auth/registration_screen.dart';


void main() async {
  // This line is required when using async operations before runApp()
  WidgetsFlutterBinding.ensureInitialized();

  // This is the magic line that boots up your connection to Google!
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SmartStudyApp());
}
