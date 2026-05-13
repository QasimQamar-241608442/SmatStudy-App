import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../notifications/notifications_screen.dart';
import 'account_settings_screen.dart'; 

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF9FAFB);

    // Get initials for the avatar (e.g., "Qasim Qamar" -> "QQ")
    String initials = "ST";
    if (user != null && user!.displayName != null && user!.displayName!.isNotEmpty) {
      List<String> names = user!.displayName!.split(" ");
      if (names.length >= 2) {
        initials = "${names[0][0]}${names[1][0]}".toUpperCase();
      } else {
        initials = names[0].substring(0, 1).toUpperCase();
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Settings', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- PROFILE QUICK LINK ---
            Row(
              children: [
                Container(
                  width: 60, height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B4EFF).withValues(alpha: 0.2), // Soft Purple
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials, 
                      style: const TextStyle(color: Color(0xFF6B4EFF), fontWeight: FontWeight.bold, fontSize: 20)
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.displayName ?? 'Student', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(user?.email ?? '', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 32),

            // --- GROUP 1: ACCOUNT ---
            _buildSectionHeader('ACCOUNT & DATA'),
            _buildSettingsGroup(
              children: [
                _buildSettingsTile(
                  icon: Icons.person_outline,
                  title: 'Account',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSettingsScreen())),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- GROUP 2: PREFERENCES ---
            _buildSectionHeader('APP SETTINGS'),
            _buildSettingsGroup(
              children: [
                _buildSettingsTile(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- GROUP 3: ABOUT ---
            _buildSectionHeader('SYSTEM'),
            _buildSettingsGroup(
              children: [
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'About SmartStudy',
                  trailingText: 'v1.0.0', // Updated for your first launch!
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('SmartStudy is up to date.'), behavior: SnackBarBehavior.floating),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 16.0),
      child: Text(
        title, 
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.2)
      ),
    );
  }

  Widget _buildSettingsGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon, 
    required String title, 
    String? subtitle, 
    String? trailingText, 
    Color? iconColor,
    required VoidCallback onTap
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: iconColor ?? Colors.black87, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      subtitle: subtitle != null ? Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingText != null) 
            Text(trailingText, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[400])),
          const SizedBox(width: 4),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }
}