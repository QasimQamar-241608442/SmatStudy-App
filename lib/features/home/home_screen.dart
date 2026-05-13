import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// Importing other screens
import '../search/global_search_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  
  bool _isLoading = true;
  String _firstName = '';
  List<Map<String, dynamic>> _todayEvents = [];
  List<Map<String, dynamic>> _upcomingTasks = [];

  @override
  void initState() {
    super.initState();
    _setGreetingName();
    _fetchDashboardData();
  }

  void _setGreetingName() {
    if (user != null && user!.displayName != null && user!.displayName!.isNotEmpty) {
      _firstName = user!.displayName!.split(' ')[0];
    } else {
      _firstName = 'Student';
    }
  }

  String _getTimeOfDayGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> _fetchDashboardData() async {
    if (user == null) return;

    final DateTime now = DateTime.now();
    final DateTime startOfToday = DateTime(now.year, now.month, now.day);
    final DateTime endOfToday = startOfToday.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));
    final DateTime nextWeek = endOfToday.add(const Duration(days: 7));
    final String todayWeekday = DateFormat('EEEE').format(now); // e.g., "Monday"

    List<Map<String, dynamic>> todayItems = [];
    List<Map<String, dynamic>> upcomingItems = [];

    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(user!.uid);
      final semestersSnapshot = await userRef.collection('semesters').get();

      for (var semester in semestersSnapshot.docs) {
        final coursesSnapshot = await semester.reference.collection('courses').get();
        
        for (var course in coursesSnapshot.docs) {
          final courseData = course.data();
          final String courseCode = courseData['code'] ?? 'Course';
          final String location = courseData['location'] ?? 'TBA';

          // 1. Fetch Classes for Today
          final List<dynamic> sessions = courseData['sessions'] ?? [];
          for (var session in sessions) {
            if (session['day'].toString().trim().toLowerCase() == todayWeekday.toLowerCase()) {
              todayItems.add({
                'title': courseCode,
                'subtitle': 'Lecture • $location',
                'timeString': session['start'] ?? 'Time TBA',
                'isClass': true,
                'isUrgent': false,
                'sortTime': _parseTimeForSorting(session['start'] ?? ''),
              });
            }
          }

          // 2. Fetch Tasks (Today & Upcoming)
          final tasksSnapshot = await course.reference.collection('tasks').get();
          for (var task in tasksSnapshot.docs) {
            final taskData = task.data();
            if (taskData['dueDate'] != null) {
              DateTime dueDate = (taskData['dueDate'] as Timestamp).toDate();
              
              if (dueDate.isAfter(startOfToday) && dueDate.isBefore(endOfToday)) {
                // Due today
                todayItems.add({
                  'title': taskData['title'] ?? 'Task',
                  'subtitle': '$courseCode • ${taskData['type'] ?? 'Assignment'}',
                  'timeString': 'Due 11:59 PM',
                  'isClass': false,
                  'isUrgent': taskData['isUrgent'] ?? false,
                  'sortTime': 1439, // End of day for sorting (23:59)
                });
              } else if (dueDate.isAfter(endOfToday) && dueDate.isBefore(nextWeek)) {
                // Due in the next 7 days
                upcomingItems.add({
                  ...taskData,
                  'courseCode': courseCode,
                  'dateObject': dueDate,
                });
              }
            }
          }
        }
      }

      // Fetch Global Tasks
      final globalTasksSnapshot = await userRef.collection('global_tasks').get();
      for (var task in globalTasksSnapshot.docs) {
        final taskData = task.data();
        if (taskData['dueDate'] != null) {
          DateTime dueDate = (taskData['dueDate'] as Timestamp).toDate();
          if (dueDate.isAfter(startOfToday) && dueDate.isBefore(endOfToday)) {
            todayItems.add({
              'title': taskData['title'] ?? 'Global Task',
              'subtitle': taskData['type'] ?? 'Reminder',
              'timeString': 'Due 11:59 PM',
              'isClass': false,
              'isUrgent': taskData['isUrgent'] ?? false,
              'sortTime': 1439,
            });
          } else if (dueDate.isAfter(endOfToday) && dueDate.isBefore(nextWeek)) {
            upcomingItems.add({
              ...taskData,
              'courseCode': 'General',
              'dateObject': dueDate,
            });
          }
        }
      }

      // Sort today items by time
      todayItems.sort((a, b) => (a['sortTime'] as int).compareTo(b['sortTime'] as int));
      // Sort upcoming items by date
      upcomingItems.sort((a, b) => (a['dateObject'] as DateTime).compareTo(b['dateObject'] as DateTime));

      if (mounted) {
        setState(() {
          _todayEvents = todayItems;
          _upcomingTasks = upcomingItems;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching home data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper to convert "09:00 AM" to minutes for chronologically sorting the timeline
  int _parseTimeForSorting(String timeStr) {
    try {
      final lower = timeStr.toLowerCase();
      bool isPM = lower.contains('pm');
      String clean = timeStr.replaceAll(RegExp(r'[^0-9:]'), '');
      if (clean.isEmpty) return 1439;
      
      List<String> parts = clean.split(':');
      int hours = int.parse(parts[0]);
      int mins = parts.length > 1 ? int.parse(parts[1]) : 0;
      
      if (isPM && hours < 12) hours += 12;
      if (!isPM && hours == 12) hours = 0;
      
      return (hours * 60) + mins;
    } catch (e) {
      return 1439; // Fallback to end of day
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
        title: const Text('SmartStudy', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GlobalSearchScreen())),
          ),
          IconButton(
            icon: const Badge(backgroundColor: Colors.red, child: Icon(Icons.notifications_none, color: Colors.black)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.black))
        : RefreshIndicator(
            color: Colors.black,
            onRefresh: _fetchDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- 1. DYNAMIC HEADER ---
                  Text('${_getTimeOfDayGreeting()},', style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                  Text(_firstName, style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  Text(DateFormat('EEEE, MMMM d').format(DateTime.now()), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 32),

                  // --- 2. TODAY'S TIMELINE ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('TODAY\'S SCHEDULE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                      if (_todayEvents.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(6)),
                          child: Text('${_todayEvents.length} EVENTS', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        )
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  if (_todayEvents.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                      child: Column(
                        children: [
                          Icon(Icons.celebration_outlined, size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          const Text('Free Day!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('No classes or deadlines today.', style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
                      child: Column(
                        children: _todayEvents.asMap().entries.map((entry) {
                          int idx = entry.key;
                          Map<String, dynamic> event = entry.value;
                          bool isLast = idx == _todayEvents.length - 1;
                          
                          Color dotColor = Colors.black;
                          if (event['isClass'] == false) dotColor = Colors.grey.shade400;
                          if (event['isUrgent'] == true) dotColor = Colors.red;

                          return IntrinsicHeight(
                            child: Row(
                              children: [
                                // Timeline Line & Dot
                                SizedBox(
                                  width: 20,
                                  child: Column(
                                    children: [
                                      Container(width: 10, height: 10, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2))),
                                      if (!isLast) Expanded(child: Container(width: 2, color: Colors.grey.shade100)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Event Content
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(event['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            Text(event['timeString'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey[600])),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(event['subtitle'], style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  const SizedBox(height: 40),

                  // --- 3. UPCOMING RADAR ---
                  const Text('UPCOMING DEADLINES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                  const SizedBox(height: 16),
                  
                  if (_upcomingTasks.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('You are all caught up for the week.', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
                    )
                  else
                    SizedBox(
                      height: 140,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _upcomingTasks.length,
                        clipBehavior: Clip.none,
                        itemBuilder: (context, index) {
                          final task = _upcomingTasks[index];
                          final date = task['dateObject'] as DateTime;
                          final isUrgent = task['isUrgent'] == true;

                          return Container(
                            width: 240,
                            margin: const EdgeInsets.only(right: 16),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: isUrgent ? Colors.red.shade50 : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: isUrgent ? Colors.red.shade100 : Colors.grey.shade200),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(color: isUrgent ? Colors.red.shade100 : Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                                      child: Icon(task['type'].toString().contains('Exam') ? Icons.assignment : Icons.task, color: isUrgent ? Colors.red : Colors.black, size: 18),
                                    ),
                                    Text(DateFormat('MMM d').format(date).toUpperCase(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: isUrgent ? Colors.red : Colors.grey[500], letterSpacing: 1.0)),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(task['title'] ?? 'Task', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 2),
                                    Text('${task['courseCode']} • ${task['type']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }
}