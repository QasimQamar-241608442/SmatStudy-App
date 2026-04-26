import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the currently logged-in user's ID
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        title: const Text('SmartStudy', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.black)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.black)),
          const SizedBox(width: 8),
        ],
      ),
      // Use a FutureBuilder to fetch the user's name from Firestore
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(uid).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }

          // Extract the data we saved during registration
          String fullName = 'Student';
          String email = FirebaseAuth.instance.currentUser!.email ?? '';
          
          if (snapshot.hasData && snapshot.data!.exists) {
            var data = snapshot.data!.data() as Map<String, dynamic>;
            fullName = data['fullName'] ?? 'Student';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 1. Profile Picture & Name
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(24),
                      ),
                      // Swapped the web image for a clean, built-in icon!
                      child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, color: Colors.white, size: 14),
                    )
                  ],
                ),
                const SizedBox(height: 24),
                // DISPLAY REAL NAME!
                Text(fullName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                // DISPLAY REAL EMAIL!
                Text(email, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                const SizedBox(height: 32),

                // 2. GPA & Credits Stats
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CURRENT GPA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                const Text('3.89', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                                Text(' / 4.0', style: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('COMPLETED CREDITS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                            const SizedBox(height: 12),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                const Text('94', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                                Text(' / 120', style: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // 3. Dean's List Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Dean\'s List Status', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Consecutive Semester Achievement', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                        ],
                      ),
                      const Icon(Icons.verified, color: Colors.white, size: 28),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // 4. Settings List
                const Align(alignment: Alignment.centerLeft, child: Text('SETTINGS & PREFERENCES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5))),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    children: [
                      _buildSettingsTile(icon: Icons.person_outline, title: 'Account Settings'),
                      const Divider(height: 1),
                      _buildSettingsTile(icon: Icons.notifications_none, title: 'Notifications', trailingText: '3 unread updates', isRedTrailing: true),
                      const Divider(height: 1),
                      _buildSettingsTile(icon: Icons.help_outline, title: 'Academic Support'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 5. Logout Button - NOW FUNCTIONAL!
                InkWell(
                  onTap: () async {
                    // Tell Firebase to log the user out
                    await FirebaseAuth.instance.signOut();
                    // The AuthWrapper will instantly detect this and kick them to the Login Screen!
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Text('Log out', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 32),
                Text('SMARTSTUDY V2.4.0 • BUILT FOR ACADEMIC EXCELLENCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 0.5)),
                const SizedBox(height: 40),
              ],
            ),
          );
        }
      ),
    );
  }

  // Helper Widget for Settings Items
  Widget _buildSettingsTile({required IconData icon, required String title, String? trailingText, bool isRedTrailing = false}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: Colors.grey[700], size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
          if (trailingText != null) ...[
            Text(trailingText, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isRedTrailing ? Colors.red : Colors.grey[600])),
            const SizedBox(width: 8),
          ],
          Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
        ],
      ),
    );
  }
}