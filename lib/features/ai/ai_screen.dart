import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // FIX 1: Added 'final' here to clear your linter warning!
  final List<Map<String, String>> _chatHistory = [];
  bool _isLoading = false;

  // WARNING: Paste your actual API key here!
  final String _apiKey = 'AIzaSyBzAsSUzsfoh7eYg1BHOD8KIhpvH78Jvbk'; 

  Future<void> _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _chatHistory.add({'role': 'user', 'text': message});
      _isLoading = true;
    });
    
    _messageController.clear();
    _scrollToBottom();

    try {
      // FIX 2: Upgraded to Google's current active generation!
      final model = GenerativeModel(model: 'gemini-2.5-flash', apiKey: _apiKey);
      
      final response = await model.generateContent([Content.text(message)]);

      setState(() {
        _chatHistory.add({'role': 'ai', 'text': response.text ?? 'I could not generate a response.'});
      });
    } catch (e) {
      setState(() {
        _chatHistory.add({'role': 'ai', 'text': 'Error: Could not connect to AI. Please check your API key and connection.'});
      });
      debugPrint(e.toString());
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
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
        title: const Text('SmartStudy AI', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _chatHistory.isEmpty 
              ? _buildWelcomeUI() 
              : _buildChatList(),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

// --- THE CHAT INTERFACE ---
  Widget _buildChatList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(24.0),
      itemCount: _chatHistory.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading Indicator
        if (index == _chatHistory.length) {
          return const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black)),
            ),
          );
        }

        final msg = _chatHistory[index];
        final isUser = msg['role'] == 'user';

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
            // THE FIX: Replaced Text with MarkdownBody!
            child: MarkdownBody(
              data: msg['text']!,
              selectable: true, // Lets you copy/paste the AI's answers!
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
      },
    );
  }

  // --- THE INPUT FIELD ---
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(24.0).copyWith(top: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF9FAFB),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.grey.shade300)),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Ask anything about your courses...',
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

  // --- THE ORIGINAL WELCOME UI ---
  Widget _buildWelcomeUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
            child: const Icon(Icons.auto_awesome, color: Colors.black, size: 32),
          ),
          const SizedBox(height: 24),
          const Text(
            'How can I assist your\nstudies?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, height: 1.2),
          ),
          const SizedBox(height: 12),
          Text(
            'Your academic curator is ready to summarize, plan, or solve complex problems.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14, height: 1.4),
          ),
          const SizedBox(height: 48),
          _buildAiActionCard(icon: Icons.description_outlined, title: 'Summarize my notes', subtitle: 'Turn long lectures into concise bullet points.'),
          _buildAiActionCard(icon: Icons.calendar_today_outlined, title: 'Plan my week', subtitle: 'Optimize your schedule for upcoming exams.'),
          _buildAiActionCard(icon: Icons.calculate_outlined, title: 'Help with Calculus', subtitle: 'Step-by-step guidance for complex equations.'),
        ],
      ),
    );
  }

  Widget _buildAiActionCard({required IconData icon, required String title, required String subtitle}) {
    return InkWell(
      onTap: () {
        _messageController.text = title;
        _sendMessage();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.grey[500], size: 24),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 4),
            Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          ],
        ),
      ),
    );
  }
}