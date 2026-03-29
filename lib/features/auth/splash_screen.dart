import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      body: Column(
        children: [
          const Spacer(), // Pushes the center content down
          
          // Center Content (Logo Placeholder & Text)
          Center(
            child: Column(
              children: [
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
                    color: Colors.grey, 
                    fontSize: 12,
                    letterSpacing: 2.0,
                  ),
                ),
              ],
            ),
          ),
          
          const Spacer(), // Pushes the loading indicator to the bottom
          
          // Bottom Loading Indicator
          const Padding(
            padding: EdgeInsets.only(bottom: 48.0),
            child: CircularProgressIndicator(
              color: Colors.white, // Minimalist white spinner
            ),
          ),
        ],
      ),
    );
  }
}