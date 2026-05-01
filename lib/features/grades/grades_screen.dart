import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final String uid = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // --- TAB 1: FINAL COURSE GRADES ---
  Widget _buildCourseGradesTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).collection('semesters').snapshots(),
      builder: (context, semesterSnapshot) {
        if (semesterSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.black));
        }

        if (!semesterSnapshot.hasData || semesterSnapshot.data!.docs.isEmpty) {
          return _buildEmptyState('No courses found', 'Add courses in the Courses tab first.');
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: semesterSnapshot.data!.docs.length,
          itemBuilder: (context, semIndex) {
            final semDoc = semesterSnapshot.data!.docs[semIndex];
            final semName = semDoc['name']?.toString().toUpperCase() ?? 'SEMESTER';
            
            return StreamBuilder<QuerySnapshot>(
              stream: semDoc.reference.collection('courses').snapshots(),
              builder: (context, courseSnapshot) {
                if (!courseSnapshot.hasData || courseSnapshot.data!.docs.isEmpty) return const SizedBox();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PREMIUM TWEAK: Letter-spaced, bold section headers
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12, left: 4),
                      child: Text(semName, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.5)),
                    ),
                    ...courseSnapshot.data!.docs.map((courseDoc) {
                      final courseData = courseDoc.data() as Map<String, dynamic>;
                      final currentGrade = courseData['grade'] ?? '-';

                      return _buildPremiumCard(
                        onTap: () => _showCourseGradePicker(semDoc.id, courseDoc.id, courseData['code'] ?? 'Course', currentGrade),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(courseData['code'] ?? 'Course', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('${courseData['creditHours'] ?? 3} Credits', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              ],
                            ),
                            // PREMIUM TWEAK: Dynamic Badge Styling
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: currentGrade == '-' ? Colors.white : Colors.black, 
                                border: Border.all(color: currentGrade == '-' ? Colors.grey.shade300 : Colors.black, width: 1.5),
                                borderRadius: BorderRadius.circular(20)
                              ),
                              child: Text(
                                currentGrade == '-' ? 'Add Grade' : currentGrade, 
                                style: TextStyle(fontWeight: FontWeight.bold, color: currentGrade == '-' ? Colors.black : Colors.white)
                              ),
                            )
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 24),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  void _showCourseGradePicker(String semId, String courseId, String courseCode, String currentGrade) {
    final List<String> grades = ['A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'F', 'Clear Grade'];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Final Grade for $courseCode', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: grades.length,
                    itemBuilder: (context, index) {
                      final grade = grades[index];
                      return ListTile(
                        title: Text(grade, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: grade == 'Clear Grade' ? Colors.red : Colors.black, fontSize: 16)),
                        onTap: () async {
                          Navigator.pop(context);
                          await FirebaseFirestore.instance
                              .collection('users').doc(uid)
                              .collection('semesters').doc(semId)
                              .collection('courses').doc(courseId)
                              .update({'grade': grade == 'Clear Grade' ? FieldValue.delete() : grade});
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  // --- TAB 2: ASSIGNMENT SCORES ---
  Widget _buildTaskScoresTab() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchAllTasks(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Colors.black));
        if (!snapshot.hasData || snapshot.data!.isEmpty) return _buildEmptyState('No assignments yet', 'Tasks linked to courses will appear here.');

        final tasks = snapshot.data!;

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            final score = task['score'];

            return _buildPremiumCard(
              onTap: () => _showTaskActionSheet(task),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                    child: Icon(task['type'].toString().contains('Exam') ? Icons.assignment : Icons.menu_book, color: Colors.black),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text('${task['courseCode']} • ${task['type']}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                  ),
                  // PREMIUM TWEAK: Soft green badge for scores, sleek outline for empty states
                  if (score != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Text(score, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: Colors.green.shade700)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                      child: Text('Add Score', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey.shade600)),
                    )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchAllTasks() async {
    List<Map<String, dynamic>> allTasks = [];
    final semestersSnapshot = await FirebaseFirestore.instance.collection('users').doc(uid).collection('semesters').get();

    for (var sem in semestersSnapshot.docs) {
      final coursesSnapshot = await sem.reference.collection('courses').get();
      for (var course in coursesSnapshot.docs) {
        final courseCode = course.data()['code'] ?? 'Course';
        final tasksSnapshot = await course.reference.collection('tasks').get();
        
        for (var task in tasksSnapshot.docs) {
          final data = task.data();
          allTasks.add({
            'taskId': task.id,
            'courseId': course.id,
            'semId': sem.id,
            'courseCode': courseCode,
            'title': data['title'] ?? 'Task',
            'type': data['type'] ?? 'Assignment',
            'score': data['score'], 
            'dueDate': data['dueDate'],
          });
        }
      }
    }
    
    allTasks.sort((a, b) {
      if (a['dueDate'] == null || b['dueDate'] == null) return 0;
      return (b['dueDate'] as Timestamp).compareTo(a['dueDate'] as Timestamp);
    });

    return allTasks;
  }

  void _showTaskActionSheet(Map<String, dynamic> task) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(task['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                
                ListTile(
                  leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.score, color: Colors.black)),
                  title: const Text('Add / Edit Marks', style: TextStyle(fontWeight: FontWeight.bold)),
                  onTap: () {
                    Navigator.pop(context);
                    _showAddScoreDialog(task);
                  },
                ),
                
                ListTile(
                  leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.delete_outline, color: Colors.red)),
                  title: const Text('Delete Task', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  onTap: () async {
                    Navigator.pop(context);
                    await FirebaseFirestore.instance
                        .collection('users').doc(uid)
                        .collection('semesters').doc(task['semId'])
                        .collection('courses').doc(task['courseId'])
                        .collection('tasks').doc(task['taskId']).delete();
                    setState(() {}); 
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  void _showAddScoreDialog(Map<String, dynamic> task) {
    final TextEditingController scoreController = TextEditingController(text: task['score']);
    
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Enter Marks', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: scoreController,
            decoration: InputDecoration(
              hintText: 'e.g., 85/100 or 92%',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
            ),
            ElevatedButton(
              onPressed: () async {
                final newScore = scoreController.text.trim();
                Navigator.pop(context);
                
                await FirebaseFirestore.instance
                    .collection('users').doc(uid)
                    .collection('semesters').doc(task['semId'])
                    .collection('courses').doc(task['courseId'])
                    .collection('tasks').doc(task['taskId'])
                    .update({'score': newScore.isEmpty ? FieldValue.delete() : newScore});
                
                setState(() {}); 
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF4F6F8);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Text('Academic Record', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.grey[400],
          indicatorColor: Colors.black,
          indicatorWeight: 3,
          // PREMIUM TWEAK: Rounded tab indicators
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: 'Course Grades'),
            Tab(text: 'Task Scores'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCourseGradesTab(),
          _buildTaskScoresTab(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPremiumCard({required Widget child, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: child,
      ),
    );
  }
}