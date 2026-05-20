import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../notifications/notifications_screen.dart';
import 'account_settings_screen.dart'; 

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  // --- THE DEGREE EDITING LOGIC ---
  Future<void> _editDegreeDialog(String currentDegree) async {
    final TextEditingController degreeController = TextEditingController(
      text: currentDegree == 'Add your degree' ? '' : currentDegree
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Update Degree', style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: degreeController,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g. B.S. Mechanical Engineering',
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            onPressed: () async {
              if (degreeController.text.trim().isNotEmpty && user != null) {
                // Update or create the degree field in the user's Firestore document
                await FirebaseFirestore.instance.collection('users').doc(user!.uid).set(
                  {'degree': degreeController.text.trim()},
                  SetOptions(merge: true) // Merge ensures we don't overwrite existing data like name/email
                );
              }
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    // Your AuthWrapper will automatically handle routing back to the Login Screen!
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF9FAFB);

    if (user == null) return const Center(child: CircularProgressIndicator(color: Colors.black));

    // Generate Initials
    String initials = "US";
    if (user!.displayName != null && user!.displayName!.isNotEmpty) {
      List<String> names = user!.displayName!.split(" ");
      initials = names.length >= 2 
          ? "${names[0][0]}${names[1][0]}".toUpperCase() 
          : names[0].substring(0, 1).toUpperCase();
    }

    // Generate a mock student ID from the Firebase UID (first 10 chars)
    String studentId = user!.uid.substring(0, 10).toUpperCase();

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text('SmartStudy', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
          IconButton(
            icon: const Badge(backgroundColor: Colors.red, child: Icon(Icons.notifications_none, color: Colors.black)), 
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
          ),
        ],
      ),
      // --- REAL-TIME FIRESTORE LISTENER ---
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.black));
          }

          // Extract data from Firestore, defaulting if it doesn't exist yet
          Map<String, dynamic>? userData = snapshot.data?.data() as Map<String, dynamic>?;
          String currentDegree = userData?['degree'] ?? 'Add your degree';

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: Column(
              children: [
                // --- AVATAR ---
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(color: Colors.blueGrey.shade300, shape: BoxShape.circle),
                      child: Center(child: Text(initials, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 36))),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, color: Colors.white, size: 16),
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // --- NAME & DYNAMIC DEGREE ---
                Text(user?.displayName ?? 'Student', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                
                // Wrap the ID/Degree in an InkWell so the user can tap it to edit!
                InkWell(
                  onTap: () => _editDegreeDialog(currentDegree),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('ID: $studentId • $currentDegree', style: TextStyle(color: Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)),
                        const SizedBox(width: 6),
                        Icon(Icons.edit, size: 14, color: Colors.grey[400]), // Small hint that it's clickable
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // --- ACADEMIC STATS ---
                Row(
                  children: [
                    Expanded(child: _buildStatCard('CURRENT GPA', '— / 4.0')),
                    const SizedBox(width: 16),
                    Expanded(child: _buildStatCard('COMPLETED CREDITS', '0 / 120')),
                  ],
                ),
                const SizedBox(height: 40),

                // --- SETTINGS LIST ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('SETTINGS & PREFERENCES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.2)),
                ),
                const SizedBox(height: 12),
                Container(
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: Icons.settings_outlined,
                        title: 'App Settings',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSettingsScreen())),
                      ),
                      const Divider(height: 1, indent: 60),
                      _buildSettingsTile(
                        icon: Icons.notifications_none,
                        title: 'Notifications',
                        subtitle: 'Manage alerts',
                        subtitleColor: Colors.red,
                        trailingText: 'View',
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // --- LOG OUT BUTTON ---
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _signOut,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade200),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text('Log out', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                
                const SizedBox(height: 32),
                Text('SMARTSTUDY V1.0.0 • BUILT FOR ACADEMIC EXCELLENCE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1.0)),
                const SizedBox(height: 40),
              ],
            ),
          );
        }
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 0.5)),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon, 
    required String title, 
    String? subtitle, 
    Color? subtitleColor,
    String? trailingText, 
    required VoidCallback onTap
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: subtitleColor ?? Colors.grey[600], fontSize: 13, fontWeight: FontWeight.w500)) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) 
            Text(trailingText, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[500])),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }
}