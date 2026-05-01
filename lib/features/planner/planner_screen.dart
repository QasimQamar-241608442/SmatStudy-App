import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart'; 
import 'global_add_task_screen.dart'; 
import '../search/global_search_screen.dart';
import '../notifications/notifications_screen.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  late final ValueNotifier<List<Map<String, dynamic>>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  PageController? _pageController; 

  final Map<DateTime, List<Map<String, dynamic>>> _events = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _fetchAllData();
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  List<Map<String, dynamic>> _getEventsForDay(DateTime day) {
    return _events[_normalizeDate(day)] ?? [];
  }

  int _getWeekdayNumber(String day) {
    switch (day.toLowerCase().trim()) {
      case 'monday': return DateTime.monday;
      case 'tuesday': return DateTime.tuesday;
      case 'wednesday': return DateTime.wednesday;
      case 'thursday': return DateTime.thursday;
      case 'friday': return DateTime.friday;
      case 'saturday': return DateTime.saturday;
      case 'sunday': return DateTime.sunday;
      default: return DateTime.monday;
    }
  }

  Future<void> _fetchAllData() async {
    setState(() {
      _isLoading = true;
      _events.clear();
    });
    
    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      
      final DateTime now = DateTime.now();
      final DateTime windowStart = now.subtract(const Duration(days: 30));
      final DateTime windowEnd = now.add(const Duration(days: 90));

      final semestersSnapshot = await userRef.collection('semesters').get();
      for (var semester in semestersSnapshot.docs) {
        final coursesSnapshot = await semester.reference.collection('courses').get();
        for (var course in coursesSnapshot.docs) {
          final courseData = course.data();
          final courseName = courseData['title'] ?? courseData['code'] ?? 'Course';
          final courseLocation = courseData['location'] ?? 'No location';

          List<dynamic> sessions = courseData['sessions'] ?? [];
          for (var session in sessions) {
            int targetWeekday = _getWeekdayNumber(session['day']);
            for (DateTime d = windowStart; d.isBefore(windowEnd); d = d.add(const Duration(days: 1))) {
              if (d.weekday == targetWeekday) {
                DateTime normalized = _normalizeDate(d);
                if (_events[normalized] == null) _events[normalized] = [];
                _events[normalized]!.add({
                  'title': courseName,
                  'type': 'Lecture',
                  'time': '${session['start']} — $courseLocation',
                  'isUrgent': false,
                  'isClass': true,
                });
              }
            }
          }

          final tasksSnapshot = await course.reference.collection('tasks').get();
          for (var task in tasksSnapshot.docs) {
            final taskData = task.data();
            if (taskData['dueDate'] != null) {
              Timestamp timestamp = taskData['dueDate'] as Timestamp;
              DateTime normalizedDate = _normalizeDate(timestamp.toDate());
              
              if (_events[normalizedDate] == null) _events[normalizedDate] = [];
              _events[normalizedDate]!.add({
                'title': taskData['title'] ?? 'Task',
                'type': courseName, 
                'time': 'DUE 11:59 PM',
                'isUrgent': taskData['isUrgent'] ?? false,
                'isClass': false,
              });
            }
          }
        }
      }

      final globalTasksSnapshot = await userRef.collection('global_tasks').get();
      for (var task in globalTasksSnapshot.docs) {
        final taskData = task.data();
        if (taskData['dueDate'] != null) {
          Timestamp timestamp = taskData['dueDate'] as Timestamp;
          DateTime normalizedDate = _normalizeDate(timestamp.toDate());
          
          if (_events[normalizedDate] == null) _events[normalizedDate] = [];
          _events[normalizedDate]!.add({
            'title': taskData['title'] ?? 'Task',
            'type': taskData['type'] ?? 'General Task', 
            'time': 'DUE 11:59 PM',
            'isUrgent': taskData['isUrgent'] ?? false,
            'isClass': false,
          });
        }
      }

    } catch (e) {
      debugPrint("Error fetching data: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
        _selectedEvents.value = _getEventsForDay(_selectedDay!);
      }
    }
  }

  void _openAddTask(String type) async {
    final result = await Navigator.push(
      context, 
      MaterialPageRoute(builder: (context) => GlobalAddTaskScreen(initialType: type))
    );
    if (result == true) {
      _fetchAllData();
    }
  }

  @override
  Widget build(BuildContext context) {
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
      
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        activeBackgroundColor: Colors.grey[800],
        activeForegroundColor: Colors.white,
        elevation: 8,
        overlayColor: Colors.black,
        overlayOpacity: 0.6, 
        spacing: 12,
        spaceBetweenChildren: 12,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), 
        children: [
          SpeedDialChild(
            child: const Icon(Icons.menu_book, color: Colors.black),
            backgroundColor: Colors.white,
            label: 'Homework',
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            onTap: () => _openAddTask('Homework'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.assignment, color: Colors.black),
            backgroundColor: Colors.white,
            label: 'Exam',
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            onTap: () => _openAddTask('Exam'),
          ),
          SpeedDialChild(
            child: const Icon(Icons.notifications_active, color: Colors.black),
            backgroundColor: Colors.white,
            label: 'Reminder',
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            onTap: () => _openAddTask('Reminder'),
          ),
        ],
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          // 1. We wrap the entire layout in a SingleChildScrollView so the WHOLE screen scrolls
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMMM yyyy').format(_focusedDay).toUpperCase(),
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600], letterSpacing: 1.5),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _pageController?.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                                  child: Container(padding: const EdgeInsets.all(4), child: const Icon(Icons.chevron_left, size: 24, color: Colors.black)),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () => _pageController?.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
                                  child: Container(padding: const EdgeInsets.all(4), child: const Icon(Icons.chevron_right, size: 24, color: Colors.black)),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('Academic\nPlanner', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1)),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(8)),
                              child: Row(
                                children: [
                                  _buildToggleBtn('Monthly', _calendarFormat == CalendarFormat.month, () => setState(() => _calendarFormat = CalendarFormat.month)),
                                  _buildToggleBtn('Weekly', _calendarFormat == CalendarFormat.week, () => setState(() => _calendarFormat = CalendarFormat.week)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade300)),
                    child: TableCalendar<Map<String, dynamic>>(
                      firstDay: DateTime.utc(2020, 1, 1),
                      lastDay: DateTime.utc(2030, 12, 31),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      calendarFormat: _calendarFormat,
                      eventLoader: _getEventsForDay,
                      startingDayOfWeek: StartingDayOfWeek.sunday,
                      headerVisible: false, 
                      daysOfWeekHeight: 40,
                      onCalendarCreated: (controller) => _pageController = controller,
                      calendarBuilders: CalendarBuilders(
                        markerBuilder: (context, date, events) {
                          if (events.isEmpty) return const SizedBox();
                          bool hasLecture = events.any((e) => e['isClass'] == true);
                          bool hasTask = events.any((e) => e['isClass'] == false && e['isUrgent'] == false);
                          bool hasUrgent = events.any((e) => e['isUrgent'] == true);

                          return Positioned(
                            bottom: 6,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (hasLecture) _buildStitchMarker(Colors.grey.shade800),
                                if (hasTask) _buildStitchMarker(Colors.grey.shade300),
                                if (hasUrgent) _buildStitchMarker(Colors.red),
                              ],
                            ),
                          );
                        },
                      ),
                      calendarStyle: CalendarStyle(
                        todayDecoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.rectangle),
                        todayTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        selectedDecoration: BoxDecoration(border: Border.all(color: Colors.black, width: 2), shape: BoxShape.rectangle),
                        selectedTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        defaultDecoration: const BoxDecoration(shape: BoxShape.rectangle),
                        weekendDecoration: const BoxDecoration(shape: BoxShape.rectangle),
                        cellMargin: const EdgeInsets.all(0),
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDay = selectedDay;
                          _focusedDay = focusedDay;
                        });
                        _selectedEvents.value = _getEventsForDay(selectedDay);
                      },
                      onPageChanged: (focusedDay) {
                        setState(() => _focusedDay = focusedDay);
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Legend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildLegendItem(Colors.grey.shade800, 'Scheduled Lectures'),
                        const SizedBox(height: 8),
                        _buildLegendItem(Colors.grey.shade300, 'Study Sessions & Tasks'),
                        const SizedBox(height: 8),
                        _buildLegendItem(Colors.red, 'Major Deadlines'),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Today’s Focus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        ValueListenableBuilder<List<Map<String, dynamic>>>(
                          valueListenable: _selectedEvents,
                          builder: (context, value, _) {
                            return Text('${value.length} EVENTS', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 12));
                          }
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // 2. We completely removed the `Expanded` widget that was here!
                  ValueListenableBuilder<List<Map<String, dynamic>>>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      if (value.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32.0),
                          child: Center(child: Text('Free day!', style: TextStyle(color: Colors.grey[500]))),
                        );
                      }

                      return ListView.builder(
                        // 3. We tell the list to wrap its height and surrender scrolling to the parent
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          final event = value[index];
                          final isUrgent = event['isUrgent'] == true;
                          final isClass = event['isClass'] == true;
                          
                          Color markerColor = Colors.grey.shade300;
                          if (isClass) markerColor = Colors.grey.shade800;
                          if (isUrgent) markerColor = Colors.red;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                            child: IntrinsicHeight(
                              child: Row(
                                children: [
                                  Container(width: 4, margin: const EdgeInsets.symmetric(vertical: 8), decoration: BoxDecoration(color: markerColor, borderRadius: BorderRadius.circular(4))),
                                  Expanded(
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                      title: Text(event['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      subtitle: Text(event['type'], style: TextStyle(color: Colors.grey[600], fontSize: 13)), 
                                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  
                  // 4. We add padding to the bottom so the last item isn't hidden under your FAB!
                  const SizedBox(height: 80), 
                ],
              ),
            ),
    );
  }

  Widget _buildToggleBtn(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(color: isSelected ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(6), boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : []),
        child: Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? Colors.black : Colors.grey[600])),
      ),
    );
  }

  Widget _buildStitchMarker(Color color) {
    return Container(margin: const EdgeInsets.only(top: 2), height: 4, width: 16, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)));
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}