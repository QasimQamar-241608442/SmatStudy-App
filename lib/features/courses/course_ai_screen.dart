import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class CourseAiScreen extends StatefulWidget {
  final String courseId;
  final String courseName;

  const CourseAiScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<CourseAiScreen> createState() => _CourseAiScreenState();
}

class _CourseAiScreenState extends State<CourseAiScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;

  // WARNING: Paste your actual Gemini API key here!
  final String _apiKey = 'AIzaSyBzAsSUzsfoh7eYg1BHOD8KIhpvH78Jvbk';

  // Helper to securely get the current logged-in user's ID
  String get _userId => FirebaseAuth.instance.currentUser!.uid;

  // This is the magic path! It points directly to this exact course's chat folder in Firebase
  CollectionReference get _chatRef => FirebaseFirestore.instance
      .collection('users')
      .doc(_userId)
      .collection('courses')
      .doc(widget.courseId)
      .collection('ai_chats');

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    _messageController.clear();
    setState(() => _isLoading = true);
    _scrollToBottom();

    try {
      // 1. Immediately save the user's message to Firebase
      await _chatRef.add({
        'role': 'user',
        'text': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // 2. Call Gemini (We secretly tell the AI which course it is tutoring behind the scenes!)
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
      final prompt = "You are a dedicated university teaching assistant for the course '${widget.courseName}'. Answer the following student query concisely and accurately: $message";
      
      final response = await model.generateContent([Content.text(prompt)]);

      // 3. Save the AI's response to Firebase
      await _chatRef.add({
        'role': 'ai',
        'text': response.text ?? 'I could not generate a response.',
        'timestamp': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      debugPrint(e.toString());
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Could not connect to AI. $e'), backgroundColor: Colors.red.shade800),
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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFB),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black), // Black back arrow
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${widget.courseName} Tutor', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
            const Text('AI Assistant', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              // This Stream Builder continuously watches Firebase for new messages!
              stream: _chatRef.orderBy('timestamp', descending: false).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.black));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return _buildWelcomeUI();
                }

                final messages = snapshot.data!.docs;

                // Auto-scroll logic when new Firebase documents arrive
                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(24.0),
                  itemCount: messages.length + (_isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    // Show loading spinner if AI is thinking
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
            code: TextStyle(
              backgroundColor: isUser ? Colors.grey[800] : Colors.grey[200], 
              color: isUser ? Colors.white : Colors.black, 
              fontFamily: 'monospace',
            ),
            codeblockDecoration: BoxDecoration(
              color: isUser ? Colors.grey[900] : Colors.grey[100], 
              borderRadius: BorderRadius.circular(8),
            ),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade300)),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ask your ${widget.courseName} tutor...',
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
                onPressed: _isLoading ? null : _sendMessage,
              ),
            )
          ],
        ),
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
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: const Icon(Icons.school_outlined, color: Colors.black, size: 32),
            ),
            const SizedBox(height: 24),
            Text(
              'Your ${widget.courseName}\nTeaching Assistant',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.2),
            ),
            const SizedBox(height: 12),
            Text(
              'I remember everything about this course. Feed me the syllabus, paste lecture notes, or ask me to generate a custom quiz.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}