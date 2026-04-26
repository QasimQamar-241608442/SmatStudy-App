import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../courses/add_edit_course_screen.dart';
import '../courses/course_details_screen.dart';

class CoursesView extends StatelessWidget {
  final String semesterId;
  final String semesterName;

  const CoursesView({
    super.key,
    required this.semesterId,
    required this.semesterName,
  });

  @override
  Widget build(BuildContext context) {
    // Grab the currently logged-in user's ID
    final String uid = FirebaseAuth.instance.currentUser!.uid;

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
                Text(
                  semesterName,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Academic Year', // We can make this dynamic later
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          
          // THE REAL-TIME DATABASE STREAM
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(uid)
                  .collection('semesters')
                  .doc(semesterId) // Point exactly to this semester!
                  .collection('courses')
                  .orderBy('createdAt', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                // 1. Loading State
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.black));
                }

                // 2. Empty State
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'No courses added yet.\nTap the + button to build your schedule!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey, fontSize: 16, height: 1.5),
                      ),
                    ),
                  );
                }

                // 3. Data State
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    var data = doc.data() as Map<String, dynamic>;

                    // Safely extract text data
                    String code = data['code'] ?? '';
                    String title = data['title'] ?? 'Untitled Course';
                    String professor = data['professor'] ?? 'No Professor Listed';
                    String location = data['location'] ?? 'No Location Listed';
                    String section = data['section'] ?? '';
                    // Parse the Sessions array to make a readable schedule string
                    List<dynamic> rawSessions = data['sessions'] ?? [];
                    String scheduleString = 'Time TBD';

                    if (rawSessions.isNotEmpty) {
                      // Check if all sessions share the exact same start time
                      bool sameTime = rawSessions.every((s) => s['start'] == rawSessions[0]['start']);
                      
                      if (sameTime) {
                        // If times are identical, group the days: "Mon, Wed, Fri • 9:00 AM"
                        List<String> days = rawSessions.map((s) => s['day'].toString().substring(0, 3)).toList();
                        scheduleString = '${days.join(', ')} • ${rawSessions[0]['start']}';
                      } else {
                        // If times are different, list them out: "Mon 9:00 AM | Thu 2:00 PM"
                        List<String> blocks = rawSessions.map((s) => '${s['day'].toString().substring(0, 3)} ${s['start']}').toList();
                        scheduleString = blocks.join('  |  ');
                      }
                    }
                    // Wrap the card in an InkWell to make it tappable!
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseDetailsScreen(
                              semesterId: semesterId, // The parent semester ID
                              courseId: doc.id,       // The unique Firestore ID for this specific course
                              courseData: data,       // Passing all the data so it loads instantly
                            ),
                          ),
                        );
                      },
                      child: _buildCourseCard(
                        code: code,
                        section: section, 
                        title: title,
                        professor: professor,
                        location: location,
                        time: scheduleString,
                        alert: '', 
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditCourseScreen(
                semesterId: semesterId,
              ),
            ),
          );
        },
        backgroundColor: Colors.black,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // The helper widget that draws the actual card
// Update the signature to include section// The helper widget that draws the actual card
  Widget _buildCourseCard({
    required String code,
    required String section, 
    required String title,
    required String professor,
    required String location,
    required String time,
    required String alert,
  }) {
    return Container(
      // --- RESTORED STYLING PROPERTIES ---
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      // -----------------------------------
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                    child: Text(code, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                  ),
                  if (section.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(6)),
                        child: Text('Sec $section', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                      ),
                    ),
                ],
              ),
              if (alert.isNotEmpty)
                Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red, size: 14),
                    const SizedBox(width: 4),
                    Text(alert, style: const TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                )
            ],
          ),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(professor, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.business_outlined, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(location, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(time, style: TextStyle(color: Colors.grey[700], fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Icon(Icons.arrow_forward, size: 20, color: Colors.black),
          )
        ],
      ),
    );
  }
}