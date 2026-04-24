import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';
import '../dashboard/home_dashboard_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // StreamBuilder listens to a constant stream of data (in this case, Auth state)
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. While it's checking with Firebase, show a quick loading spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF9FAFB),
            body: Center(
              child: CircularProgressIndicator(color: Colors.black),
            ),
          );
        }

        // 2. If the snapshot contains user data, they are successfully logged in!
        if (snapshot.hasData) {
          return const HomeDashboardScreen();
        }

        // 3. If there is no data, they are logged out. Show the Login Screen.
        return const LoginScreen();
      },
    );
  }
}