import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  String _searchQuery = '';
  String _selectedFilter = 'All'; 
  
  bool _isLoading = true;
  // NEW: State to track if the user clicked "Clear All"
  bool _isRecentActivityCleared = false; 
  
  List<Map<String, dynamic>> _allCourses = [];
  List<Map<String, dynamic>> _allTasks = [];

  @override
  void initState() {
    super.initState();
    _fetchSearchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchSearchData() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    List<Map<String, dynamic>> tempCourses = [];
    List<Map<String, dynamic>> tempTasks = [];

    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final semestersSnapshot = await userRef.collection('semesters').get();

      for (var semester in semestersSnapshot.docs) {
        final coursesSnapshot = await semester.reference.collection('courses').get();
        
        for (var course in coursesSnapshot.docs) {
          final courseData = course.data();
          courseData['id'] = course.id;
          courseData['semesterId'] = semester.id;
          courseData['type'] = 'course';
          tempCourses.add(courseData);

          final tasksSnapshot = await course.reference.collection('tasks').get();
          for (var task in tasksSnapshot.docs) {
            final taskData = task.data();
            taskData['id'] = task.id;
            taskData['courseId'] = course.id;
            taskData['semesterId'] = semester.id;
            taskData['courseTitle'] = courseData['title'] ?? courseData['code'];
            taskData['type'] = 'task';
            tempTasks.add(taskData);
          }
        }
      }

      if (mounted) {
        setState(() {
          _allCourses = tempCourses;
          _allTasks = tempTasks;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching search data: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredResults {
    if (_searchQuery.isEmpty && _selectedFilter == 'All') return [];

    List<Map<String, dynamic>> combined = [];
    final String query = _searchQuery.toLowerCase();

    if (_selectedFilter == 'All' || _selectedFilter == 'Courses' || _selectedFilter == 'Professors') {
      combined.addAll(_allCourses);
    }
    if (_selectedFilter == 'All' || _selectedFilter == 'Deadlines') {
      combined.addAll(_allTasks);
    }

    if (query.isNotEmpty) {
      combined = combined.where((item) {
        if (item['type'] == 'course') {
          if (_selectedFilter == 'Professors') {
            return (item['professor'] ?? '').toLowerCase().contains(query);
          }
          return (item['title'] ?? '').toLowerCase().contains(query) ||
                 (item['code'] ?? '').toLowerCase().contains(query) ||
                 (item['professor'] ?? '').toLowerCase().contains(query);
        } else {
          return (item['title'] ?? '').toLowerCase().contains(query) ||
                 (item['description'] ?? '').toLowerCase().contains(query) ||
                 (item['type'] ?? '').toLowerCase().contains(query); 
        }
      }).toList();
    } else {
      if (_selectedFilter == 'Professors' || _selectedFilter == 'Courses') {
         combined = _allCourses;
      } else if (_selectedFilter == 'Deadlines') {
         combined = _allTasks;
      }
    }

    return combined;
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
        title: const Text('SmartStudy', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.search, color: Colors.black),
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.black))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _searchQuery = value),
                    decoration: InputDecoration(
                      hintText: 'Search courses, files, or deadlines...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                const Text('FILTER RESULTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: [
                    _buildFilterChip('All', Icons.all_inclusive),
                    _buildFilterChip('Courses', Icons.school),
                    _buildFilterChip('Deadlines', Icons.calendar_today),
                    _buildFilterChip('Files', Icons.insert_drive_file),
                    _buildFilterChip('Professors', Icons.person),
                  ],
                ),
                const SizedBox(height: 32),

                if (_searchQuery.isEmpty && _selectedFilter == 'All')
                  _buildDynamicDashboard() 
                else if (_selectedFilter == 'Files')
                  _buildEmptyFilesState()
                else if (_filteredResults.isEmpty)
                  _buildNoResultsState()
                else
                  _buildSearchResults(),
                  
                const SizedBox(height: 40),
              ],
            ),
          ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    final bool isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? Colors.black : Colors.grey.shade200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey[700]),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${_filteredResults.length} RESULTS FOUND', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _filteredResults.length,
          itemBuilder: (context, index) {
            final item = _filteredResults[index];
            if (item['type'] == 'course') {
              return _buildCourseResultCard(item);
            } else {
              return _buildTaskResultCard(item);
            }
          },
        ),
      ],
    );
  }

  Widget _buildCourseResultCard(Map<String, dynamic> course) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.school, color: Colors.blue.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course['title'] ?? 'Course', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('${course['code']} • ${course['professor'] ?? 'TBA'}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildTaskResultCard(Map<String, dynamic> task) {
    final bool isUrgent = task['isUrgent'] == true;
    String dateStr = 'No Date';
    if (task['dueDate'] != null) {
      dateStr = DateFormat('MMM d, yyyy').format((task['dueDate'] as Timestamp).toDate());
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isUrgent ? Colors.red.shade200 : Colors.grey.shade200)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: isUrgent ? Colors.red.shade50 : Colors.orange.shade50, borderRadius: BorderRadius.circular(12)),
            child: Icon(Icons.assignment, color: isUrgent ? Colors.red : Colors.orange.shade700),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task['title'] ?? 'Task', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('${task['courseTitle']} • Due $dateStr', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ],
            ),
          ),
          if (isUrgent)
            const Icon(Icons.priority_high, color: Colors.red, size: 20)
          else
            const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Column(
          children: [
            Icon(Icons.search_off, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('No results found', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Try adjusting your search or filter.', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyFilesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 40.0),
        child: Column(
          children: [
            Icon(Icons.folder_off_outlined, size: 48, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('File Search', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 8),
            Text('Document indexing is coming in Phase 3.', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicDashboard() {
    // Stable Recent Activity: Take the 3 most recently fetched items without shuffling
    List<Map<String, dynamic>> recentItems = [];
    recentItems.addAll(_allTasks);
    recentItems.addAll(_allCourses);
    // Reverse to simulate "most recent first" based on fetch order
    final topRecent = recentItems.reversed.take(3).toList();

    final urgentTasks = _allTasks.where((t) => t['isUrgent'] == true).toList();
    Map<String, dynamic>? activeUrgentTask;
    if (urgentTasks.isNotEmpty) {
      urgentTasks.sort((a, b) => (a['dueDate'] as Timestamp).compareTo(b['dueDate'] as Timestamp));
      activeUrgentTask = urgentTasks.first;
    }

    String dynamicCourseName = _allCourses.isNotEmpty ? _allCourses.first['title'] : 'your courses';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('RECENT ACTIVITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            // FIX: Hide the button if already cleared, otherwise make it clickable
            if (!_isRecentActivityCleared)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isRecentActivityCleared = true;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.all(4.0), // Adds a slightly bigger tap area
                  child: Text('CLEAR ALL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        
        // FIX: Display empty message if cleared OR if there's no data
        if (_isRecentActivityCleared || topRecent.isEmpty)
          const Text("No recent activity.", style: TextStyle(color: Colors.grey))
        else
          ...topRecent.map((item) => Column(
            children: [
              _buildRecentRow(item['title'] ?? 'Untitled'),
              if (item != topRecent.last) const Divider(height: 24),
            ],
          )),
        
        const SizedBox(height: 40),

        if (activeUrgentTask != null) ...[
          _buildUrgentActionCard(activeUrgentTask),
          const SizedBox(height: 40),
        ],

        const Text('AI SUGGESTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, size: 18),
                  SizedBox(width: 8),
                  Text('Smart Discovery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const SizedBox(height: 12),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4),
                  children: [
                    const TextSpan(text: 'Based on your upcoming deadlines in '),
                    TextSpan(text: '"$dynamicCourseName"', style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                    const TextSpan(text: ', you might find SmartStudy AI helpful to build a study plan.'),
                  ],
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  Widget _buildRecentRow(String title) {
    return Row(
      children: [
        Icon(Icons.history, color: Colors.grey[400], size: 18),
        const SizedBox(width: 16),
        Expanded(child: Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 14), overflow: TextOverflow.ellipsis)),
      ],
    );
  }

  Widget _buildUrgentActionCard(Map<String, dynamic> task) {
    DateTime dueDate = (task['dueDate'] as Timestamp).toDate();
    int hoursLeft = dueDate.difference(DateTime.now()).inHours;
    String timeString = hoursLeft > 24 ? '${hoursLeft ~/ 24} days' : '${hoursLeft > 0 ? hoursLeft : 0} hours';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.red.shade100)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('URGENT DEADLINE FOUND', style: TextStyle(color: Colors.red.shade700, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
              Icon(Icons.priority_high, color: Colors.red.shade700, size: 16),
            ],
          ),
          const SizedBox(height: 12),
          Text(task['title'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
          const SizedBox(height: 12),
          Text("Due in $timeString. Related to your ${task['courseTitle']} course.", style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedFilter = 'Deadlines';
                _searchController.text = task['title'];
                _searchQuery = task['title'];
              });
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('VIEW TASK', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }
}