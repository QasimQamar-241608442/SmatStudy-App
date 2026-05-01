import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('UPDATES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey[500], letterSpacing: 1.5)),
                    const Text('Notifications', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, height: 1.1)),
                  ],
                ),
                const Text('Mark all as read', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey, decoration: TextDecoration.underline)),
              ],
            ),
            const SizedBox(height: 32),

            // --- URGENT DEADLINES ---
            Row(
              children: [
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                const Text('Urgent Deadlines', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(10)),
                                  child: Icon(Icons.timer_outlined, color: Colors.red.shade700, size: 20),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Expanded(child: Text('Advanced Calculus Quiz', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(6)),
                                            child: Text('2H REMAINING', style: TextStyle(color: Colors.red.shade700, fontSize: 10, fontWeight: FontWeight.bold)),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text('The weekly formative assessment for Chapter 4 is closing soon. Ensure all proofs are uploaded.', style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4)),
                                      const SizedBox(height: 16),
                                      Text('Start Now', style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.bold, fontSize: 13)), // Matches the faded look in mockup
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // --- ACADEMIC ACTIVITY ---
            const Text('Academic Activity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                children: [
                  _buildActivityTile(
                    icon: Icons.star, 
                    title: 'New Grade Released', 
                    time: '15M AGO', 
                    body: 'Your submission for "Macroeconomics Mid-Term" has been graded. You scored ',
                    boldText: '94/100.',
                  ),
                  const Divider(height: 1, indent: 60),
                  _buildActivityTile(
                    icon: Icons.article_outlined, 
                    title: 'New Material: Bio 201', 
                    time: '1H AGO', 
                    body: 'Professor Miller uploaded "Cellular Respiration - Lecture Slides" to the course portal.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- AI STUDY INSIGHTS ---
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Colors.grey[800], size: 16),
                const SizedBox(width: 8),
                const Text('AI Study Insights', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.grey.shade50, shape: BoxShape.circle),
                        child: Icon(Icons.lightbulb_outline, color: Colors.grey[400], size: 20),
                      ),
                      const SizedBox(width: 16),
                      const Text('Focus Pattern Detected', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.5, fontFamily: 'Roboto'), // Adjust font family as needed
                      children: const [
                        TextSpan(text: "You've been most productive on "),
                        TextSpan(text: "Theoretical Physics", style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: " between 9 PM and 11 PM. Should we schedule more deep-work sessions for this slot?"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(backgroundColor: Colors.grey.shade200, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          child: const Text('IGNORE', style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(backgroundColor: Colors.grey.shade700, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                          child: const Text('OPTIMIZE SCHEDULE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- EARLIER THIS WEEK ---
            Text('Earlier this week', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey[500])),
            const SizedBox(height: 12),
            _buildEarlierTile(Icons.calendar_today, 'Class rescheduled: Art History', 'Monday, Oct 14 • 2:00 PM'),
            const SizedBox(height: 8),
            _buildEarlierTile(Icons.mail_outline, 'Advisor Meeting Confirmation', 'Friday, Oct 11 • 10:15 AM'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTile({required IconData icon, required String title, required String time, required String body, String? boldText}) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: Colors.grey[600], size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(time, style: TextStyle(color: Colors.grey[500], fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 4),
                RichText(
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4, fontFamily: 'Roboto'),
                    children: [
                      TextSpan(text: body),
                      if (boldText != null) TextSpan(text: boldText, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarlierTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[400], size: 20),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey[800])),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}