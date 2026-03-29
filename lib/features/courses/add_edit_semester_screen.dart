import 'package:flutter/material.dart';

class AddEditSemesterScreen extends StatefulWidget {
  const AddEditSemesterScreen({super.key});

  @override
  State<AddEditSemesterScreen> createState() => _AddEditSemesterScreenState();
}

class _AddEditSemesterScreenState extends State<AddEditSemesterScreen> {
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
              // 1. Header Section
              const Text(
                'Semester Details',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Organize your academic journey by defining your semester timeframe.',
                style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 32),

              // 2. Semester Name Input
              const Text('SEMESTER NAME', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(
                  hintText: 'e.g. Fall 2024',
                ),
              ),
              const SizedBox(height: 24),

              // 3. Date Pickers (Using custom containers to match Figma precisely)
              const Text('START DATE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              _buildDatePickerField('mm/dd/yyyy'),
              
              const SizedBox(height: 24),

              const Text('END DATE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
              const SizedBox(height: 8),
              _buildDatePickerField('mm/dd/yyyy'),
              
              const SizedBox(height: 32),

              // 4. AI Timeline Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[200], // Slightly darker grey for contrast
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Academic Timeline', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Text(
                      'Visualizing your upcoming commitment period.',
                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
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

              // 5. Action Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // For now, just pop back to the previous screen
                    Navigator.pop(context);
                  },
                  child: const Text('Save Semester'),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                  child: const Text('Cancel Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget: Simulates a Date Picker Input
  Widget _buildDatePickerField(String hintText) {
    return InkWell(
      onTap: () {
        // Later, we will trigger Flutter's native showDatePicker() here
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
             BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined, color: Colors.black, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hintText,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
            ),
            const Icon(Icons.calendar_month, color: Colors.black, size: 20),
          ],
        ),
      ),
    );
  }
}