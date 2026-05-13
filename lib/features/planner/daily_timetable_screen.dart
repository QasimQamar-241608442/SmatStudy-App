import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

// Ensure this path matches your project structure for the AI Tutor
import '../courses/course_ai_screen.dart';

class DailyTimetableScreen extends StatefulWidget {
  final DateTime selectedDate;

  const DailyTimetableScreen({
    super.key,
    required this.selectedDate,
  });

  @override
  State<DailyTimetableScreen> createState() => _DailyTimetableScreenState();
}

class _DailyTimetableScreenState extends State<DailyTimetableScreen> {
  final String uid = FirebaseAuth.instance.currentUser!.uid;
  
  bool _isLoading = true;
  List<Map<String, dynamic>> _dayEvents = [];
  bool _isToday = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _isToday = widget.selectedDate.year == now.year && 
               widget.selectedDate.month == now.month && 
               widget.selectedDate.day == now.day;
    _fetchDailyData();
  }

  Future<void> _fetchDailyData() async {
    final DateTime startOfDay = DateTime(widget.selectedDate.year, widget.selectedDate.month, widget.selectedDate.day);
    final DateTime endOfDay = startOfDay.add(const Duration(days: 1));
    final String targetWeekday = DateFormat('EEEE').format(widget.selectedDate); // e.g., "Monday"

    List<Map<String, dynamic>> events = [];

    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final semestersSnapshot = await userRef.collection('semesters').get();

      for (var semester in semestersSnapshot.docs) {
        final coursesSnapshot = await semester.reference.collection('courses').get();
        
        for (var course in coursesSnapshot.docs) {
          final courseData = course.data();
          final String courseCode = courseData['code'] ?? 'Course';
          final String title = courseData['title'] ?? 'Untitled';
          final String location = courseData['location'] ?? 'TBA';

          // 1. Fetch Classes for this day of the week
          final List<dynamic> sessions = courseData['sessions'] ?? [];
          for (var session in sessions) {
            if (session['day'].toString().trim().toLowerCase() == targetWeekday.toLowerCase()) {
              events.add({
                'id': course.id,
                'title': courseCode,
                'subtitle': title,
                'location': location,
                'timeString': '${session['start']} — ${session['end']}',
                'startTime': session['start'],
                'endTime': session['end'],
                'isClass': true,
                'isUrgent': false,
                'sortTime': _parseTimeForSorting(session['start'] ?? ''),
              });
            }
          }

          // 2. Fetch Tasks due on this exact date
          final tasksSnapshot = await course.reference.collection('tasks').get();
          for (var task in tasksSnapshot.docs) {
            final taskData = task.data();
            if (taskData['dueDate'] != null) {
              DateTime dueDate = (taskData['dueDate'] as Timestamp).toDate();
              
              if (dueDate.isAfter(startOfDay) && dueDate.isBefore(endOfDay)) {
                events.add({
                  'id': task.id,
                  'title': taskData['title'] ?? 'Task',
                  'subtitle': '$courseCode • ${taskData['type'] ?? 'Assignment'}',
                  'location': 'Submit Online',
                  'timeString': 'Due 11:59 PM',
                  'isClass': false,
                  'isUrgent': taskData['isUrgent'] ?? false,
                  'sortTime': 1439, // End of day
                });
              }
            }
          }
        }
      }

      // 3. Fetch Global/General Tasks due today
      final globalTasksSnapshot = await userRef.collection('global_tasks').get();
      for (var task in globalTasksSnapshot.docs) {
        final taskData = task.data();
        if (taskData['dueDate'] != null) {
          DateTime dueDate = (taskData['dueDate'] as Timestamp).toDate();
          if (dueDate.isAfter(startOfDay) && dueDate.isBefore(endOfDay)) {
            events.add({
              'id': task.id,
              'title': taskData['title'] ?? 'Global Task',
              'subtitle': taskData['type'] ?? 'Reminder',
              'location': 'General',
              'timeString': 'Due 11:59 PM',
              'isClass': false,
              'isUrgent': taskData['isUrgent'] ?? false,
              'sortTime': 1439,
            });
          }
        }
      }

      // Sort events chronologically
      events.sort((a, b) => (a['sortTime'] as int).compareTo(b['sortTime'] as int));

      if (mounted) {
        setState(() {
          _dayEvents = events;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper to convert "09:00 AM" to minutes for sorting
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
      return 1439; 
    }
  }

  // Checks if the current real-world time falls inside a class window
  bool _checkIfInProgress(String startStr, String endStr) {
    if (!_isToday) return false;
    
    final now = DateTime.now();
    final currentMinutes = (now.hour * 60) + now.minute;
    
    final startMins = _parseTimeForSorting(startStr);
    final endMins = _parseTimeForSorting(endStr);

    return currentMinutes >= startMins && currentMinutes <= endMins;
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
        title: Text(
          _isToday ? 'Today\'s Agenda' : 'Daily Planner',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  Text(
                    DateFormat('EEEE').format(widget.selectedDate).toUpperCase(),
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.5),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMMM d, yyyy').format(widget.selectedDate),
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -0.5),
                  ),
                  const SizedBox(height: 32),

                  // --- AI SMART PREP INSIGHT ---
                  if (_dayEvents.isNotEmpty && _dayEvents.any((e) => e['isClass']))
                    _buildAISmartPrepCard(),
                  
                  if (_dayEvents.isNotEmpty && _dayEvents.any((e) => e['isClass']))
                    const SizedBox(height: 32),

                  // --- TIMELINE ---
                  if (_dayEvents.isEmpty)
                    _buildEmptyState()
                  else
                    ..._dayEvents.asMap().entries.map((entry) {
                      final index = entry.key;
                      final event = entry.value;
                      final isLast = index == _dayEvents.length - 1;
                      
                      return _buildTimelineItem(event, isLast);
                    }),
                    
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildTimelineItem(Map<String, dynamic> event, bool isLast) {
    final bool isClass = event['isClass'];
    final bool isUrgent = event['isUrgent'];
    
    Color dotColor = Colors.black;
    if (!isClass) dotColor = Colors.grey.shade400;
    if (isUrgent) dotColor = Colors.red;

    Color bgColor = isUrgent ? Colors.red.shade50 : Colors.white;

    bool inProgress = false;
    if (isClass) {
      inProgress = _checkIfInProgress(event['startTime'], event['endTime']);
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. The Timeline Line & Dot
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 14, 
                  height: 14, 
                  decoration: BoxDecoration(
                    color: inProgress ? Colors.green : dotColor, 
                    shape: BoxShape.circle, 
                    border: Border.all(color: bgColor, width: 3),
                    boxShadow: inProgress ? [BoxShadow(color: Colors.green.withValues(alpha: 0.4), blurRadius: 8)] : [],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: Colors.grey.shade200,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          
          // 2. The Event Card
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isUrgent ? Colors.red.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: inProgress ? Colors.green.shade400 : (isUrgent ? Colors.red.shade200 : Colors.grey.shade200),
                    width: inProgress ? 1.5 : 1.0,
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(event['title'], style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                        ),
                        if (inProgress)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(6)),
                            child: const Text('IN PROGRESS', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                          )
                        else
                          Text(
                            event['timeString'], 
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isUrgent ? Colors.red : Colors.grey[600]),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(event['subtitle'], style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(isClass ? Icons.location_on : Icons.computer, size: 16, color: Colors.grey[500]),
                        const SizedBox(width: 8),
                        Text(event['location'], style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    
                    // Quick Action button for Classes
                    if (isClass) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CourseAiScreen(
                                  courseId: event['id'],
                                  courseName: event['title'],
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.auto_awesome, size: 16, color: Colors.black),
                          label: const Text('Ask AI Tutor', style: TextStyle(color: Colors.black)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      )
                    ]
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

Widget _buildAISmartPrepCard() {
    // 1. Calculate dynamic stats based on the actual events for this specific day
    int lectureCount = _dayEvents.where((e) => e['isClass'] == true).length;
    int taskCount = _dayEvents.where((e) => e['isClass'] == false).length;
    int urgentCount = _dayEvents.where((e) => e['isUrgent'] == true).length;

    String dynamicMessage = '';

    // 2. Generate contextual advice based on the day's load
    if (lectureCount > 0 && taskCount > 0) {
      dynamicMessage = 'You have $lectureCount lecture${lectureCount > 1 ? 's' : ''} and $taskCount task${taskCount > 1 ? 's' : ''} today. ';
      if (urgentCount > 0) {
        dynamicMessage += 'Prioritize your $urgentCount urgent deadline${urgentCount > 1 ? 's' : ''} first!';
      } else {
        dynamicMessage += 'Pace yourself and review your materials between sessions.';
      }
    } else if (lectureCount > 0) {
      dynamicMessage = 'You have $lectureCount lecture${lectureCount > 1 ? 's' : ''} today. Review your notes beforehand to stay ahead.';
    } else if (taskCount > 0) {
      dynamicMessage = 'Focus day! You have $taskCount task${taskCount > 1 ? 's' : ''} to complete. Knock them out early.';
    } else {
      dynamicMessage = 'Looks like a light day. Great time to review upcoming course materials!';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 12),
              const Text('SMART PREP', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            ],
          ),
          const SizedBox(height: 16),
          // 3. Inject the dynamic message into the UI
          Text(
            dynamicMessage,
            style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            Icon(Icons.bedtime_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No classes or deadlines.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Enjoy your free time!', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}