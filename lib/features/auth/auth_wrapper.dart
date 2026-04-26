import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import '../dashboard/main_dashboard.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If the stream is still loading, show a blank loading screen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.black)));
        }
        
        // If we have a user data object, they are logged in! Go to Dashboard.
        if (snapshot.hasData) {
          return const MainDashboard();
        }
        
        // Otherwise, they are logged out. Show the Login Screen.
        return const LoginScreen();
      },
    );
  }
}