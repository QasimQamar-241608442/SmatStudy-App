import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_edit_task_screen.dart';
import 'course_ai_screen.dart'; 
import 'add_edit_course_screen.dart'; // REQUIRED: So we can navigate to the edit screen!

class CourseDetailsScreen extends StatelessWidget {
  final String semesterId;
  final String courseId;
  final Map<String, dynamic> courseData;

  const CourseDetailsScreen({
    super.key,
    required this.semesterId,
    required this.courseId,
    required this.courseData,
  });

  // The Deletion Engine
  Future<void> _deleteCourse(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white, // Ensure dialog is also pure white
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Delete Course?'),
          content: const Text('Are you sure you want to delete this course? This action cannot be undone and will remove all associated tasks.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), 
              style: TextButton.styleFrom(foregroundColor: Colors.grey),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true), 
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Delete', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('semesters')
          .doc(semesterId)
          .collection('courses')
          .doc(courseId)
          .delete();

      if (context.mounted) {
        Navigator.pop(context); // Go back to the list
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Course deleted successfully.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting course: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    
    // Safely extract all our awesome database fields!
    final String code = courseData['code'] ?? '';
    final String title = courseData['title'] ?? 'Untitled Course';
    final String professor = courseData['professor'] ?? 'Not specified';
    final String location = courseData['location'] ?? 'Not specified';
    final String section = courseData['section'] ?? '';
    final int creditHours = courseData['creditHours'] ?? 3;
    final List<dynamic> sessions = courseData['sessions'] ?? [];

    String subtitle = code;
    if (section.isNotEmpty) subtitle += ' • Sec $section';
    subtitle += ' • $creditHours Credits';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('SmartStudy', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          PopupMenuButton<String>(
            // --- FIX 1: FORCE PURE WHITE BACKGROUND ---
            color: Colors.white,
            surfaceTintColor: Colors.white, 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            // ------------------------------------------
            onSelected: (value) async {
              if (value == 'delete') {
                _deleteCourse(context);
              } else if (value == 'edit') {
                // --- FIX 2: PROPER ROUTING TO THE EDIT SCREEN ---
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditCourseScreen(
                      semesterId: semesterId,
                      courseId: courseId, // Triggers Edit Mode
                      existingData: courseData, // Passes the data to pre-fill the form
                    ),
                  ),
                );
                
                // Once we return from the edit screen, pop this details screen
                // so the user returns to the main list which will auto-refresh with the new data!
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined, size: 20, color: Colors.black),
                    SizedBox(width: 12),
                    Text('Edit Course'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete Course', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The Hero Header
            Text(title, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, height: 1.1)),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(fontSize: 15, color: Colors.grey[700], fontWeight: FontWeight.w500)),
            const SizedBox(height: 24),
            
            // Mock Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 12)),
                    child: const Text('Join Lecture', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), side: BorderSide(color: Colors.grey.shade300)),
                    icon: const Icon(Icons.download_outlined, size: 18, color: Colors.black),
                    label: const Text('Syllabus', style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),

            // THE AI TUTOR BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseAiScreen(
                        courseId: courseId,
                        courseName: title, 
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B4EFF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                label: Text('Open $code AI Tutor', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
            
            const SizedBox(height: 40),

            // Schedule & Venue
            const Text('Schedule & Venue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  if (sessions.isEmpty)
                    const Text('No schedule added.', style: TextStyle(color: Colors.grey))
                  else
                    ...sessions.map((session) => Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.access_time_filled, color: Colors.grey[400], size: 20),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Time & Frequency', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                const SizedBox(height: 2),
                                Text('${session['day']}\n${session['start']} — ${session['end']}', style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                  
                  const Divider(height: 24),
                  
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[400], size: 20),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(location, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Instructor Profile
            const Text('Instructor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.person, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(professor, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text('Course Instructor', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                )
              ],
            ),
            
            const SizedBox(height: 40),

            // Upcoming Tasks 
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Upcoming Assignments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEditTaskScreen(
                          semesterId: semesterId, 
                          courseId: courseId,     
                        ),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap), 
                  child: const Text('+ Add', style: TextStyle(fontWeight: FontWeight.bold))
                )
              ],
            ),
            const SizedBox(height: 16),

            // THE REAL-TIME TASKS STREAM
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('semesters')
                  .doc(semesterId)
                  .collection('courses')
                  .doc(courseId)
                  .collection('tasks')
                  .orderBy('dueDate') 
                  .snapshots(),
              builder: (context, snapshot) {
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
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200, style: BorderStyle.solid)),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline, color: Colors.grey[400], size: 48),
                        const SizedBox(height: 12),
                        const Text('No upcoming tasks', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 4),
                        Text('You are all caught up for this class!', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                      ],
                    ),
                  );
                }

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
                    
                    DateTime now = DateTime.now();
                    String dateString = '${dueDate.month}/${dueDate.day}/${dueDate.year}';
                    if (dueDate.year == now.year && dueDate.month == now.month && dueDate.day == now.day) {
                      dateString = 'Today';
                    } else if (dueDate.year == now.year && dueDate.month == now.month && dueDate.day == now.day + 1) {
                      dateString = 'Tomorrow';
                    }

                    String taskId = doc.id;

                    return Dismissible(
                      key: Key(taskId), 
                      direction: DismissDirection.endToStart, 
                      
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                      ),
                      
                      onDismissed: (direction) async {
                        try {
                          await FirebaseFirestore.instance
                              .collection('users')
                              .doc(uid)
                              .collection('semesters')
                              .doc(semesterId)
                              .collection('courses')
                              .doc(courseId)
                              .collection('tasks')
                              .doc(taskId)
                              .delete();

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('$title removed'),
                                duration: const Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: 'OK',
                                  textColor: Colors.blue,
                                  onPressed: () {},
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error deleting task: $e')),
                            );
                          }
                        }
                      },
                      
                      child: _buildTaskCard(
                        title: title,
                        type: type,
                        dateString: dateString,
                        isUrgent: isUrgent,
                      ),
                    );  
                  },
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard({
    required String title,
    required String type,
    required String dateString,
    required bool isUrgent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: isUrgent ? Colors.red : Colors.grey[300],
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text('Due $dateString • $type', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      isUrgent ? 'URGENT' : 'NORMAL',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: isUrgent ? Colors.red : Colors.grey[600],
                      ),
                    ),
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