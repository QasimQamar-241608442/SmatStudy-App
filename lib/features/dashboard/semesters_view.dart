import 'package:flutter/material.dart';
import 'courses_view.dart';
import '../courses/add_edit_semester_screen.dart';


class SemestersView extends StatelessWidget {
  const SemestersView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Priority Action Card
          const Text(
            'Priority Action',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black, width: 2), // Distinct thick border from Figma
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.calendar_today, color: Colors.red[400]),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('View Deadlines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text('4 assignments due in the next 72 hours', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text('Open Schedule', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right, color: Colors.red[700], size: 16),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 40),

          // 2. Academic Journey Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Academic\nJourney',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
              ),
              Text(
                '2025 — 2026 Academic\nYear',
                textAlign: TextAlign.right,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. Semester Cards
          _buildSemesterCard(
            context: context,
            status: 'UPCOMING',
            title: 'Fall 2026',
            details: '5 Courses • 18 Credits Total',
            tags: ['CS50', 'MATH22', 'PHYS01'],
            progress: 0.0,
          ),
          _buildSemesterCard(
            context: context,
            status: 'IN PROGRESS',
            title: 'Spring 2026',
            details: '4 Courses • 15 Credits Total',
            tags: [],
            progress: 0.75, // Week 12 of 16
            progressText: 'WEEK 12 OF 16',
          ),
          
          // 4. Add Semester Button (Now wrapped in a GestureDetector!)
          GestureDetector(
            onTap: () {
              // This is the code that runs when the user taps the box!
              // It pushes the new AddEditSemesterScreen onto the screen.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddEditSemesterScreen(),
                ),
              );
            },
            child: Container( // <-- This is where your original code starts
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300, style: BorderStyle.solid), 
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add, color: Colors.black),
                  ),
                  const SizedBox(height: 16),
                  const Text('Add Semester', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text('Plan your next academic\nmilestone', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                ],
              ),
            ),
          ), // <-- Closing parenthesis for the GestureDetector!
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // Helper Widget for Semester Cards
  Widget _buildSemesterCard({
    required BuildContext context,
    required String status,
    required String title,
    required String details,
    required List<String> tags,
    required double progress,
    String? progressText,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(status, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
              const Icon(Icons.more_vert, color: Colors.grey, size: 20),
            ],
          ),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(details, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const SizedBox(height: 16),
          
          if (tags.isNotEmpty)
            Row(
              children: tags.map((tag) => Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(4)),
                child: Text(tag, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
              )).toList(),
            ),
            
          if (progress > 0) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.grey),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 8),
            Text(progressText ?? '', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          ],
          
          const SizedBox(height: 24),
          const Divider(height: 1),
          const SizedBox(height: 16),
          
          // Navigation Trigger!
          InkWell(
            onTap: () {
              // This pushes the Courses screen over the entire app, hiding the bottom tabs
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CoursesView(),
                ),
              );
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('View Courses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}