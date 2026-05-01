import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../notifications/notifications_screen.dart';
import 'account_settings_screen.dart'; // The name/email editor we built earlier

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
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: NetworkImage('https://ui-avatars.com/api/?name=User&background=random&size=200'),
                      fit: BoxFit.cover,
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

            // --- GROUP 1: ACCOUNT & CLOUD ---
            _buildSectionHeader('ACCOUNT & DATA'),
            _buildSettingsGroup(
              children: [
                _buildSettingsTile(
                  icon: Icons.person_outline,
                  title: 'Account',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountSettingsScreen())),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.cloud_sync_outlined,
                  title: 'Cloud Sync',
                  trailingText: 'Enabled',
                  onTap: () => _showComingSoon(context, 'Cloud Sync'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.backup_outlined,
                  title: 'Backup and restore',
                  onTap: () => _showComingSoon(context, 'Backup & Restore'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- GROUP 2: PLANNER & SCHEDULE ---
            _buildSectionHeader('PLANNER & SCHEDULE'),
            _buildSettingsGroup(
              children: [
                _buildSettingsTile(
                  icon: Icons.notifications_none,
                  title: 'Notifications',
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.calendar_view_week_outlined,
                  title: 'Timetable and Calendar',
                  onTap: () => _showComingSoon(context, 'Timetable Layout'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.school_outlined,
                  title: 'Semesters & Terms',
                  onTap: () => _showComingSoon(context, 'Term Management'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.beach_access_outlined,
                  title: 'Holidays',
                  onTap: () => _showComingSoon(context, 'Holidays'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- GROUP 3: APP PREFERENCES ---
            _buildSectionHeader('PREFERENCES'),
            _buildSettingsGroup(
              children: [
                _buildSettingsTile(
                  icon: Icons.palette_outlined,
                  title: 'Look and appearance',
                  trailingText: 'Default',
                  onTap: () => _showComingSoon(context, 'Themes'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.tune,
                  title: 'Advanced',
                  onTap: () => _showComingSoon(context, 'Advanced Settings'),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- GROUP 4: BILLING & SUPPORT ---
            _buildSectionHeader('BILLING AND SUPPORT'),
            _buildSettingsGroup(
              children: [
                _buildSettingsTile(
                  icon: Icons.star_border_rounded,
                  title: 'Premium',
                  subtitle: 'Manage subscriptions and payments',
                  iconColor: Colors.amber.shade700,
                  onTap: () => _showComingSoon(context, 'Premium Upgrade'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.desktop_mac_outlined,
                  title: 'Web App',
                  subtitle: 'Access your data from your PC or Mac',
                  onTap: () => _showComingSoon(context, 'Web Companion'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.rate_review_outlined,
                  title: 'Write a review',
                  onTap: () => _showComingSoon(context, 'App Store Review'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.support_agent_outlined,
                  title: 'Contact us',
                  onTap: () => _showComingSoon(context, 'Support Desk'),
                ),
                _buildDivider(),
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'About SmartStudy',
                  trailingText: 'v2.4.0',
                  onTap: () => _showComingSoon(context, 'About'),
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

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56, endIndent: 16, color: Color(0xFFEEEEEE));
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

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature settings coming in Phase 3!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      )
    );
  }
}