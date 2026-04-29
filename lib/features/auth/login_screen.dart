import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 1. THE FORM KEY: This is the brain of your validation
  final _formKey = GlobalKey<FormState>();
  
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _login() async {
    // 2. THE VALIDATION CHECK: Only proceed if the form passes all rules
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // If successful, your AuthWrapper in main.dart will automatically 
        // detect the login and send the user to the Dashboard!
      } on FirebaseAuthException catch (e) {
        // Show Firebase errors (like wrong password) to the user
        String errorMessage = 'Login failed. Please try again.';
        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          errorMessage = 'Incorrect email or password.';
        }
        _showFakeButtonMessage(errorMessage, isError: true);
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // 3. THE "CLICKABLE ELEMENTS" TRICK: Reusable SnackBar function
  void _showFakeButtonMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: isError ? Colors.red.shade800 : Colors.black87,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo & Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.menu_book, color: Colors.white, size: 48),
                ),
                const SizedBox(height: 24),
                const Text('SmartStudy', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 8),
                Text('Elevate your academic workflow', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 48),

                // Main Form Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  // WRAP THE INPUTS IN A FORM WIDGET
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('EMAIL ADDRESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        
                        // EMAIL FIELD WITH VALIDATION
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'name@university.edu',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Email is required';
                            }
                            
                            // 1. Check for standard email format using Regex
                            final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                            if (!emailRegex.hasMatch(value)) {
                              return 'Please enter a valid email format';
                            }

                            // The .edu check has been completely removed!

                            return null; // Passes all tests!
                          },
                        ),
                        
                        const SizedBox(height: 24),
                        
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('PASSWORD', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                            // FAKE BUTTON 1: Forgot Password
                            GestureDetector(
                              onTap: () => _showFakeButtonMessage('Password reset flow coming in v2.0!'),
                              child: const Text('Forgot?', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        
                        // PASSWORD FIELD WITH VALIDATION
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            hintText: 'Enter your password',
                            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: Colors.grey[500]),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _isLoading 
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Login to Dashboard', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                                      SizedBox(width: 8),
                                      Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                // REAL BUTTON 2: Sign Up
                GestureDetector(
                  onTap: () {
                    // This pushes the new Registration Screen onto the screen!
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                    );
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account? ", style: TextStyle(color: Colors.grey, fontSize: 14)),
                      Text("Sign up for free", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black, decoration: TextDecoration.underline)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}