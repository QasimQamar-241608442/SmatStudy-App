import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

// Ensure these paths match your project structure
import '../search/global_search_screen.dart';
import '../notifications/notifications_screen.dart';

class GlobalAiScreen extends StatefulWidget {
  const GlobalAiScreen({super.key});

  @override
  State<GlobalAiScreen> createState() => _GlobalAiScreenState();
}

class _GlobalAiScreenState extends State<GlobalAiScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // WARNING: Paste your actual Gemini API key here!
  final String _apiKey = 'AIzaSyBzAsSUzsfoh7eYg1BHOD8KIhpvH78Jvbk';

  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  // Global Chat Reference in Firebase
  CollectionReference get _chatRef => FirebaseFirestore.instance
      .collection('users')
      .doc(_userId)
      .collection('global_ai_chats');

  Future<void> _sendMessage({String? predefinedMessage}) async {
    final message = predefinedMessage ?? _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    setState(() => _isLoading = true);
    _scrollToBottom();

    try {
      // 1. Save User Message
      await _chatRef.add({
        'role': 'user',
        'text': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. Call Gemini (Global Context)
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
      final prompt = "You are SmartStudy AI, an elite, highly intelligent academic tutor. Answer the student's query concisely, clearly, and use markdown for formatting if needed: $message";
      
      final response = await model.generateContent([Content.text(prompt)]);

      // 3. Save AI Response
      await _chatRef.add({
        'role': 'ai',
        'text': response.text ?? 'I could not generate a response.',
        'timestamp': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error connecting to AI: $e'), backgroundColor: Colors.red.shade800),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showPdfUploadSimulation() {
    // Simulating a PDF upload process since true local file reading requires external packages
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('PDF Parsing Engine coming in Phase 3. Tell me what the document is about instead!'),
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: Colors.black, size: 20),
            SizedBox(width: 8),
            Text('SmartStudy AI', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GlobalSearchScreen())),
          ),
          IconButton(
            icon: const Badge(backgroundColor: Colors.red, child: Icon(Icons.notifications_none, color: Colors.black)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatRef.orderBy('timestamp', descending: false).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.black));
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildWelcomeUI();
                }

                final messages = snapshot.data!.docs;
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(24.0),
                  itemCount: messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == messages.length) {
                      return const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)),
                        ),
                      );
                    }

                    final msg = messages[index].data() as Map<String, dynamic>;
                    final isUser = msg['role'] == 'user';

                    return _buildChatBubble(msg['text'] ?? '', isUser);
                  },
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildWelcomeUI() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))]),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'How can I help you\nstudy today?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -0.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Upload your syllabus, ask complex questions, or let me build a personalized study plan.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 40),
            
            // Quick Action Cards
            _buildQuickActionCard(
              icon: Icons.upload_file,
              title: 'Summarize Document',
              subtitle: 'Upload a PDF to extract key concepts.',
              onTap: _showPdfUploadSimulation,
            ),
            _buildQuickActionCard(
              icon: Icons.style,
              title: 'Generate Flashcards',
              subtitle: 'Create a quick review set for an upcoming exam.',
              onTap: () => _sendMessage(predefinedMessage: 'Can you generate 5 complex flashcards for Organic Chemistry?'),
            ),
            _buildQuickActionCard(
              icon: Icons.calendar_month,
              title: 'Build Study Plan',
              subtitle: 'Organize my next 7 days of studying.',
              onTap: () => _sendMessage(predefinedMessage: 'I have a Calculus Midterm in 7 days. Can you build me a daily study schedule?'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.black, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
        decoration: BoxDecoration(
          color: isUser ? Colors.black : Colors.white,
          border: isUser ? null : Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(0),
          )
        ),
        child: MarkdownBody(
          data: text,
          selectable: true,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15, height: 1.4),
            strong: TextStyle(color: isUser ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
            em: TextStyle(color: isUser ? Colors.white70 : Colors.black54, fontStyle: FontStyle.italic),
            listBullet: TextStyle(color: isUser ? Colors.white : Colors.black),
            code: TextStyle(backgroundColor: isUser ? Colors.grey[800] : Colors.grey[100], color: isUser ? Colors.white : Colors.red.shade800, fontFamily: 'monospace'),
            codeblockDecoration: BoxDecoration(color: isUser ? Colors.grey[900] : Colors.grey[100], borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(24.0).copyWith(top: 12),
      color: const Color(0xFFF9FAFB),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade300)),
        child: Row(
          children: [
            // Attach PDF Button
            IconButton(
              icon: Icon(Icons.attach_file, color: Colors.grey[600]),
              onPressed: _showPdfUploadSimulation,
            ),
            Expanded(
              child: TextField(
                controller: _messageController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Message SmartStudy AI...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            Container(
              decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 20),
                onPressed: _isLoading ? null : () => _sendMessage(),
              ),
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }
}