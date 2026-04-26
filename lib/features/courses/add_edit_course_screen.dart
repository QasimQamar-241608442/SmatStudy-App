import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEditCourseScreen extends StatefulWidget {
  final String semesterId; 

  const AddEditCourseScreen({
    super.key,
    required this.semesterId,
  });

  @override
  State<AddEditCourseScreen> createState() => _AddEditCourseScreenState();
}

class _AddEditCourseScreenState extends State<AddEditCourseScreen> {
  // 1. Text controllers for our fields
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _professorController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  // New Controller for Section
  final TextEditingController _sectionController = TextEditingController();

  // 2. Data states
  // Updated list for session maps
  final List<Map<String, dynamic>> _sessions = [];
  // New state for Credit Hours (int counter)
  int _creditHours = 3; // Default university class

  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    _titleController.dispose();
    _professorController.dispose();
    _locationController.dispose();
    _sectionController.dispose(); // Always dispose of controllers
    super.dispose();
  }

  Future<void> _saveCourse() async {
    // Validation
    if (_codeController.text.isEmpty || _titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Course Code and Title are required.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final String uid = FirebaseAuth.instance.currentUser!.uid;

      // 3. Database Injection: Now including Section and Credit Hours
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('semesters')
          .doc(widget.semesterId)
          .collection('courses')
          .add({
        'code': _codeController.text.trim(),
        'title': _titleController.text.trim(),
        'professor': _professorController.text.trim(),
        'location': _locationController.text.trim(),
        'section': _sectionController.text.trim(), // New database field
        'creditHours': _creditHours, // New database field
        'sessions': _sessions, 
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save course: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Session Picker Logic from Turn 18 remains the same
  void _openSessionPicker() {
    final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    String selectedDay = 'Monday';
    TimeOfDay? startTime;
    TimeOfDay? endTime;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Add Class Session', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),

                  const Text('DAY OF THE WEEK', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: days.map((day) {
                      final bool isSelected = selectedDay == day;
                      return ChoiceChip(
                        label: Text(day, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontSize: 13)),
                        selected: isSelected,
                        selectedColor: Colors.black,
                        backgroundColor: Colors.grey[100],
                        showCheckmark: false,
                        onSelected: (bool selected) {
                          if (selected) {
                            setModalState(() => selectedDay = day); 
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('START TIME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime: const TimeOfDay(hour: 9, minute: 0),
                                );
                                if (picked != null) {
                                  setModalState(() => startTime = picked);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(startTime?.format(context) ?? 'Select Time', style: TextStyle(color: startTime == null ? Colors.grey : Colors.black, fontWeight: FontWeight.w600)),
                                    const Icon(Icons.access_time, size: 18, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('END TIME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: () async {
                                final TimeOfDay? picked = await showTimePicker(
                                  context: context,
                                  initialTime: startTime ?? const TimeOfDay(hour: 10, minute: 0), 
                                );
                                if (picked != null) {
                                  setModalState(() => endTime = picked);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(endTime?.format(context) ?? 'Select Time', style: TextStyle(color: endTime == null ? Colors.grey : Colors.black, fontWeight: FontWeight.w600)),
                                    const Icon(Icons.access_time, size: 18, color: Colors.grey),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (startTime == null || endTime == null) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select both start and end times.')));
                          return;
                        }

                        setState(() {
                          _sessions.add({
                            'day': selectedDay,
                            'start': startTime!.format(context),
                            'end': endTime!.format(context),
                          });
                        });

                        Navigator.pop(context);
                      },
                      child: const Text('Add to Schedule'),
                    ),
                  ),
                  const SizedBox(height: 16), 
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Session Card rendering remains the same
  Widget _buildSessionCard(Map<String, dynamic> session, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ]
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.schedule, size: 18, color: Colors.blue),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session['day'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 4),
                  Text('${session['start']}  —  ${session['end']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              setState(() {
                _sessions.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('Add New Course', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Course Details', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Enter the core information for this class.', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('CODE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(hintText: 'ECON402'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('COURSE TITLE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _titleController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(hintText: 'Advanced Econometrics'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  // Professor Name (Takes up most of the row)
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('PROFESSOR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _professorController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Prof. Aris',
                            prefixIcon: Icon(Icons.person_outline, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // New Section Input (Takes up less space)
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('SECTION', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _sectionController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            hintText: 'e.g. 01',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),

              const Text('LOCATION / ROOM', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              TextField(
                controller: _locationController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'e.g. Hall 405 • Section B',
                  prefixIcon: Icon(Icons.business_outlined, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 40),

              // THE NEW CREDIT HOURS COUNTER (Benchmarked from School Planner App)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Credit Hours', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('Weightage in your curriculum', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                    ],
                  ),
                  // The - Number + Interface
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: _creditHours > 1 ? () => setState(() => _creditHours--) : null,
                          icon: Icon(Icons.remove_circle_outline, color: _creditHours > 1 ? Colors.grey[700] : Colors.grey[300]),
                        ),
                        SizedBox(width: 20, child: Center(child: Text('$_creditHours', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
                        IconButton(
                          onPressed: () => setState(() => _creditHours++),
                          icon: Icon(Icons.add_circle_outline, color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  )
                ],
              ),

              const SizedBox(height: 40),

              // Class Sessions header
              const Text('CLASS SESSIONS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 16),
              
              if (_sessions.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                  child: const Center(child: Text('No class sessions added yet.', style: TextStyle(color: Colors.grey))),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    return _buildSessionCard(_sessions[index], index);
                  },
                ),
              
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: _openSessionPicker,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue[50],
                    foregroundColor: Colors.blue[700],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Class Time', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveCourse,
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Course'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}