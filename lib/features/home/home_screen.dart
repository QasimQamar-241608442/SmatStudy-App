import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../search/global_search_screen.dart';
import '../notifications/notifications_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Get the current user ID
    final String uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        title: const Text('SmartStudy', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
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
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. FOCUS TODAY HERO CARD (Still dummy data for now)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
                ]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(6)),
                    child: const Text('FOCUS TODAY', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ),
                  const SizedBox(height: 16),
                  const Text('Advanced\nEconometrics', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.1)),
                  const SizedBox(height: 12),
                  Text(
                    'Preparation for mid-term review. Chapter 4: Instrumental Variables and Two-Stage Least Squares.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: const Row(
                          children: [
                            Text('Resume Study', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('NEXT SESSION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 2),
                            Text('14:00 • Library\nRoom 4B', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800], height: 1.2)),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // 2. AI INSIGHTS CARD
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Colors.black, size: 20),
                      const SizedBox(width: 8),
                      Text('AI Insights', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[800])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '"Your concentration peaks between 10 AM and 12 PM. Schedule your hardest math problem sets for tomorrow morning for 24% better retention."',
                    style: TextStyle(fontSize: 15, height: 1.5, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('VIEW DETAILED ANALYSIS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.grey[600])),
                      const SizedBox(width: 4),
                      Icon(Icons.chevron_right, size: 14, color: Colors.grey[600]),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 24),

            // 3. WEEKLY PROGRESS
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('WEEKLY PROGRESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      const Text('72', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                      const Text('%', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const Spacer(),
                      Text('Target: 85% by Sunday', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Stack(
                    children: [
                      Container(height: 8, decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4))),
                      FractionallySizedBox(
                        widthFactor: 0.72,
                        child: Container(height: 8, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(4))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _buildBar(height: 20, color: Colors.grey[300]!),
                      const SizedBox(width: 4),
                      _buildBar(height: 30, color: Colors.grey[300]!),
                      const SizedBox(width: 4),
                      _buildBar(height: 45, color: Colors.grey[300]!),
                      const SizedBox(width: 4),
                      _buildBar(height: 60, color: Colors.black),
                      const SizedBox(width: 4),
                      _buildBar(height: 15, color: Colors.grey[200]!),
                      const SizedBox(width: 4),
                      _buildBar(height: 15, color: Colors.grey[200]!),
                      const SizedBox(width: 4),
                      _buildBar(height: 15, color: Colors.grey[200]!),
                    ],
                  )
                ],
              ),
            ),
            
            const SizedBox(height: 32),

            // 4. TODAY'S SCHEDULE (Still dummy data for now)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TODAY\'S SCHEDULE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.grey)),
                Text('Monday, Oct 24', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[800])),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  _buildTimelineRow(
                    time: '09:00', status: 'START', title: 'Intro to Behavioral\nPsychology', subtitle: 'Mon/Wed/Fri • Room 201 • Section A', 
                    isPast: true, trailing: const Icon(Icons.more_vert, color: Colors.grey, size: 20)
                  ),
                  const Padding(padding: EdgeInsets.only(left: 80), child: Divider(height: 1)),
                  _buildTimelineRow(
                    time: '11:30', status: 'NOW', title: 'Advanced\nEconometrics', subtitle: 'Mon/Wed • Hall 405 • Section B', 
                    isActive: true, trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)), child: const Text('IN PROGRESS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)))
                  ),
                  const Padding(padding: EdgeInsets.only(left: 80), child: Divider(height: 1)),
                  _buildTimelineRow(
                    time: '15:00', status: 'LATER', title: 'Statistical Computing\nLab', subtitle: 'Monday • Lab 2 • Section C', 
                    isFuture: true, trailing: Icon(Icons.lock_outline, color: Colors.grey[400], size: 20)
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 5. CRITICAL DEADLINES (NOW REAL DATA!)
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 18),
                const SizedBox(width: 8),
                const Text('CRITICAL DEADLINES', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 16),
            
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('tasks')
                  .where('uid', isEqualTo: uid)
                  .orderBy('dueDate')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.black));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                    child: const Text('No upcoming deadlines. Great job!', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  );
                }

                // Filter out completed tasks using Dart logic
                var activeTasks = snapshot.data!.docs.where((doc) {
                  var data = doc.data() as Map<String, dynamic>;
                  return data['isCompleted'] == false || data['isCompleted'] == null;
                }).toList();

                // Take only the top 3 most urgent tasks
                var top3Tasks = activeTasks.take(3).toList();

                if (top3Tasks.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                    child: const Text('All caught up!', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  );
                }

                return Column(
                  children: top3Tasks.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    String title = data['title'] ?? 'Untitled';
                    String type = data['type'] ?? 'Task';
                    bool isUrgent = data['isUrgent'] ?? false;
                    
                    Timestamp timestamp = data['dueDate'] as Timestamp;
                    DateTime dueDate = timestamp.toDate();
                    
                    // Simple Date formatting
                    String dateStr = '${dueDate.month}/${dueDate.day}/${dueDate.year}';
                    bool isOverdue = dueDate.isBefore(DateTime.now());
                    
                    String statusLabel = 'UPCOMING';
                    if (isOverdue) {
                      statusLabel = 'OVERDUE';
                    } else if (isUrgent) {
                      statusLabel = 'URGENT';
                    }

                    return _buildDeadlineCard(
                      title: title,
                      subtitle: type.toUpperCase(), // Using type as a stand-in for course name
                      dateStr: dateStr,
                      statusLabel: statusLabel,
                      isOverdue: isOverdue,
                    );
                  }).toList(),
                );
              },
            ),
            
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildBar({required double height, required Color color}) {
    return Expanded(
      child: Container(
        height: height,
        decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(2))),
      ),
    );
  }

  Widget _buildTimelineRow({
    required String time, required String status, required String title, required String subtitle, 
    bool isActive = false, bool isPast = false, bool isFuture = false, required Widget trailing
  }) {
    Color textColor = isFuture ? Colors.grey[400]! : Colors.black;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(time, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textColor)),
                  const SizedBox(height: 2),
                  Text(status, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isFuture ? Colors.grey[300] : Colors.grey)),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(width: 3, decoration: BoxDecoration(color: isActive ? Colors.black : Colors.transparent, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: textColor, height: 1.2)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 12, color: isFuture ? Colors.grey[400] : Colors.grey[600])),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineCard({
    required String title, required String subtitle, required String dateStr, required String statusLabel, bool isOverdue = false
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(width: 4, decoration: const BoxDecoration(color: Colors.red, borderRadius: BorderRadius.horizontal(left: Radius.circular(12)))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        if (isOverdue)
                          Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(4)), child: Text('OVERDUE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.red[700])))
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(dateStr, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isOverdue ? Colors.red : Colors.grey[800])),
                        Text(isOverdue ? 'SUBMIT NOW' : statusLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isOverdue ? Colors.black : Colors.grey[500], decoration: isOverdue ? TextDecoration.underline : TextDecoration.none)),
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}