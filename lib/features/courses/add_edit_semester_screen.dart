import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddEditSemesterScreen extends StatefulWidget {
  const AddEditSemesterScreen({super.key});

  @override
  State<AddEditSemesterScreen> createState() => _AddEditSemesterScreenState();
}

class _AddEditSemesterScreenState extends State<AddEditSemesterScreen> {
  // Controller for the semester name
  final TextEditingController _nameController = TextEditingController();
  
  // Variables to store our selected dates
  DateTime? _startDate;
  DateTime? _endDate;
  
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  // 1. Function to trigger the native calendar popup
  Future<void> _pickDate(bool isStart) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.black, // Makes the calendar black/white to match our theme
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          _startDate = pickedDate;
        } else {
          _endDate = pickedDate;
        }
      });
    }
  }

  // 2. Function to save data to Firestore
  Future<void> _saveSemester() async {
    // Validation: Ensure nothing is empty
    if (_nameController.text.isEmpty || _startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a name and select both dates.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the currently logged-in user's ID
      final String uid = FirebaseAuth.instance.currentUser!.uid;

      // Save to Firestore under users -> [user_id] -> semesters
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('semesters')
          .add({
        'name': _nameController.text.trim(),
        'startDate': Timestamp.fromDate(_startDate!),
        'endDate': Timestamp.fromDate(_endDate!),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Close the screen after saving
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Semester Details', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Organize your academic journey by defining your semester timeframe.', style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4)),
              const SizedBox(height: 32),

              const Text('SEMESTER NAME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(hintText: 'e.g. Fall 2026'),
              ),
              const SizedBox(height: 24),

              const Text('START DATE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              _buildDatePickerField(
                isStart: true,
                date: _startDate,
              ),
              
              const SizedBox(height: 24),

              const Text('END DATE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              _buildDatePickerField(
                isStart: false,
                date: _endDate,
              ),
              
              const SizedBox(height: 32),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Academic Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text('Visualizing your upcoming commitment period.', style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, size: 16, color: Colors.black),
                          SizedBox(width: 8),
                          Text('AI OPTIMIZED', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 48),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSemester,
                  child: _isLoading 
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Save Semester'),
                ),
              ),
              const SizedBox(height: 16),
              
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey[700]),
                  child: const Text('Cancel Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for the Date Pickers
  Widget _buildDatePickerField({required bool isStart, required DateTime? date}) {
    // Simple formatting so we don't have to install another package right now
    final String displayText = date == null 
        ? 'mm/dd/yyyy' 
        : '${date.month}/${date.day}/${date.year}';

    return GestureDetector(
      onTap: () => _pickDate(isStart),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
             BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: Colors.black, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                displayText,
                style: TextStyle(color: date == null ? Colors.grey : Colors.black, fontSize: 16),
              ),
            ),
            const Icon(Icons.calendar_month, color: Colors.black, size: 20),
          ],
        ),
      ),
    );
  }
}