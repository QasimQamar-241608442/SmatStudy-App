import 'package:flutter/material.dart';
import 'registration_screen.dart';
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Very light grey background
      body: SafeArea( // Keeps UI out of the phone's notch/status bar
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              
              // Top Icon Placeholder (The book icon)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.menu_book, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 24),
              
              // Titles
              const Text(
                'SmartStudy',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Elevate your academic workflow',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 40),

              // The White Form Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email Field
                    const Text('EMAIL ADDRESS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    const TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(hintText: 'name@university.edu'),
                    ),
                    const SizedBox(height: 24),

                    // Password Field with Forgot Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('PASSWORD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          child: const Text('Forgot?', style: TextStyle(color: Colors.black, fontSize: 12)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const TextField(
                      obscureText: true, // Hides the text
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        suffixIcon: Icon(Icons.visibility, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Main Login Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Login to Dashboard  →'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR CONTINUE WITH', style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1.0)),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Google Button Placeholder
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF3F4F6),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () {},
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.g_mobiledata, size: 28), // Placeholder for Google G logo
                            SizedBox(width: 8),
                            Text('Google Account', style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Bottom Sign Up Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Don\'t have an account? ', style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                 onTap: () {
                   // Pushes the Registration screen onto the navigation stack
                   Navigator.push(
                     context,
                     MaterialPageRoute(
                       builder: (context) => const RegistrationScreen(),
                     ),
                   );
                 },
                 child: const Text(
                   'Sign up for free',
                   style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                 ),
               ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Footer security note
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: Colors.grey),
                  SizedBox(width: 6),
                  Text('END-TO-END ENCRYPTED SYSTEM', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1.0)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}