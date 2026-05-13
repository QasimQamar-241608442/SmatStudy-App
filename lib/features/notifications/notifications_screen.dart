import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  bool _isCleared = false; // State to handle "Mark all as read"

  List<Map<String, dynamic>> _urgentDeadlines = [];
  List<Map<String, dynamic>> _academicActivity = [];
  String _topCourseForAI = 'your courses';

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    final DateTime now = DateTime.now();

    List<Map<String, dynamic>> tempUrgent = [];
    List<Map<String, dynamic>> tempActivity = [];
    Map<String, int> courseActivityCount = {};

    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final semestersSnapshot = await userRef.collection('semesters').get();

      for (var semester in semestersSnapshot.docs) {
        final coursesSnapshot = await semester.reference.collection('courses').get();
        
        for (var course in coursesSnapshot.docs) {
          final courseData = course.data();
          final String courseTitle = courseData['title'] ?? courseData['code'] ?? 'Course';
          courseActivityCount[courseTitle] = (courseActivityCount[courseTitle] ?? 0) + 1;

          final tasksSnapshot = await course.reference.collection('tasks').get();
          for (var task in tasksSnapshot.docs) {
            final taskData = task.data();
            taskData['id'] = task.id;
            taskData['courseTitle'] = courseTitle;
            
            // Track course with most tasks for AI insights
            courseActivityCount[courseTitle] = (courseActivityCount[courseTitle] ?? 0) + 1;

            if (taskData['dueDate'] != null) {
              DateTime dueDate = (taskData['dueDate'] as Timestamp).toDate();
              
              // 1. URGENT DEADLINES LOGIC
              if (taskData['isUrgent'] == true && dueDate.isAfter(now)) {
                taskData['timeRemaining'] = _calculateTimeRemaining(dueDate, now);
                taskData['sortDate'] = dueDate;
                tempUrgent.add(taskData);
              } 
              // 2. ACADEMIC ACTIVITY LOGIC (Past deadlines = Grades, Recent creations = New Material)
              else if (dueDate.isBefore(now)) {
                // Synthesize a "Grade Released" notification for past due items
                tempActivity.add({
                  'type': 'grade',
                  'title': 'New Grade Released',
                  'description': 'Your submission for "${taskData['title']}" has been graded. Tap to view.',
                  'timeAgo': _calculateTimeAgo(dueDate, now),
                  'sortDate': dueDate,
                });
              }
            }

            // Synthesize "New Material/Task" for recently created items
            if (taskData['createdAt'] != null) {
              DateTime createdAt = (taskData['createdAt'] as Timestamp).toDate();
              if (now.difference(createdAt).inDays <= 3) {
                tempActivity.add({
                  'type': 'material',
                  'title': 'New ${taskData['type'] ?? 'Assignment'}: $courseTitle',
                  'description': 'A new task "${taskData['title']}" was added to your schedule.',
                  'timeAgo': _calculateTimeAgo(createdAt, now),
                  'sortDate': createdAt,
                });
              }
            }
          }
        }
      }

      // Sort data chronologically
      tempUrgent.sort((a, b) => (a['sortDate'] as DateTime).compareTo(b['sortDate'] as DateTime));
      tempActivity.sort((a, b) => (b['sortDate'] as DateTime).compareTo(a['sortDate'] as DateTime)); // Newest first

      // Find most active course for the AI tip
      if (courseActivityCount.isNotEmpty) {
        var topCourseEntry = courseActivityCount.entries.reduce((a, b) => a.value > b.value ? a : b);
        _topCourseForAI = topCourseEntry.key;
      }

      if (mounted) {
        setState(() {
          _urgentDeadlines = tempUrgent.take(2).toList(); // Only show top 2 most urgent
          _academicActivity = tempActivity.take(4).toList(); // Limit activity feed to top 4
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _calculateTimeRemaining(DateTime future, DateTime now) {
    Duration diff = future.difference(now);
    if (diff.inDays > 0) return '${diff.inDays}D REMAINING';
    if (diff.inHours > 0) return '${diff.inHours}H REMAINING';
    return '${diff.inMinutes}M REMAINING';
  }

  String _calculateTimeAgo(DateTime past, DateTime now) {
    Duration diff = now.difference(past);
    if (diff.inDays > 0) return '${diff.inDays}D AGO';
    if (diff.inHours > 0) return '${diff.inHours}H AGO';
    if (diff.inMinutes > 0) return '${diff.inMinutes}M AGO';
    return 'JUST NOW';
  }

  void _markAllAsRead() {
    setState(() {
      _isCleared = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.black))
        : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- HEADER ---
                const Text('UPDATES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Notifications', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    if (!_isCleared && (_urgentDeadlines.isNotEmpty || _academicActivity.isNotEmpty))
                      GestureDetector(
                        onTap: _markAllAsRead,
                        child: const Text('Mark all as read', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, decoration: TextDecoration.underline)),
                      ),
                  ],
                ),
                const SizedBox(height: 32),

                if (_isCleared || (_urgentDeadlines.isEmpty && _academicActivity.isEmpty))
                  _buildEmptyState()
                else ...[
                  // --- 1. URGENT DEADLINES ---
                  if (_urgentDeadlines.isNotEmpty) ...[
                    Row(
                      children: [
                        Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        const Text('Urgent Deadlines', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ..._urgentDeadlines.map((task) => _buildUrgentCard(task)),
                    const SizedBox(height: 32),
                  ],

                  // --- 2. ACADEMIC ACTIVITY ---
                  if (_academicActivity.isNotEmpty) ...[
                    const Text('Academic Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                      child: Column(
                        children: _academicActivity.asMap().entries.map((entry) {
                          int idx = entry.key;
                          var activity = entry.value;
                          return Column(
                            children: [
                              _buildActivityTile(activity),
                              if (idx != _academicActivity.length - 1)
                                const Divider(height: 1, indent: 72, endIndent: 20),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],

                  // --- 3. AI STUDY INSIGHTS ---
                  Row(
                    children: [
                      const Icon(Icons.auto_awesome, size: 18, color: Colors.black),
                      const SizedBox(width: 8),
                      const Text('AI Study Insights', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAILearningCard(),
                  const SizedBox(height: 40),
                ]
              ],
            ),
          ),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildUrgentCard(Map<String, dynamic> task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.red.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              decoration: const BoxDecoration(color: Colors.red, borderRadius: BorderRadius.horizontal(left: Radius.circular(16))),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                          child: Icon(Icons.timer_outlined, color: Colors.red.shade400),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: Text(task['title'] ?? 'Task', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(4)),
                                    child: Text(task['timeRemaining'], style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text('From ${task['courseTitle']}: ${task['description'] ?? 'Please complete this task as soon as possible.'}', style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4)),
                              const SizedBox(height: 16),
                              const Text('Start Now', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                            ],
                          ),
                        ),
                      ],
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

  Widget _buildActivityTile(Map<String, dynamic> activity) {
    bool isGrade = activity['type'] == 'grade';

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: Icon(isGrade ? Icons.star : Icons.article, color: Colors.grey[600]),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(activity['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(activity['timeAgo'], style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(activity['description'], style: TextStyle(color: Colors.grey[600], fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAILearningCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.grey[400]),
              const SizedBox(width: 12),
              const Text('Focus Pattern Detected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: TextStyle(color: Colors.grey[700], fontSize: 14, height: 1.5),
              children: [
                const TextSpan(text: "You've been most productive on "),
                TextSpan(text: _topCourseForAI, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                const TextSpan(text: " between 9 PM and 11 PM. Should we schedule more deep-work sessions for this slot?"),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(backgroundColor: Colors.grey.shade100, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('IGNORE', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  child: const Text('OPTIMIZE SCHEDULE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60.0),
        child: Column(
          children: [
            Icon(Icons.notifications_off_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('All caught up!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('You have no new notifications.', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}