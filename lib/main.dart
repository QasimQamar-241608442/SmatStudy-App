import 'package:flutter/material.dart';

void main() {
  // This is the starting point of your entire application.
  runApp(const SmartStudyApp());
}

class SmartStudyApp extends StatelessWidget {
  const SmartStudyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartStudy',
      debugShowCheckedModeBanner: false, // Removes the red "DEBUG" banner
      theme: ThemeData(
        // We will customize these colors later when we have our Figma design
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // Scaffold is the blank white canvas for a screen
      home: const Scaffold(
        body: Center(
          child: Text(
            'SmartStudy: Ready for Development',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}