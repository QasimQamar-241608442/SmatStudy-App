import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Header (Greeting & Avatar)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Good Morning, Qasim',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Let's stay on track today",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
              // Placeholder for Profile Picture
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.grey, size: 28),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // 2. Global Search Bar
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha:0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search courses, assignments...',
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 3. Section Title
          const Text(
            "TODAY'S SCHEDULE",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0),
          ),
          const SizedBox(height: 16),

          // 4. Schedule Card
          Container(
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
              children: [
                _buildScheduleItem('09:00 AM', 'Calculus Lecture', 'Room 201 • Section A', true),
                const Divider(height: 32),
                _buildScheduleItem('11:30 AM', 'Advanced Econometrics', 'Hall 405 • Section B', false),
                const Divider(height: 32),
                _buildScheduleItem('03:00 PM', 'Study Session', 'Library Room 4B', false),
              ],
            ),
          ),
          const SizedBox(height: 32),
          
          // Next cards (Deadlines, AI Insights) will go here!
          // 5. Critical Deadlines Header
          Row(
            children: [
              Icon(Icons.error, color: Colors.red[700], size: 16),
              const SizedBox(width: 8),
              const Text(
                "CRITICAL DEADLINES",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 6. Deadline Cards
          _buildDeadlineCard(
            title: 'Mobile App Development Proposal',
            subtitle: 'Final submission of research proposal and abstract.',
            date: 'APR 1, 23:59',
            rightActionText: 'SUBMIT NOW',
            isOverdue: true,
          ),
          _buildDeadlineCard(
            title: 'Operating Systems Quiz 4',
            subtitle: 'Covers process management and memory allocation.',
            date: 'TOMORROW, 09:00',
            rightActionText: '14H LEFT',
            isOverdue: false,
          ),
          _buildDeadlineCard(
            title: 'Math Problem Set #8',
            subtitle: 'Fourier Series and Laplace Transformations.',
            date: 'FRIDAY, 17:00',
            rightActionText: '3 DAYS LEFT',
            isOverdue: false,
          ),
          // 7. AI Study Recommendation Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black, // Dark card for contrast
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('AI Insights', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '"Your concentration peaks between 10 AM and 12 PM. Schedule your hardest Mobile App Development tasks for tomorrow morning for better retention."',
                  style: TextStyle(color: Colors.grey[300], fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text('VIEW DETAILED ANALYSIS', style: TextStyle(color: Colors.grey[400], fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right, color: Colors.grey[400], size: 16),
                  ],
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 8. Weekly Progress Card
          Container(
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('WEEKLY PROGRESS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
                    Text('8 / 12 Tasks', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('72', style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, height: 1.0)),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 8.0),
                      child: Text('%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    const Spacer(),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('Target: 85%', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // The Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: 0.72, // 72%
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48), // Extra padding at the very bottom so content doesn't get hidden behind the navigation bar
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // A small helper widget to keep our schedule list clean and reusable
  Widget _buildScheduleItem(String time, String title, String subtitle, bool isNow) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(
            time,
            style: TextStyle(
              fontWeight: isNow ? FontWeight.bold : FontWeight.normal,
              color: isNow ? Colors.black : Colors.grey,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
            ],
          ),
        ),
        if (isNow)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text('NOW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
  // Helper widget for Deadline Cards
  Widget _buildDeadlineCard({
    required String title,
    required String subtitle,
    required String date,
    required String rightActionText,
    required bool isOverdue,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      // ClipRRect ensures the left border doesn't poke outside our rounded corners
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isOverdue ? Colors.red : Colors.red.shade200,
                width: 4,
              ),
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Title & Optional Overdue Badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isOverdue) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('OVERDUE', style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ]
                ],
              ),
              const SizedBox(height: 4),
              
              // Description
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 16),
              
              // Bottom Row: Date & Countdown/Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    date, 
                    style: TextStyle(
                      color: isOverdue ? Colors.red : Colors.grey, 
                      fontSize: 12, 
                      fontWeight: FontWeight.bold
                    )
                  ),
                  Text(
                    rightActionText, 
                    style: TextStyle(
                      color: isOverdue ? Colors.black : Colors.grey, 
                      fontSize: 12, 
                      fontWeight: FontWeight.bold, 
                      decoration: isOverdue ? TextDecoration.underline : TextDecoration.none
                    )
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}