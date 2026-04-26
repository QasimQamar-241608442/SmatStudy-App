import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // <--- 1. Add this import!
import 'features/auth/auth_wrapper.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 2. Add the options parameter here!
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  ); 
  runApp(const SmartStudyApp());
}
class SmartStudyApp extends StatelessWidget {
  const SmartStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartStudy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB),
        fontFamily: 'Roboto', 
      ),
      home: const AuthWrapper(), 
    );
  }
}