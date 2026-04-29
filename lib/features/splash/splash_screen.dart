import 'package:flutter/material.dart';
import '../auth/auth_wrapper.dart'; // Make sure this path matches your project!

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _routeToApp();
  }

  void _routeToApp() async {
    debugPrint("⏳ Splash Screen: Started the 2.5-second timer...");
    await Future.delayed(const Duration(milliseconds: 2500));
    
    debugPrint("✅ Splash Screen: Timer finished. Checking if mounted...");
    if (!mounted) {
      debugPrint("❌ Splash Screen: Widget is no longer mounted. Aborting navigation.");
      return;
    }
    
    debugPrint("🚀 Splash Screen: Attempting to push AuthWrapper...");
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const AuthWrapper()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.menu_book, color: Colors.white, size: 64),
            ),
            const SizedBox(height: 24),
            const Text(
              'SmartStudy',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              'Elevate your academic workflow',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}