import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart'; // Importing your design system
import 'features/auth/splash_screen.dart'; 
void main() {
  runApp(const SmartStudyApp());
}

class SmartStudyApp extends StatelessWidget {
  const SmartStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartStudy',
      debugShowCheckedModeBanner: false,
      // Here is where we inject your custom design system!
      theme: AppTheme.lightTheme, 
      // We will replace this placeholder with your actual Splash Screen in the next step
      home: const Scaffold(
        body: Center(
          child: Text('Theme Connected!'),
        ),
      ),
    );
  }
}
