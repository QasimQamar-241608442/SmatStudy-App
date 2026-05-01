import 'package:flutter/material.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text('SmartStudy', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.black), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- SEARCH BAR ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  icon: const Icon(Icons.search, color: Colors.black87),
                  hintText: 'Search courses, files, or de', // Matching mockup cut-off
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
                  border: InputBorder.none,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- FILTER RESULTS ---
            const Text('FILTER RESULTS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFilterChip('All', Icons.all_inclusive, isActive: true),
                _buildFilterChip('Courses', Icons.school),
                _buildFilterChip('Deadlines', Icons.calendar_today),
                _buildFilterChip('Files', Icons.insert_drive_file),
                _buildFilterChip('Professors', Icons.person),
              ],
            ),
            const SizedBox(height: 40),

            // --- RECENT ACTIVITY ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('RECENT ACTIVITY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
                Text('CLEAR ALL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red.shade700)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  _buildRecentTile('Organic Chemistry Finals Prep'),
                  const Divider(height: 1, indent: 48, color: Colors.white),
                  _buildRecentTile('Macroeconomics Syllabus 2024'),
                  const Divider(height: 1, indent: 48, color: Colors.white),
                  _buildRecentTile('Advanced Algorithms Assignment 3'),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- URGENT DEADLINE FOUND ---
            Container(
              decoration: BoxDecoration(
                color: Colors.red.shade50.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    Container(width: 4, decoration: const BoxDecoration(color: Colors.red, borderRadius: BorderRadius.horizontal(left: Radius.circular(12)))),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('URGENT DEADLINE FOUND', style: TextStyle(color: Colors.red.shade700, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                                const Icon(Icons.priority_high, color: Colors.red, size: 20),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text('Calculus II Midterm\nProject', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.2)),
                            const SizedBox(height: 12),
                            Text("Due in 14 hours. Your last search for 'Integration Methods' is related to this task.", style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
                              child: const Text('VIEW PROJECT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- AI SUGGESTIONS ---
            const Text('AI SUGGESTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.grey[800], size: 20),
                      const SizedBox(width: 12),
                      const Text('Smart Discovery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey[800], fontSize: 13, height: 1.5, fontFamily: 'Roboto'),
                      children: const [
                        TextSpan(text: "Based on your recent search for "),
                        TextSpan(text: '"Quantum Mechanics"', style: TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                        TextSpan(text: ", you might find these lecture notes useful."),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Resource Tiles
                  _buildResourceTile(Icons.picture_as_pdf, 'Lecture_04_Wave_Function.pdf', 'Shared by Prof. Aris - 2 days ago'),
                  const SizedBox(height: 12),
                  _buildResourceTile(Icons.play_circle_fill, 'Schrödinger\'s Equation Recap', 'Video Recap • 12 mins'),
                  const SizedBox(height: 20),
                  
                  // Explore Group Card Placeholder
                  Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: NetworkImage('https://images.unsplash.com/photo-1635070041078-e363dbe005cb?q=80&w=1000&auto=format&fit=crop'), // Placeholder for the abstract vortex image
                        fit: BoxFit.cover,
                        opacity: 0.7,
                      ),
                    ),
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(16),
                    child: const Text('EXPLORE STUDY GROUP', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(color: isActive ? Colors.black : Colors.grey.shade200, borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: isActive ? Colors.white : Colors.grey[700]),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isActive ? Colors.white : Colors.grey[800])),
        ],
      ),
    );
  }

  Widget _buildRecentTile(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(Icons.history, color: Colors.grey[400], size: 20),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildResourceTile(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: Colors.grey[700], size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
            ],
          ),
        )
      ],
    );
  }
}