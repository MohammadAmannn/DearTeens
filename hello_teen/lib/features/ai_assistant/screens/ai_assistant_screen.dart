import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({Key? key}) : super(key: key);

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  late final GenerativeModel _model;
  late final ChatSession _chat;

  final List<Map<String, dynamic>> _suggestedQuestions = [
    {'text': 'What is puberty?',            'icon': Icons.child_care_rounded,  'color': AppColors.primary},
    {'text': 'How do I manage period cramps?','icon': Icons.water_drop_rounded, 'color': Colors.pink},
    {'text': 'Why do I feel anxious?',       'icon': Icons.psychology_rounded,  'color': AppColors.secondary},
    {'text': 'What are good hygiene habits?','icon': Icons.soap_rounded,        'color': AppColors.accent},
    {'text': 'Foods for better energy?',     'icon': Icons.restaurant_rounded,  'color': AppColors.warning},
    {'text': 'How to improve my mood?',      'icon': Icons.mood_rounded,        'color': AppColors.success},
  ];

  @override
  void initState() {
    super.initState();
    _initModel();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initModel() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'PASTE_YOUR_GEMINI_API_KEY_HERE') {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': 'API key not configured. Please add your Gemini API key in the .env file.',
        });
      });
      return;
    }

    _model = GenerativeModel(
      model: 'gemini-3.1-flash-lite-preview',
      apiKey: apiKey,
      systemInstruction: Content.system('''
You are TeenCare AI, a safe and educational health assistant designed only for teenagers aged 13-19.

Your role is to answer questions related ONLY to:
• puberty and body changes
• menstruation and menstrual health
• emotional changes during teenage years
• hygiene and personal care
• mental health and stress
• nutrition for teenagers
• normal physical development
• common teenage health concerns

Rules you MUST follow:
1. If a question is unrelated to teenage health, politely refuse.
2. Never answer questions about hacking, politics, money, coding, or general knowledge.
3. Always respond in a friendly, supportive and educational tone.
4. Do NOT provide medical diagnosis. Encourage consulting a doctor when necessary.
5. Use emojis appropriately to make responses feel warm and teen-friendly.
6. Keep responses concise and easy to understand.

If a question is outside your scope say:
"I'm here to help with questions about teenage health, puberty, hygiene, and emotional well-being. Please ask something related to those topics. 💕"
'''),
    );
    _chat = _model.startChat();
    setState(() {
      _messages.add({
        'role': 'assistant',
        'text': 'Hi there! 👋 I\'m your TeenCare AI assistant. I\'m here to answer your questions about puberty, mental health, hygiene, and body changes — completely anonymously! What would you like to know? 💕',
      });
    });
  }

  Future<void> _sendMessage([String? presetText]) async {
    final text = presetText ?? _promptController.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });
    _promptController.clear();
    _scrollToBottom();

    try {
      final response = await _chat.sendMessage(Content.text(text));
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': response.text ?? 'I could not generate an answer. Please try again.',
        });
      });
    } catch (e) {
      setState(() {
        _messages.add({
          'role': 'assistant',
          'text': 'Sorry, I couldn\'t connect right now. Please check your connection and try again. 💕',
        });
      });
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: AppColors.secondaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TeenCare AI',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text('Safe & Anonymous',
                    style: GoogleFonts.poppins(fontSize: 10, color: Colors.white70)),
              ],
            ),
          ],
        ),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Color(0xFF69FF47),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 5),
                Text('Online',
                    style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_messages.length <= 1) _buildSuggestedQuestions(),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              physics: const BouncingScrollPhysics(),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                return _ChatBubble(
                  text: msg['text']!,
                  isUser: isUser,
                  delay: (index * 50).ms,
                );
              },
            ),
          ),
          if (_isLoading) _buildTypingIndicator(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildSuggestedQuestions() {
    final surface = Theme.of(context).colorScheme.surface;
    return Container(
      decoration: BoxDecoration(
        color: surface,
        border: const Border(bottom: BorderSide(color: AppColors.cardBorder)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick questions:',
              style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedQuestions.map((q) {
              final qColor = q['color'] as Color;
              return GestureDetector(
                onTap: () => _sendMessage(q['text'] as String),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: qColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: qColor.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(q['icon'] as IconData, size: 14, color: qColor),
                      const SizedBox(width: 6),
                      Text(
                        q['text'] as String,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: qColor,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 60, 4),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
          ),
          border: const Border.fromBorderSide(BorderSide(color: AppColors.cardBorder)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DotBounce(delay: 0.ms),
            const SizedBox(width: 5),
            _DotBounce(delay: 150.ms),
            const SizedBox(width: 5),
            _DotBounce(delay: 300.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    final surface = Theme.of(context).colorScheme.surface;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: BoxDecoration(
        color: surface,
        border: const Border(top: BorderSide(color: AppColors.cardBorder)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(28),
                  border: const Border.fromBorderSide(
                      BorderSide(color: AppColors.cardBorder)),
                ),
                child: TextField(
                  controller: _promptController,
                  maxLines: 4,
                  minLines: 1,
                  style: GoogleFonts.poppins(
                    color: AppColors.textMain,
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ask anything about your health...',
                    hintStyle: GoogleFonts.poppins(
                        color: AppColors.textHint, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: _isLoading ? null : () => _sendMessage(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: _isLoading
                      ? null
                      : const LinearGradient(
                          colors: AppColors.secondaryGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: _isLoading ? AppColors.cardBorder : null,
                  shape: BoxShape.circle,
                  boxShadow: _isLoading
                      ? null
                      : [
                          BoxShadow(
                            color: AppColors.secondary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Icon(
                  _isLoading ? Icons.hourglass_top_rounded : Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Chat Bubble
// ─────────────────────────────────────────────────────────────────────────────
class _ChatBubble extends StatelessWidget {
  final String text;
  final bool isUser;
  final Duration delay;

  const _ChatBubble(
      {required this.text, required this.isUser, required this.delay});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.fromLTRB(
          isUser ? 48 : 0,
          4,
          isUser ? 0 : 48,
          4,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          gradient: isUser
              ? const LinearGradient(
                  colors: AppColors.secondaryGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isUser ? null : surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          border: isUser
              ? null
              : const Border.fromBorderSide(
                  BorderSide(color: AppColors.cardBorder)),
          boxShadow: [
            BoxShadow(
              color: isUser
                  ? AppColors.secondary.withOpacity(0.25)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: isUser ? Colors.white : AppColors.textMain,
            height: 1.5,
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms, delay: delay)
        .slideY(begin: 0.1, end: 0, duration: 300.ms, delay: delay);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated Typing Dot
// ─────────────────────────────────────────────────────────────────────────────
class _DotBounce extends StatelessWidget {
  final Duration delay;
  const _DotBounce({required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 8,
      height: 8,
      decoration: const BoxDecoration(
          color: AppColors.secondary, shape: BoxShape.circle),
    )
        .animate(onPlay: (c) => c.repeat())
        .moveY(begin: 0, end: -6, duration: 400.ms, delay: delay, curve: Curves.easeOut)
        .then()
        .moveY(begin: -6, end: 0, duration: 400.ms, curve: Curves.easeIn);
  }
}
