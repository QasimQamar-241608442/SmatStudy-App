import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class GlobalAddTaskScreen extends StatefulWidget {
  final String initialType; 

  const GlobalAddTaskScreen({
    super.key, 
    this.initialType = 'Task', 
  });

  @override
  State<GlobalAddTaskScreen> createState() => _GlobalAddTaskScreenState();
}

class _GlobalAddTaskScreenState extends State<GlobalAddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  
  DateTime? _dueDate;
  late String _currentType;
  bool _isUrgent = false;
  bool _isLoading = false;

  String _examFormat = 'Written Exam';
  final List<String> _examFormats = ['Written Exam', 'Oral Exam', 'Practical Exam'];

  // FIX: We start with an empty list. No more hardcoded "General Life Task"!
  List<Map<String, String>> _availableCourses = [];
  
  // FIX: This is now nullable so we can handle users who have zero courses.
  String? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    _currentType = widget.initialType;
    _fetchUserCourses();
  }

  Future<void> _fetchUserCourses() async {
    final String uid = FirebaseAuth.instance.currentUser!.uid;
    try {
      final semestersSnapshot = await FirebaseFirestore.instance
          .collection('users').doc(uid).collection('semesters').get();

      List<Map<String, String>> fetchedCourses = [];
      
      for (var sem in semestersSnapshot.docs) {
        final coursesSnapshot = await sem.reference.collection('courses').get();
        for (var course in coursesSnapshot.docs) {
          fetchedCourses.add({
            'id': course.id,
            'name': course.data()['title'] ?? course.data()['code'] ?? 'Unnamed Course',
            'semId': sem.id,
          });
        }
      }

      if (mounted) {
        setState(() {
          _availableCourses = fetchedCourses;
          // FIX: If it's an Exam or Homework, automatically select the first course they are enrolled in!
          if (_currentType != 'Reminder' && _availableCourses.isNotEmpty) {
            _selectedCourseId = _availableCourses.first['id'];
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching courses: $e");
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate() || _dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please add a title and select a due date.', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.black87,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        )
      );
      return;
    }

    // FIX: Block them from saving an Exam/Homework if they haven't created a course yet!
    if (_currentType != 'Reminder' && _selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('You need to add a Course in the Courses tab first!', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.red.shade800,
          behavior: SnackBarBehavior.floating,
        )
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;
      
      final taskData = {
        'title': _titleController.text.trim(),
        'type': _currentType == 'Exam' ? 'Exam ($_examFormat)' : _currentType, 
        'dueDate': Timestamp.fromDate(_dueDate!),
        'isUrgent': _isUrgent,
        'createdAt': FieldValue.serverTimestamp(),
      };

      if (_currentType == 'Reminder') {
        // Reminders go straight to global_tasks. No course needed.
        await FirebaseFirestore.instance.collection('users').doc(uid).collection('global_tasks').add(taskData);
      } else {
        // Exams and Homework MUST go to the specifically selected course.
        final selectedCourse = _availableCourses.firstWhere((c) => c['id'] == _selectedCourseId);
        await FirebaseFirestore.instance
            .collection('users').doc(uid)
            .collection('semesters').doc(selectedCourse['semId'])
            .collection('courses').doc(_selectedCourseId!)
            .collection('tasks').add(taskData);
      }

      if (mounted) Navigator.pop(context, true); 
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.black, onPrimary: Colors.white, onSurface: Colors.black),
            dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF4F6F8);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        leading: IconButton(
          icon: const Icon(Icons.close, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(left: 24, right: 24, bottom: 40, top: 16),
        decoration: BoxDecoration(
          color: bgColor,
          boxShadow: [BoxShadow(color: bgColor.withValues(alpha: 0.9), blurRadius: 20, spreadRadius: 10, offset: const Offset(0, -10))],
        ),
        child: SizedBox(
          height: 60,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveTask,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              elevation: 8,
              shadowColor: Colors.black.withValues(alpha: 0.3),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isLoading 
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text('New $_currentType', style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w900, letterSpacing: -1.0, color: Colors.black)),
              const SizedBox(height: 32),

              _buildSectionLabel(_currentType == 'Reminder' ? 'REMIND ME ABOUT...' : 'TITLE'),
              _buildPremiumCard(
                child: TextFormField(
                  controller: _titleController,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: _currentType == 'Exam' ? 'e.g., Midterm Finals' : 'e.g., Read Chapter 4',
                    hintStyle: TextStyle(color: Colors.grey[400], fontWeight: FontWeight.normal),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                  validator: (val) => val == null || val.isEmpty ? '' : null, 
                ),
              ),
              const SizedBox(height: 24),

              if (_currentType != 'Reminder') ...[
                _buildSectionLabel('LINK TO SUBJECT'),
                _buildPremiumCard(
                  child: DropdownButton<String>(
                    value: _selectedCourseId,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                    underline: const SizedBox(), 
                    // FIX: If they have no courses, show a disabled text item so it doesn't crash
                    items: _availableCourses.isEmpty 
                      ? [const DropdownMenuItem(value: null, child: Text('No courses found', style: TextStyle(color: Colors.grey)))]
                      : _availableCourses.map((course) {
                        return DropdownMenuItem(
                          value: course['id'], 
                          child: Row(
                            children: [
                              Icon(Icons.school, color: Colors.grey[700], size: 20),
                              const SizedBox(width: 12),
                              Expanded(child: Text(course['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))),
                            ],
                          )
                        );
                      }).toList(),
                    onChanged: _availableCourses.isEmpty ? null : (val) => setState(() => _selectedCourseId = val),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              if (_currentType == 'Exam') ...[
                _buildSectionLabel('EXAM CATEGORY'),
                _buildPremiumCard(
                  child: DropdownButton<String>(
                    value: _examFormat,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.black),
                    underline: const SizedBox(), 
                    items: _examFormats.map((format) {
                      return DropdownMenuItem(
                        value: format, 
                        child: Text(format, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16))
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _examFormat = val!),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              _buildSectionLabel('DUE DATE'),
              GestureDetector(
                onTap: _pickDate,
                child: _buildPremiumCard(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _dueDate == null ? 'Select Date' : DateFormat('MMMM d, yyyy').format(_dueDate!), 
                        style: TextStyle(color: _dueDate == null ? Colors.grey[500] : Colors.black, fontWeight: FontWeight.w600, fontSize: 16)
                      ),
                      Icon(Icons.calendar_today_rounded, color: _dueDate == null ? Colors.grey[400] : Colors.black, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              _buildSectionLabel('PRIORITY LEVEL'),
              GestureDetector(
                onTap: () => setState(() => _isUrgent = !_isUrgent),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: _isUrgent ? Colors.red.shade50 : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _isUrgent ? Colors.red.shade200 : Colors.transparent, width: 2),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: _isUrgent ? Colors.red : Colors.grey.shade100, shape: BoxShape.circle),
                        child: Icon(_isUrgent ? Icons.local_fire_department_rounded : Icons.flag_rounded, color: _isUrgent ? Colors.white : Colors.grey.shade400, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_isUrgent ? 'Urgent Deadline' : 'Standard Priority', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: _isUrgent ? Colors.red.shade900 : Colors.black)),
                            const SizedBox(height: 4),
                            Text(_isUrgent ? 'This task will be highlighted in red.' : 'Normal priority tracking.', style: TextStyle(color: _isUrgent ? Colors.red.shade700 : Colors.grey[500], fontSize: 13)),
                          ],
                        ),
                      ),
                      Container(
                        width: 24, height: 24,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: _isUrgent ? Colors.red : Colors.grey.shade300, width: 2), color: _isUrgent ? Colors.red : Colors.transparent),
                        child: _isUrgent ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 100), 
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.2)),
    );
  }

  Widget _buildPremiumCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      constraints: const BoxConstraints(minHeight: 60), 
      alignment: Alignment.centerLeft,
      child: child,
    );
  }
}