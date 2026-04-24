import 'package:flutter/material.dart';
class CoursesView extends StatelessWidget {
  // 1. Declare the variables this screen expects to receive
  final String semesterId;
  final String semesterName;

  // 2. Require them in the constructor
  const CoursesView({
    super.key,
    required this.semesterId,
    required this.semesterName,
  });

  // (Keep your _dummyCourses list here exactly as it is)
  final List<Map<String, String>> _dummyCourses = const [
    {
      'code': 'ECON402',
      'title': 'Advanced Econometrics',
      'professor': 'Prof. Aris',
      'location': 'Hall 405 • Section B',
      'time': 'Mon/Wed/Fri  11:30 - 13:00',
      'alert': 'NEXT CLASS: TODAY'
    },
    // ... keep the rest of your dummy courses ...
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 3. Inject the dynamic semester name here!
                Text(
                  semesterName,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Academic Year 2026', // We can make this dynamic later too!
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
            color: Colors.black.withValues(alpha:0.05),
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