import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'courses_view.dart';
import '../courses/add_edit_semester_screen.dart';

class SemestersView extends StatelessWidget {
  const SemestersView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Priority Action Card
          const Text('Priority Action', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 2), 
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
                  child: Icon(Icons.calendar_today, color: Colors.red[400]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('View Deadlines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('4 assignments due in the next 72 hours', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('Open Schedule', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right, color: Colors.red[700], size: 16),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 40),

          // 2. Academic Journey Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Academic\nJourney', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2)),
              Text('2026 Academic\nYear', textAlign: TextAlign.right, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),

          // 3. REAL-TIME DATABASE STREAM
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('semesters')
                .orderBy('startDate', descending: false)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: Colors.black));
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text('No semesters added yet. Click below to start!', style: TextStyle(color: Colors.grey)),
                );
              }

              return ListView.builder(
                shrinkWrap: true, 
                physics: const NeverScrollableScrollPhysics(), 
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var doc = snapshot.data!.docs[index];
                  var data = doc.data() as Map<String, dynamic>;
                  
                  String name = data['name'] ?? 'Unnamed Semester';
                  
                  Timestamp? start = data['startDate'];
                  Timestamp? end = data['endDate'];
                  String details = 'Dates not set';
                  
                  if (start != null && end != null) {
                    DateTime startDate = start.toDate();
                    DateTime endDate = end.toDate();
                    details = '${startDate.month}/${startDate.day}/${startDate.year}  —  ${endDate.month}/${endDate.day}/${endDate.year}';
                  }

                  return _buildSemesterCard(
                    context: context,
                    status: 'SEMESTER',
                    title: name,
                    details: details,
                    tags: [], 
                    progress: 0.0,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CoursesView(
                            semesterId: doc.id, 
                            semesterName: name, 
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
          
          // 4. Add Semester Button
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditSemesterScreen()));
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), 
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: const Icon(Icons.add, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  const Text('Add Semester', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Plan your next academic\nmilestone', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Helper Widget for Semester Cards
  Widget _buildSemesterCard({
    required BuildContext context,
    required String status,
    required String title,
    required String details,
    required List<String> tags,
    required double progress,
    required VoidCallback onTap, 
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
              const Icon(Icons.more_vert, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(details, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 16),
          
          if (tags.isNotEmpty)
            Row(
              children: tags.map((tag) => Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              )).toList(),
            ),
            
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),
          
          InkWell(
            onTap: onTap, 
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('View Courses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}