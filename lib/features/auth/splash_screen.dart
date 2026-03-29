import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background from your design
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Using a simple text widget for the logo right now
            const Text(
              '✦ SmartStudy',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'STRUCTURED SERENITY',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 12,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}