import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/constants/app_colors.dart';

// ─── Mood Data ────────────────────────────────────────────────────────────────
class MoodEntry {
  final String id;
  final String mood;
  final String note;
  final String aiSuggestion;
  final DateTime timestamp;

  MoodEntry({
    required this.id,
    required this.mood,
    required this.note,
    required this.aiSuggestion,
    required this.timestamp,
  });

  factory MoodEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MoodEntry(
      id: doc.id,
      mood: data['mood'] ?? '',
      note: data['note'] ?? '',
      aiSuggestion: data['aiSuggestion'] ?? '',
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final moodEntriesProvider = StreamProvider<List<MoodEntry>>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value([]);
  return FirebaseFirestore.instance
      .collection('mood_companion_logs')
      .where('userId', isEqualTo: uid)
      .orderBy('timestamp', descending: true)
      .limit(30)
      .snapshots()
      .map((s) => s.docs.map(MoodEntry.fromFirestore).toList());
});

// ─── Screen ───────────────────────────────────────────────────────────────────
class MoodCompanionScreen extends ConsumerStatefulWidget {
  const MoodCompanionScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MoodCompanionScreen> createState() => _MoodCompanionScreenState();
}

class _MoodCompanionScreenState extends ConsumerState<MoodCompanionScreen>
    with TickerProviderStateMixin {
  String? _selectedMood;
  bool _isSaving = false;
  bool _showSuggestion = false;
  String _aiSuggestion = '';
  final TextEditingController _noteController = TextEditingController();
  late AnimationController _waveController;

  final List<Map<String, dynamic>> _moods = [
    {
      'label': 'happy',
      'display': 'Happy',
      'emoji': '😊',
      'color': const Color(0xFFFF6B9A),
      'bgColor': const Color(0xFFFFEEF5),
      'tip': 'Wonderful! Celebrate this happy moment. Try journaling what made you smile today! 🌟',
      'activity': 'Share your positive energy — call a friend or do something creative!',
      'breath': '4-4-4 breathing: Inhale joy, exhale love.',
    },
    {
      'label': 'calm',
      'display': 'Calm',
      'emoji': '😌',
      'color': const Color(0xFF7C7CF8),
      'bgColor': const Color(0xFFF0EEFF),
      'tip': 'This peaceful state is precious. Use it for reflection or creative activities. 🌸',
      'activity': 'Perfect time to meditate, read, or journal about your goals.',
      'breath': 'Deep breathing: 4 counts in, 6 counts out for deeper calm.',
    },
    {
      'label': 'sad',
      'display': 'Sad',
      'emoji': '😢',
      'color': const Color(0xFF2196F3),
      'bgColor': const Color(0xFFE3F2FD),
      'tip': 'It\'s okay to feel sad. Your feelings are valid and will pass. 💙',
      'activity': 'Try gentle movement, a warm drink, or talk to someone you trust.',
      'breath': 'Calming breath: Inhale for 4, hold for 2, exhale for 8.',
    },
    {
      'label': 'anxious',
      'display': 'Anxious',
      'emoji': '😰',
      'color': const Color(0xFFFF9800),
      'bgColor': const Color(0xFFFFF8E1),
      'tip': 'Anxiety is normal! Ground yourself with the 5-4-3-2-1 technique. 🌻',
      'activity': 'Name 5 things you see, 4 you touch, 3 you hear, 2 you smell, 1 you taste.',
      'breath': 'Box breathing: 4 in, 4 hold, 4 out, 4 hold. Repeat 4 times.',
    },
    {
      'label': 'excited',
      'display': 'Excited',
      'emoji': '🤩',
      'color': const Color(0xFF43C6AC),
      'bgColor': const Color(0xFFE0F7FA),
      'tip': 'Yay! Channel this energy into something amazing you\'ve been wanting to do! ✨',
      'activity': 'Start that project, dance it out, or share your excitement with friends!',
      'breath': 'Energizing breath: Quick inhale, slow exhale to stay focused.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveMood() async {
    if (_selectedMood == null) return;
    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('Not logged in');

      final moodData = _moods.firstWhere((m) => m['label'] == _selectedMood);

      // Generate AI suggestion
      String suggestion = '${moodData['tip']}\n\n💪 Activity: ${moodData['activity']}\n\n🌬️ Breathing: ${moodData['breath']}';

      try {
        final apiKey = dotenv.env['GEMINI_API_KEY'];
        if (apiKey != null && apiKey.isNotEmpty && apiKey != 'PASTE_YOUR_GEMINI_API_KEY_HERE') {
          final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
          final note = _noteController.text.trim();
          final prompt = 'A teenager is feeling ${moodData['display']} today. ${note.isNotEmpty ? 'They noted: "$note". ' : ''}Give a warm, supportive, educational 2-sentence response with one emoji. Be friendly and teen-appropriate. Include one specific tip.';
          final response = await model.generateContent([Content.text(prompt)]);
          if (response.text != null && response.text!.isNotEmpty) {
            suggestion = response.text!;
          }
        }
      } catch (_) {
        // Use fallback suggestion
      }

      await FirebaseFirestore.instance.collection('mood_companion_logs').add({
        'userId': uid,
        'mood': _selectedMood,
        'note': _noteController.text.trim(),
        'aiSuggestion': suggestion,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _aiSuggestion = suggestion;
        _showSuggestion = true;
        _isSaving = false;
      });
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save: ${e.toString()}',
                style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _reset() {
    setState(() {
      _selectedMood = null;
      _showSuggestion = false;
      _aiSuggestion = '';
      _noteController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE91E8C), Color(0xFFFF6B9A), Color(0xFFFF8CB8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -40, right: -40,
                      child: AnimatedBuilder(
                        animation: _waveController,
                        builder: (_, __) => Container(
                          width: 200 + _waveController.value * 20,
                          height: 200 + _waveController.value * 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20, left: -30,
                      child: Container(
                        width: 150, height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.favorite_rounded,
                                      color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('AI Mood Companion',
                                        style: GoogleFonts.poppins(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    Text('Your daily emotional check-in',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12, color: Colors.white70)),
                                  ],
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
          ),

          // ── Main Content ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _showSuggestion
                  ? _buildSuggestionCard()
                  : _buildMoodSelector(),
            ),
          ),

          // ── History ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
              child: Text(
                'Recent Mood History',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain),
              ).animate().fadeIn(),
            ),
          ),

          // ── History List ──────────────────────────────────────────────────
          ref.watch(moodEntriesProvider).when(
            data: (entries) {
              if (entries.isEmpty) {
                return SliverToBoxAdapter(
                  child: _buildEmptyHistory(),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildHistoryCard(entries[index], index),
                  childCount: entries.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text('Could not load history',
                      style: GoogleFonts.poppins(color: AppColors.textLight)),
                ),
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    final selectedData = _selectedMood != null
        ? _moods.firstWhere((m) => m['label'] == _selectedMood)
        : null;
    final selectedColor = selectedData != null
        ? (selectedData['color'] as Color)
        : AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Daily prompt card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withOpacity(0.12),
                AppColors.secondary.withOpacity(0.06),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text('💬', style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Text(
                    'Daily Check-in',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'How are you feeling today?',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Tap a mood to get personalized AI support ✨',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.05),

        const SizedBox(height: 24),

        // Mood grid
        Text(
          'Select Your Mood',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
          ),
        ).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 16),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemCount: _moods.length,
          itemBuilder: (context, index) {
            final mood = _moods[index];
            final isSelected = _selectedMood == mood['label'];
            final moodColor = mood['color'] as Color;
            final bgColor = mood['bgColor'] as Color;

            return GestureDetector(
              onTap: () => setState(() => _selectedMood = mood['label']),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected ? bgColor : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? moodColor : AppColors.cardBorder,
                    width: isSelected ? 2.5 : 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: isSelected
                          ? moodColor.withOpacity(0.25)
                          : Colors.black.withOpacity(0.04),
                      blurRadius: isSelected ? 16 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedScale(
                      scale: isSelected ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        mood['emoji'] as String,
                        style: const TextStyle(fontSize: 36),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mood['display'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? moodColor : AppColors.textSecondary,
                      ),
                    ),
                    if (isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 24,
                        height: 3,
                        decoration: BoxDecoration(
                          color: moodColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                  ],
                ),
              ).animate(delay: (index * 80).ms)
                  .fadeIn(duration: 300.ms)
                  .slideY(begin: 0.2),
            );
          },
        ),

        const SizedBox(height: 24),

        // Note input
        AnimatedOpacity(
          opacity: _selectedMood != null ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 300),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add a Note (Optional)',
                style: GoogleFonts.poppins(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _selectedMood != null
                        ? selectedColor.withOpacity(0.3)
                        : AppColors.cardBorder,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _noteController,
                  maxLines: 3,
                  enabled: _selectedMood != null,
                  style: GoogleFonts.poppins(
                      color: AppColors.textMain, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Tell me more about how you feel...',
                    hintStyle: GoogleFonts.poppins(
                        color: AppColors.textHint, fontSize: 13),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(16),
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 16, right: 8, top: 14),
                      child: Icon(
                        Icons.edit_note_rounded,
                        color: _selectedMood != null
                            ? selectedColor
                            : AppColors.textHint,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 20),

        // Submit button
        if (_selectedMood != null)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveMood,
              style: ElevatedButton.styleFrom(
                backgroundColor: selectedColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: _isSaving
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Text('Getting AI Support...',
                            style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600, fontSize: 15)),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_awesome_rounded, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Get AI Support & Log Mood',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700, fontSize: 15),
                        ),
                      ],
                    ),
            ),
          ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.95, 0.95)),
      ],
    );
  }

  Widget _buildSuggestionCard() {
    final moodData = _moods.firstWhere((m) => m['label'] == _selectedMood);
    final moodColor = moodData['color'] as Color;
    final bgColor = moodData['bgColor'] as Color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Mood confirmation
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: moodColor.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Text(moodData['emoji'] as String,
                  style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You\'re feeling ${moodData['display']}',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: moodColor,
                      ),
                    ),
                    Text(
                      'Mood logged successfully ✓',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ).animate().scale(begin: const Offset(0.8, 0.8), duration: 500.ms, curve: Curves.elasticOut),

        const SizedBox(height: 20),

        // AI suggestion
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [moodColor.withOpacity(0.08), Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: moodColor.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: moodColor.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: moodColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(Icons.auto_awesome_rounded,
                        color: moodColor, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Your AI Support 💕',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                _aiSuggestion,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: 200.ms).slideY(begin: 0.1),

        const SizedBox(height: 16),

        // Quick actions
        Text(
          'Try These Now',
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textMain,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionButton(
                icon: Icons.air_rounded,
                label: 'Breathe',
                color: AppColors.secondary,
                onTap: () => _showBreathingModal(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.edit_note_rounded,
                label: 'Journal',
                color: AppColors.warning,
                onTap: () => _showJournalPrompt(context, moodData),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionButton(
                icon: Icons.tips_and_updates_rounded,
                label: 'Tip',
                color: AppColors.success,
                onTap: () {},
              ),
            ),
          ],
        ).animate().fadeIn(delay: 300.ms),

        const SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: _reset,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.cardBorder, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Check In Again',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryCard(MoodEntry entry, int index) {
    final moodData = _moods.firstWhere(
      (m) => m['label'] == entry.mood,
      orElse: () => _moods[0],
    );
    final moodColor = moodData['color'] as Color;
    final now = DateTime.now();
    final diff = now.difference(entry.timestamp);
    String timeAgo;
    if (diff.inMinutes < 60) {
      timeAgo = '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      timeAgo = '${diff.inHours}h ago';
    } else {
      timeAgo = '${diff.inDays}d ago';
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: moodColor.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: moodColor.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: (moodData['bgColor'] as Color),
                shape: BoxShape.circle,
                border: Border.all(color: moodColor.withOpacity(0.3), width: 1.5),
              ),
              child: Center(
                child: Text(moodData['emoji'] as String,
                    style: const TextStyle(fontSize: 28)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        moodData['display'] as String,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: moodColor,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        timeAgo,
                        style: GoogleFonts.poppins(
                            fontSize: 11, color: AppColors.textLight),
                      ),
                    ],
                  ),
                  if (entry.note.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      entry.note,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms, delay: (index * 60).ms),
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Text('🌟', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            'Start your mood journey!',
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain),
          ),
          const SizedBox(height: 6),
          Text(
            'Log your first mood above to see your emotional patterns over time.',
            style: GoogleFonts.poppins(
                fontSize: 13, color: AppColors.textLight, height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  void _showBreathingModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _BreathingModal(),
    );
  }

  void _showJournalPrompt(BuildContext context, Map<String, dynamic> moodData) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text('📓', style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            Text('Journal Prompt',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Since you\'re feeling ${(moodData['display'] as String).toLowerCase()}, try writing about:\n\n"What is one thing that can help me feel even better today? How can I show kindness to myself right now?"',
          style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it! 💕',
                style: GoogleFonts.poppins(
                    color: AppColors.primary, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Action Button ──────────────────────────────────────────────────────
class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color)),
          ],
        ),
      ),
    );
  }
}

// ─── Breathing Modal ──────────────────────────────────────────────────────────
class _BreathingModal extends StatefulWidget {
  const _BreathingModal();

  @override
  State<_BreathingModal> createState() => _BreathingModalState();
}

class _BreathingModalState extends State<_BreathingModal>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  int _phase = 0;
  final List<String> _phases = ['Inhale...', 'Hold...', 'Exhale...'];
  final List<Color> _colors = [AppColors.secondary, AppColors.accent, AppColors.primary];
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _start() async {
    setState(() => _running = true);
    while (_running && mounted) {
      for (int i = 0; i < 3; i++) {
        if (!_running || !mounted) break;
        setState(() => _phase = i);
        if (i == 0) {
          _ctrl.forward(from: 0);
        } else if (i == 2) {
          _ctrl.reverse(from: 1);
        }
        await Future.delayed(const Duration(seconds: 4));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colors[_phase];
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.cardBorder,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 24),
          Text('Box Breathing 🌬️',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
          const SizedBox(height: 6),
          Text('Reduces anxiety in just 4 cycles',
              style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight)),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: !_running ? _start : null,
            child: AnimatedBuilder(
              animation: _scale,
              builder: (_, __) => Transform.scale(
                scale: _running ? _scale.value : 0.8,
                child: Container(
                  width: 150, height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [color.withOpacity(0.3), color.withOpacity(0.08)],
                    ),
                    border: Border.all(color: color, width: 3),
                    boxShadow: [
                      BoxShadow(color: color.withOpacity(0.3), blurRadius: 30, spreadRadius: 5),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _running ? _phases[_phase] : 'Tap\nto Start',
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.bold, color: color),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (_running)
            TextButton(
              onPressed: () {
                setState(() => _running = false);
                _ctrl.stop();
              },
              child: Text('Stop',
                  style: GoogleFonts.poppins(color: AppColors.textSecondary)),
            ),
        ],
      ),
    );
  }
}
