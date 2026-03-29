import 'package:flutter/material.dart';

class CoursesView extends StatelessWidget {
  const CoursesView({super.key});

  // This is dummy data. Later, this will come directly from Firebase!
  final List<Map<String, String>> _dummyCourses = const [
    {
      'code': 'ECON402',
      'title': 'Advanced Econometrics',
      'professor': 'Prof. Aris',
      'location': 'Hall 405 • Section B',
      'time': 'Mon/Wed/Fri  11:30 - 13:00',
      'alert': 'NEXT CLASS: TODAY'
    },
    {
      'code': 'PHYS301',
      'title': 'Quantum Mechanics I',
      'professor': 'Dr. Elena Vance',
      'location': 'Lab 12 • Section A',
      'time': 'Tue/Thu  09:00 - 10:30',
      'alert': ''
    },
    {
      'code': 'ART210',
      'title': 'Modern European Art',
      'professor': 'Prof. Julian S.',
      'location': 'Gallery 3 • Section C',
      'time': 'Friday  14:00 - 17:00',
      'alert': 'NEXT: FRIDAY'
    },
  ];

@override
  Widget build(BuildContext context) {
    // We upgraded this from a standard Column to a full Scaffold
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      // Adding the Global Top Bar based on your navigation rules
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0, // Removes the drop shadow for a flat, modern look
        iconTheme: const IconThemeData(color: Colors.black), // Makes the back arrow black
        title: const Text('SmartStudy', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.search, color: Colors.black)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none, color: Colors.black)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fall 2026',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Academic Year 2026/27 • Semester 1',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: _dummyCourses.length,
              itemBuilder: (context, index) {
                final course = _dummyCourses[index];
                return _buildCourseCard(course);
              },
            ),
          ),
        ],
      ),
    );
  }
  // The blueprint for a single course card
  Widget _buildCourseCard(Map<String, String> course) {
    final hasAlert = course['alert']!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Course Code & Alert
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  course['code']!,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                ),
              ),
              if (hasAlert)
                Row(
                  children: [
                    Icon(Icons.error, color: Colors.red[700], size: 12),
                    const SizedBox(width: 4),
                    Text(
                      course['alert']!,
                      style: TextStyle(color: Colors.red[700], fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Course Title
          Text(
            course['title']!,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Details (Professor, Location, Time)
          _buildDetailRow(Icons.person, course['professor']!),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.door_front_door, course['location']!),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.schedule, course['time']!),
          
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          
          // Bottom Action Arrow
          const Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.arrow_forward, size: 20),
          ),
        ],
      ),
    );
  }

  // Helper widget for the detail rows (Icon + Text)
  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 13)),
      ],
    );
  }
}