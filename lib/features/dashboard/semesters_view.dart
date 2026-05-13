import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Ensure these paths match your project structure
import '../search/global_search_screen.dart';
import '../notifications/notifications_screen.dart';
import '../courses/add_edit_semester_screen.dart'; // Adjusted path if needed
import 'courses_view.dart'; 

class SemestersView extends StatefulWidget {
  const SemestersView({super.key});

  @override
  State<SemestersView> createState() => _SemestersViewState();
}

class _SemestersViewState extends State<SemestersView> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  // --- FIX: Updated Context checks for production stability ---
  Future<void> _deleteSemester(BuildContext context, String semesterId, String semesterName) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Delete $semesterName?'),
          content: const Text('Are you sure you want to delete this semester? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), 
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true), 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('semesters')
          .doc(semesterId)
          .delete();

      // NEW: Modern context checking for async gaps
      if (!context.mounted) return; 

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$semesterName deleted successfully.')),
      );
    } catch (e) {
      // NEW: Modern context checking for async gaps
      if (!context.mounted) return; 

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting semester: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'SmartStudy',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const GlobalSearchScreen())
            ),
          ),
          IconButton(
            icon: const Badge(
              backgroundColor: Colors.red,
              child: Icon(Icons.notifications_none, color: Colors.black),
            ),
            onPressed: () => Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const NotificationsScreen())
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ACADEMIC JOURNEY HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Academic Journey',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5),
                ),
                Text(
                  '2026 Academic\nYear',
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1.0),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // --- SEMESTER LIST (Real-time from Firestore) ---
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('semesters')
                  .orderBy('startDate', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.black));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildEmptyState();
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final doc = snapshot.data!.docs[index];
                    return _buildSemesterCard(doc);
                  },
                );
              },
            ),

            const SizedBox(height: 32),

            // --- PRIORITY ACTION ---
            const Text(
              'PRIORITY ACTION',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
            ),
            const SizedBox(height: 12),
            _buildPriorityActionCard(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => const AddEditSemesterScreen())
        ),
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSemesterCard(DocumentSnapshot doc) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(20),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SEMESTER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[400], letterSpacing: 1.0)),
                const SizedBox(height: 4),
                Text(doc['name'], style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '${(doc['startDate'] as Timestamp).toDate().year} — Present',
                style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500),
              ),
            ),
            trailing: PopupMenuButton<String>(
              color: Colors.white,
              surfaceTintColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteSemester(context, doc.id, doc['name']);
                }
              },
              itemBuilder: (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, size: 20, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Delete Semester', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CoursesView(
                    semesterId: doc.id,
                    semesterName: doc['name'],
                  ),
                ),
              );
            },
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('View Courses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  Icon(Icons.arrow_forward, size: 18, color: Colors.grey[800]),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPriorityActionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.calendar_today, color: Colors.red, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('View Deadlines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('4 assignments due in the next 72 hours', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Text('Open Schedule', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13)),
                    SizedBox(width: 4),
                    Icon(Icons.chevron_right, size: 16, color: Colors.red),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          children: [
            Icon(Icons.auto_stories_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Start Your Journey', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Add your first semester to begin organizing your academic data.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}