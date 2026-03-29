import 'package:flutter/material.dart';

class RegistrationScreen extends StatelessWidget {
  const RegistrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              
              // Top Icon
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
                'Elevate your academic journey with Quiet\nAuthority.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 32),

              // The Form Card
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
                    const Text(
                      'Create Account',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Join the community of structured learners.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 24),

                    // Full Name Field
                    const Text('FULL NAME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    const TextField(
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(hintText: 'Alex Rivera'),
                    ),
                    const SizedBox(height: 16),

                    // Email Field
                    const Text('EMAIL ADDRESS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    const TextField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(hintText: 'alex@university.edu'),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    const Text('PASSWORD', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    const TextField(
                      obscureText: true,
                      decoration: InputDecoration(hintText: '••••••••'),
                    ),
                    const SizedBox(height: 16),

                    // Confirm Password Field
                    const Text('CONFIRM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    const TextField(
                      obscureText: true,
                      decoration: InputDecoration(hintText: '••••••••'),
                    ),
                    const SizedBox(height: 32),

                    // Main Create Account Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Create Account'),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Divider
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey[300])),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text('OR REGISTER WITH', style: TextStyle(color: Colors.grey, fontSize: 11, letterSpacing: 1.0)),
                        ),
                        Expanded(child: Divider(color: Colors.grey[300])),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Social Buttons Row
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF3F4F6),
                              foregroundColor: Colors.black,
                              elevation: 0,
                            ),
                            onPressed: () {},
                            icon: const Icon(Icons.account_circle_outlined, size: 20),
                            label: const Text('Google', style: TextStyle(fontSize: 13)),
                          ),
                        ),
                        const SizedBox(width: 12), // Spacing between buttons
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF3F4F6),
                              foregroundColor: Colors.black,
                              elevation: 0,
                            ),
                            onPressed: () {},
                            icon: const Icon(Icons.work_outline, size: 20),
                            label: const Text('SSO', style: TextStyle(fontSize: 13)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Bottom Login Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account? ', style: TextStyle(color: Colors.grey)),
                  GestureDetector(
                    // Navigator.pop returns the user to the previous screen in the stack
                    onTap: () => Navigator.pop(context), 
                    child: const Text(
                      'Back to Login',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}