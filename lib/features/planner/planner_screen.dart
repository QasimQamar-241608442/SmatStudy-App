import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 3 tabs: Assignments, Quizzes, Exams
    _tabController = TabController(length: 3, vsync: this); 
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.black,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: 'Assignments'),
            Tab(text: 'Quizzes'),
            Tab(text: 'Exams'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text('Priority Focus', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('2 items require immediate attention', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 24),

// THE GLOBAL REAL-TIME STREAM
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('tasks') // Searches ALL task collections!
                  .where('uid', isEqualTo: uid) // Only gets THIS user's tasks
                  .orderBy('dueDate') // Sorts by closest deadline
                  .snapshots(),
              builder: (context, snapshot) {
                // 1. ADD THIS ERROR CATCHER!
                if (snapshot.hasError) { 
                  return Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16)),
                    child: const Text(
                      'Database Index Missing!\nCheck your VS Code Debug Console for the link to build it.',
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator(color: Colors.black)),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Center(child: CircularProgressIndicator(color: Colors.black)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                    child: const Column(
                      children: [
                        Icon(Icons.done_all, color: Colors.green, size: 48),
                        SizedBox(height: 12),
                        Text('All caught up!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  );
                }

                // If we have data, map it into your beautiful Deadline Cards
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;

                    String title = data['title'] ?? 'Untitled';
                    String type = data['type'] ?? 'Task'; 
                    bool isUrgent = data['isUrgent'] ?? false;
                    
                    Timestamp timestamp = data['dueDate'] as Timestamp;
                    DateTime dueDate = timestamp.toDate();
                    
                    // Format the date string
                    String timeString = '${dueDate.month}/${dueDate.day}/${dueDate.year}';
                    
                    // Logic for the status label (OVERDUE vs URGENT vs UPCOMING)
                    String status = isUrgent ? 'URGENT' : 'UPCOMING';
                    bool isOverdue = dueDate.isBefore(DateTime.now());
                    if (isOverdue) status = 'OVERDUE';

                    return _buildDeadlineCard(
                      status: status,
                      course: type.toUpperCase(), // Using Type as a placeholder for course name for now
                      title: title,
                      timeString: timeString,
                      icon: Icons.access_time,
                      isRedWarning: isUrgent || isOverdue,
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 32),

            // Gamification Stats (From Mockup 14)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.check_circle, color: Colors.grey[700], size: 24),
                        const SizedBox(height: 12),
                        const Text('12', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text('COMPLETED THIS WEEK', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 0.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.trending_up, color: Colors.grey[700], size: 24),
                            const SizedBox(height: 12),
                            const Text('88%', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('EFFICIENCY SCORE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 0.5)),
                          ],
                        ),
                        // The floating '+' button from your mockup
                        Positioned(
                          right: 0,
                          top: 20,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
                            child: const Icon(Icons.add, color: Colors.white, size: 24),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper widget for the Deadline Cards
  Widget _buildDeadlineCard({
    required String status, required String course, required String title, 
    required String timeString, required IconData icon, required bool isRedWarning
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // The colored left edge indicator
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: isRedWarning ? Colors.red : Colors.transparent,
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isRedWarning ? Colors.red : Colors.grey[600], letterSpacing: 0.5)),
                              const SizedBox(width: 8),
                              Text('•', style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                              const SizedBox(width: 8),
                              Text(course, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 0.5)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(icon, size: 14, color: isRedWarning ? Colors.red : Colors.grey[600]),
                              const SizedBox(width: 6),
                              Text(timeString, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isRedWarning ? Colors.red : Colors.grey[600])),
                            ],
                          )
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.chevron_right, color: Colors.black, size: 20),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}