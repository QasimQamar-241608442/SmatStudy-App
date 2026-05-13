import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Ensure these paths match where you saved the files in your project!
import '../search/global_search_screen.dart';
import '../notifications/notifications_screen.dart';
import 'settings_screen.dart'; // The new Master Settings Hub

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  
  bool _isLoading = true;
  double _cumulativeGPA = 0.0;
  int _earnedCredits = 0;
  int _totalRequiredCredits = 120; // Default, can be changed by the user!

  @override
  void initState() {
    super.initState();
    _fetchUserDataAndCalculateGPA();
  }

  // --- THE DATA ENGINE ---
  Future<void> _fetchUserDataAndCalculateGPA() async {
    if (user == null) return;

    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      
      // 1. Fetch user preferences (like custom required credits)
      final userDoc = await userRef.get();
      if (userDoc.exists && userDoc.data() != null) {
        final data = userDoc.data() as Map<String, dynamic>;
        if (data.containsKey('requiredCredits')) {
          _totalRequiredCredits = data['requiredCredits'];
        }
      }

      // 2. Fetch all semesters and calculate GPA / Earned Credits
      final semestersSnapshot = await userRef.collection('semesters').get();

      double totalQualityPoints = 0.0;
      int calculatedCredits = 0;

      for (var semester in semestersSnapshot.docs) {
        final coursesSnapshot = await semester.reference.collection('courses').get();
        
        for (var course in coursesSnapshot.docs) {
          final data = course.data();
          final int credits = data['creditHours'] ?? 3; 
          final String? grade = data['grade']; 

          // Only calculate courses that have a final grade
          if (grade != null && grade.isNotEmpty) {
            double gradePoint = _convertGradeToPoints(grade);
            totalQualityPoints += (gradePoint * credits);
            calculatedCredits += credits;
          }
        }
      }

      if (mounted) {
        setState(() {
          _cumulativeGPA = calculatedCredits > 0 ? (totalQualityPoints / calculatedCredits) : 0.0;
          _earnedCredits = calculatedCredits;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  double _convertGradeToPoints(String grade) {
    switch (grade.toUpperCase().trim()) {
      case 'A+': return 4.0;
      case 'A':  return 4.0;
      case 'A-': return 3.7;
      case 'B+': return 3.3;
      case 'B':  return 3.0;
      case 'B-': return 2.7;
      case 'C+': return 2.3;
      case 'C':  return 2.0;
      case 'C-': return 1.7;
      case 'D+': return 1.3;
      case 'D':  return 1.0;
      case 'F':  return 0.0;
      default:   return 0.0;
    }
  }

  // --- THE CREDIT EDITOR ---
  void _showEditCreditsDialog() {
    final TextEditingController creditsController = TextEditingController(text: _totalRequiredCredits.toString());
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Required Credits', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Set the total credits required to complete your specific degree program.', style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 16),
              TextField(
                controller: creditsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'e.g., 120',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
            ),
            ElevatedButton(
              onPressed: () async {
                final newValue = int.tryParse(creditsController.text.trim());
                if (newValue != null && newValue > 0) {
                  Navigator.pop(context);
                  setState(() => _totalRequiredCredits = newValue);
                  
                  // Save to Firebase!
                  await FirebaseFirestore.instance.collection('users').doc(user!.uid)
                      .set({'requiredCredits': newValue}, SetOptions(merge: true));
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF9FAFB);
    final String displayName = user?.displayName ?? 'Student';
    // Generate a fallback ID for the UI
    final String studentId = user?.uid.substring(0, 8).toUpperCase() ?? 'ST-9842';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text('SmartStudy', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black), 
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GlobalSearchScreen())),
          ),
          IconButton(
            icon: const Badge(backgroundColor: Colors.red, child: Icon(Icons.notifications_none, color: Colors.black)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.black))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- 1. PREMIUM AVATAR HEADER ---
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          // Placeholder image
                          image: NetworkImage('https://ui-avatars.com/api/?name=User&background=random&size=200'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle, border: Border.all(color: bgColor, width: 3)),
                      child: const Icon(Icons.edit, color: Colors.white, size: 14),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Text(displayName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
                const SizedBox(height: 4),
                Text('ID: 2024-$studentId • B.S. Computer Science', style: TextStyle(fontSize: 13, color: Colors.grey[700], fontWeight: FontWeight.w500)),
                const SizedBox(height: 32),

                // --- 2. THE STATS GRID ---
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'CURRENT GPA',
                        value: _cumulativeGPA > 0 ? _cumulativeGPA.toStringAsFixed(2) : '--',
                        total: '/ 4.0',
                        onTap: null, // GPA isn't manually editable
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildStatCard(
                        title: 'COMPLETED CREDITS',
                        value: _earnedCredits.toString(),
                        total: '/ $_totalRequiredCredits',
                        onTap: _showEditCreditsDialog, // Make this clickable!
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),

                // --- 3. SETTINGS & PREFERENCES BLOCK ---
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('SETTINGS & PREFERENCES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.settings_outlined, 
                        title: 'App Settings',
                        onTap: () async {
                          // Wait for the settings screen to close, then refresh the profile to reflect any name changes!
                          await Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
                          setState(() {}); 
                        }
                      ),
                      const Divider(height: 1, indent: 60),
                      _buildSettingsTile(
                        icon: Icons.notifications_none, 
                        title: 'Notifications',
                        subtitle: 'Manage alerts',
                        trailingText: 'View',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // --- 4. THE LOGOUT BUTTON ---
                GestureDetector(
                  onTap: _signOut,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Text('Log out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // --- 5. APP FOOTER ---
                Text(
                  'SMARTSTUDY V1.0.0 • BUILT FOR ACADEMIC EXCELLENCE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1.0),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
    );
  }

  // Custom Stat Card Widget
  Widget _buildStatCard({required String title, required String value, required String total, required VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 0.5)),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(value, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, height: 1.0)),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(total, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[500])),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Custom Settings Tile Widget
  Widget _buildSettingsTile({required IconData icon, required String title, String? subtitle, String? trailingText, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600)) : null,
      trailing: trailingText != null 
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(trailingText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500], decoration: TextDecoration.underline)),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right, color: Colors.grey),
              ],
            )
          : const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}