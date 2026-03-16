import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../../core/constants/app_colors.dart';

// ─── Recommendation Model ─────────────────────────────────────────────────────
class Recommendation {
  final String text;
  final String emoji;
  final String actionLabel;
  final Color color;
  final IconData icon;
  final String category;

  const Recommendation({
    required this.text,
    required this.emoji,
    required this.actionLabel,
    required this.color,
    required this.icon,
    required this.category,
  });
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final recommendationsProvider = FutureProvider<List<Recommendation>>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return _fallbackRecommendations;

  try {
    // Fetch mood logs
    final moodSnap = await FirebaseFirestore.instance
        .collection('mood_companion_logs')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get();

    // Fetch challenge progress
    final challengeSnap = await FirebaseFirestore.instance
        .collection('wellness_challenges')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(10)
        .get();

    final moodLogs = moodSnap.docs.map((d) => d.data()).toList();
    final challengeLogs = challengeSnap.docs.map((d) => d.data()).toList();

    // Generate AI recommendations
    try {
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey != null && apiKey.isNotEmpty && apiKey != 'PASTE_YOUR_GEMINI_API_KEY_HERE') {
        final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
          systemInstruction: Content.system('''
You are a wellness coach for teenagers. Based on user data, generate exactly 5 personalized recommendations.
Each recommendation should be a short, encouraging sentence (max 15 words).
Format: Each recommendation on a new line, prefixed with a category tag:
[mood] recommendation about emotional wellness
[habit] recommendation about daily habits
[exercise] recommendation about physical activity
[nutrition] recommendation about eating/hydration
[mindfulness] recommendation about mental wellness
'''),
        );

        final moodSummary = moodLogs.isNotEmpty
            ? 'Recent moods: ${moodLogs.map((m) => m['mood']).join(', ')}'
            : 'No mood data yet';
        final challengeSummary = challengeLogs.isNotEmpty
            ? 'Completed challenges: ${challengeLogs.where((c) => c['completed'] == true).length}'
            : 'No challenges completed yet';

        final response = await model.generateContent([
          Content.text('$moodSummary. $challengeSummary. Generate personalized wellness recommendations.'),
        ]);

        final text = response.text ?? '';
        final lines = text.split('\n').where((l) => l.trim().isNotEmpty).toList();

        if (lines.isNotEmpty) {
          return lines.take(5).map((line) {
            final cleanLine = line.replaceAll(RegExp(r'\[.*?\]'), '').trim();
            if (line.contains('[mood]')) {
              return Recommendation(
                text: cleanLine,
                emoji: '💭',
                actionLabel: 'Log Mood',
                color: AppColors.primary,
                icon: Icons.favorite_rounded,
                category: 'Mood',
              );
            } else if (line.contains('[habit]')) {
              return Recommendation(
                text: cleanLine,
                emoji: '✅',
                actionLabel: 'Start Habit',
                color: AppColors.success,
                icon: Icons.check_circle_rounded,
                category: 'Habits',
              );
            } else if (line.contains('[exercise]')) {
              return Recommendation(
                text: cleanLine,
                emoji: '🏃‍♀️',
                actionLabel: 'Get Moving',
                color: const Color(0xFFFF9800),
                icon: Icons.fitness_center_rounded,
                category: 'Exercise',
              );
            } else if (line.contains('[nutrition]')) {
              return Recommendation(
                text: cleanLine,
                emoji: '🥗',
                actionLabel: 'Eat Well',
                color: const Color(0xFF43C6AC),
                icon: Icons.restaurant_rounded,
                category: 'Nutrition',
              );
            } else {
              return Recommendation(
                text: cleanLine,
                emoji: '🧘‍♀️',
                actionLabel: 'Be Mindful',
                color: AppColors.secondary,
                icon: Icons.self_improvement_rounded,
                category: 'Mindfulness',
              );
            }
          }).toList();
        }
      }
    } catch (_) {
      // Fall back to rule-based recommendations
    }

    // Rule-based fallback
    return _generateRuleBasedRecommendations(moodLogs, challengeLogs);
  } catch (_) {
    return _fallbackRecommendations;
  }
});

List<Recommendation> _generateRuleBasedRecommendations(
    List<Map<String, dynamic>> moodLogs,
    List<Map<String, dynamic>> challengeLogs) {
  final recommendations = <Recommendation>[];

  // Analyze mood patterns
  if (moodLogs.isNotEmpty) {
    final stressCount = moodLogs.where((m) =>
        m['mood'] == 'anxious' || m['mood'] == 'sad').length;
    final happyCount = moodLogs.where((m) =>
        m['mood'] == 'happy' || m['mood'] == 'excited').length;

    if (stressCount > 3) {
      recommendations.add(const Recommendation(
        text: 'You\'ve been feeling stressed lately. Try a 5-minute breathing session to relax.',
        emoji: '🌬️',
        actionLabel: 'Try Breathing',
        color: Color(0xFF7C7CF8),
        icon: Icons.air_rounded,
        category: 'Stress Relief',
      ));
    }

    if (happyCount > 3) {
      recommendations.add(const Recommendation(
        text: 'You\'re on a positive streak! Keep journaling to maintain this great energy.',
        emoji: '✨',
        actionLabel: 'Keep Going',
        color: Color(0xFFFF6B9A),
        icon: Icons.star_rounded,
        category: 'Positivity',
      ));
    }
  }

  // Add general recommendations to fill to 5
  final generalRecs = [
    const Recommendation(
      text: 'Drinking water boosts your focus by 30%. Have you had 8 glasses today?',
      emoji: '💧',
      actionLabel: 'Track Water',
      color: Color(0xFF2196F3),
      icon: Icons.water_drop_rounded,
      category: 'Hydration',
    ),
    const Recommendation(
      text: 'A 10-minute walk can boost your mood instantly. Try it between study sessions!',
      emoji: '🚶‍♀️',
      actionLabel: 'Get Moving',
      color: Color(0xFF4CAF50),
      icon: Icons.directions_walk_rounded,
      category: 'Exercise',
    ),
    const Recommendation(
      text: 'Write down 3 things you\'re grateful for. Gratitude improves sleep quality!',
      emoji: '📝',
      actionLabel: 'Write Now',
      color: Color(0xFFFF9800),
      icon: Icons.edit_note_rounded,
      category: 'Gratitude',
    ),
    const Recommendation(
      text: 'Screens before bed affect sleep quality. Try reading a book instead tonight.',
      emoji: '📚',
      actionLabel: 'Learn More',
      color: Color(0xFF9C27B0),
      icon: Icons.menu_book_rounded,
      category: 'Sleep',
    ),
    const Recommendation(
      text: 'Practice the 4-7-8 breathing technique to fall asleep faster tonight.',
      emoji: '😴',
      actionLabel: 'Try Now',
      color: Color(0xFF43C6AC),
      icon: Icons.bedtime_rounded,
      category: 'Relaxation',
    ),
  ];

  while (recommendations.length < 5) {
    final idx = recommendations.length;
    if (idx < generalRecs.length) {
      recommendations.add(generalRecs[idx]);
    } else {
      break;
    }
  }

  return recommendations;
}

const List<Recommendation> _fallbackRecommendations = [
  Recommendation(
    text: 'Start your day with a glass of water. Your body will thank you!',
    emoji: '💧',
    actionLabel: 'Track Water',
    color: Color(0xFF2196F3),
    icon: Icons.water_drop_rounded,
    category: 'Hydration',
  ),
  Recommendation(
    text: 'Take 3 deep breaths right now. You deserve a moment of calm.',
    emoji: '🌬️',
    actionLabel: 'Breathe',
    color: Color(0xFF7C7CF8),
    icon: Icons.air_rounded,
    category: 'Mindfulness',
  ),
  Recommendation(
    text: 'A quick 5-minute stretch can boost your energy and reduce pain.',
    emoji: '🧘‍♀️',
    actionLabel: 'Stretch Now',
    color: Color(0xFF4CAF50),
    icon: Icons.self_improvement_rounded,
    category: 'Exercise',
  ),
  Recommendation(
    text: 'Log your mood to understand your emotional patterns better!',
    emoji: '💭',
    actionLabel: 'Log Mood',
    color: Color(0xFFFF6B9A),
    icon: Icons.favorite_rounded,
    category: 'Mood',
  ),
  Recommendation(
    text: 'Try a new healthy recipe today. Cooking is a great mindful activity!',
    emoji: '🥗',
    actionLabel: 'Explore',
    color: Color(0xFFFF9800),
    icon: Icons.restaurant_rounded,
    category: 'Nutrition',
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────
class AiRecommendationsScreen extends ConsumerWidget {
  const AiRecommendationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recommendationsAsync = ref.watch(recommendationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF9C27B0),
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0), Color(0xFFCE93D8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -30, right: -30,
                      child: Container(
                        width: 180, height: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20, left: -20,
                      child: Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.04),
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
                                  child: const Icon(Icons.auto_awesome_rounded,
                                      color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('AI Recommendations ✨',
                                        style: GoogleFonts.poppins(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    Text('Personalized just for you',
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

          // ── Info Banner ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF9C27B0).withOpacity(0.1),
                    const Color(0xFF7C7CF8).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF9C27B0).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.psychology_rounded,
                        color: Color(0xFF9C27B0), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'These recommendations are based on your mood logs, challenges, and activity patterns.',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),

          // ── Horizontal Scroll Recommendations ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                'For You Today',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ).animate().fadeIn(),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: recommendationsAsync.when(
                data: (recommendations) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                  itemCount: recommendations.length,
                  itemBuilder: (context, index) {
                    return _RecommendationCard(
                      recommendation: recommendations[index],
                      delay: (index * 100).ms,
                    );
                  },
                ),
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF9C27B0)),
                ),
                error: (_, __) => Center(
                  child: Text('Could not load recommendations',
                      style: GoogleFonts.poppins(color: AppColors.textLight)),
                ),
              ),
            ),
          ),

          // ── Vertical List Section ────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'All Recommendations',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ).animate().fadeIn(delay: 200.ms),
            ),
          ),

          recommendationsAsync.when(
            data: (recommendations) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              sliver: SliverList.builder(
                itemCount: recommendations.length,
                itemBuilder: (context, index) {
                  final rec = recommendations[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: rec.color.withOpacity(0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: rec.color.withOpacity(0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(
                            color: rec.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(rec.emoji, style: const TextStyle(fontSize: 24)),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: rec.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  rec.category,
                                  style: GoogleFonts.poppins(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                    color: rec.color,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                rec.text,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: AppColors.textMain,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: rec.color,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            rec.actionLabel,
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate()
                      .fadeIn(duration: 350.ms, delay: (index * 80).ms)
                      .slideX(begin: 0.05);
                },
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Color(0xFF9C27B0))),
            ),
            error: (_, __) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: AppColors.textHint),
                    const SizedBox(height: 12),
                    Text('Something went wrong',
                        style: GoogleFonts.poppins(color: AppColors.textLight)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recommendation Card ──────────────────────────────────────────────────────
class _RecommendationCard extends StatefulWidget {
  final Recommendation recommendation;
  final Duration delay;

  const _RecommendationCard({required this.recommendation, required this.delay});

  @override
  State<_RecommendationCard> createState() => _RecommendationCardState();
}

class _RecommendationCardState extends State<_RecommendationCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: 260,
          margin: const EdgeInsets.only(right: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.recommendation.color.withOpacity(0.12),
                widget.recommendation.color.withOpacity(0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.recommendation.color.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.recommendation.color.withOpacity(0.15),
                blurRadius: 16,
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
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: widget.recommendation.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(widget.recommendation.icon,
                        color: widget.recommendation.color, size: 22),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: widget.recommendation.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      widget.recommendation.category,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: widget.recommendation.color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Expanded(
                child: Text(
                  widget.recommendation.text,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textMain,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: widget.recommendation.color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.recommendation.actionLabel,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ).animate()
            .fadeIn(duration: 400.ms, delay: widget.delay)
            .slideX(begin: 0.15),
      ),
    );
  }
}
