import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';

// ─── Challenge Model ──────────────────────────────────────────────────────────
class WellnessChallenge {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final Color color;
  final IconData icon;
  final int points;
  bool completed;

  WellnessChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    required this.color,
    required this.icon,
    required this.points,
    this.completed = false,
  });
}

// ─── Daily Challenges Data ────────────────────────────────────────────────────
List<WellnessChallenge> _getDailyChallenges() {
  final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
  final allChallenges = [
    WellnessChallenge(
      id: 'water_8',
      title: 'Drink 8 Glasses of Water',
      description: 'Stay hydrated throughout the day for better energy and focus.',
      emoji: '💧',
      color: const Color(0xFF2196F3),
      icon: Icons.water_drop_rounded,
      points: 10,
    ),
    WellnessChallenge(
      id: 'breathing_2min',
      title: 'Practice Breathing for 2 Min',
      description: 'Try the 4-7-8 breathing technique to calm your mind.',
      emoji: '🌬️',
      color: const Color(0xFF7C7CF8),
      icon: Icons.air_rounded,
      points: 15,
    ),
    WellnessChallenge(
      id: 'positive_thought',
      title: 'Write One Positive Thought',
      description: 'Write down something positive about yourself or your day.',
      emoji: '✨',
      color: const Color(0xFFFF6B9A),
      icon: Icons.edit_note_rounded,
      points: 10,
    ),
    WellnessChallenge(
      id: 'walk_10min',
      title: 'Walk for 10 Minutes',
      description: 'A short walk boosts mood and improves cardiovascular health.',
      emoji: '🚶‍♀️',
      color: const Color(0xFF4CAF50),
      icon: Icons.directions_walk_rounded,
      points: 15,
    ),
    WellnessChallenge(
      id: 'log_mood',
      title: 'Log Your Mood Today',
      description: 'Check in with yourself and track how you\'re feeling.',
      emoji: '💭',
      color: const Color(0xFFE91E63),
      icon: Icons.favorite_rounded,
      points: 10,
    ),
    WellnessChallenge(
      id: 'stretch_5min',
      title: 'Do 5 Minutes of Stretching',
      description: 'Gentle stretches to release tension and improve flexibility.',
      emoji: '🧘‍♀️',
      color: const Color(0xFF43C6AC),
      icon: Icons.self_improvement_rounded,
      points: 15,
    ),
    WellnessChallenge(
      id: 'healthy_snack',
      title: 'Eat a Healthy Snack',
      description: 'Choose a fruit or veggie instead of junk food today.',
      emoji: '🍎',
      color: const Color(0xFFFF9800),
      icon: Icons.apple_rounded,
      points: 10,
    ),
    WellnessChallenge(
      id: 'gratitude_3',
      title: 'Write 3 Gratitude Items',
      description: 'List 3 things you\'re grateful for to boost positivity.',
      emoji: '📝',
      color: const Color(0xFF9C27B0),
      icon: Icons.note_alt_rounded,
      points: 15,
    ),
    WellnessChallenge(
      id: 'screen_break',
      title: 'Take a 15-Min Screen Break',
      description: 'Step away from screens to rest your eyes and mind.',
      emoji: '📵',
      color: const Color(0xFF607D8B),
      icon: Icons.visibility_off_rounded,
      points: 10,
    ),
    WellnessChallenge(
      id: 'learn_something',
      title: 'Learn Something New',
      description: 'Read an article or watch an educational video today.',
      emoji: '📚',
      color: const Color(0xFF3F51B5),
      icon: Icons.school_rounded,
      points: 15,
    ),
  ];

  // Select 5 challenges based on day of year for variety
  final selectedIndices = <int>[];
  for (int i = 0; i < 5; i++) {
    selectedIndices.add((dayOfYear + i * 2) % allChallenges.length);
  }

  return selectedIndices.map((i) => allChallenges[i]).toList();
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final dailyChallengesProvider =
    NotifierProvider<DailyChallengesNotifier, AsyncValue<List<WellnessChallenge>>>(
        DailyChallengesNotifier.new);

class DailyChallengesNotifier extends Notifier<AsyncValue<List<WellnessChallenge>>> {
  @override
  AsyncValue<List<WellnessChallenge>> build() {
    _loadChallenges();
    return const AsyncValue.loading();
  }

  Future<void> _loadChallenges() async {
    try {
      final challenges = _getDailyChallenges();
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final today = DateTime.now();
        final startOfDay = DateTime(today.year, today.month, today.day);
        final snap = await FirebaseFirestore.instance
            .collection('wellness_challenges')
            .where('userId', isEqualTo: uid)
            .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
            .get();

        final completedIds = snap.docs.map((d) => d['challengeId'] as String).toSet();
        for (final challenge in challenges) {
          if (completedIds.contains(challenge.id)) {
            challenge.completed = true;
          }
        }
      }
      state = AsyncValue.data(challenges);
    } catch (e) {
      state = AsyncValue.data(_getDailyChallenges());
    }
  }

  Future<void> completeChallenge(String challengeId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance.collection('wellness_challenges').add({
        'userId': uid,
        'challengeId': challengeId,
        'completed': true,
        'timestamp': FieldValue.serverTimestamp(),
      });

      state.whenData((challenges) {
        final updated = challenges.map((c) {
          if (c.id == challengeId) c.completed = true;
          return c;
        }).toList();
        state = AsyncValue.data(updated);
      });
    } catch (_) {}
  }
}

// ─── Stats Provider ───────────────────────────────────────────────────────────
final challengeStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return {'total': 0, 'points': 0, 'streak': 0};

  try {
    final snap = await FirebaseFirestore.instance
        .collection('wellness_challenges')
        .where('userId', isEqualTo: uid)
        .where('completed', isEqualTo: true)
        .get();

    final total = snap.docs.length;
    final points = total * 12; // Average points

    // Calculate streak (simplified)
    int streak = 0;
    final today = DateTime.now();
    for (int i = 0; i < 30; i++) {
      final day = today.subtract(Duration(days: i));
      final dayStart = DateTime(day.year, day.month, day.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      final dayLogs = snap.docs.where((d) {
        final ts = (d['timestamp'] as Timestamp?)?.toDate();
        return ts != null && ts.isAfter(dayStart) && ts.isBefore(dayEnd);
      }).toList();
      if (dayLogs.isNotEmpty) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }

    return {'total': total, 'points': points, 'streak': streak};
  } catch (_) {
    return {'total': 0, 'points': 0, 'streak': 0};
  }
});

// ─── Screen ───────────────────────────────────────────────────────────────────
class DailyChallengesScreen extends ConsumerWidget {
  const DailyChallengesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challengesAsync = ref.watch(dailyChallengesProvider);
    final statsAsync = ref.watch(challengeStatsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFFFF9800),
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFEF6C00), Color(0xFFFF9800), Color(0xFFFFB74D)],
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
                                  child: const Icon(Icons.emoji_events_rounded,
                                      color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Daily Challenges 🏆',
                                        style: GoogleFonts.poppins(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    Text('Complete tasks to earn points & badges',
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

          // ── Stats Row ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: statsAsync.when(
                data: (stats) => Row(
                  children: [
                    _StatBadge(
                      label: 'Total',
                      value: '${stats['total']}',
                      emoji: '✅',
                      color: AppColors.success,
                      delay: 0.ms,
                    ),
                    const SizedBox(width: 10),
                    _StatBadge(
                      label: 'Points',
                      value: '${stats['points']}',
                      emoji: '⭐',
                      color: const Color(0xFFFF9800),
                      delay: 100.ms,
                    ),
                    const SizedBox(width: 10),
                    _StatBadge(
                      label: 'Streak',
                      value: '${stats['streak']}🔥',
                      emoji: '📅',
                      color: AppColors.primary,
                      delay: 200.ms,
                    ),
                  ],
                ),
                loading: () => const SizedBox(height: 80),
                error: (_, __) => const SizedBox(height: 80),
              ),
            ),
          ),

          // ── Progress Overview ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: challengesAsync.when(
              data: (challenges) {
                final completed = challenges.where((c) => c.completed).length;
                final total = challenges.length;
                final progress = total > 0 ? completed / total : 0.0;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF9800).withOpacity(0.12),
                          const Color(0xFFFF6B9A).withOpacity(0.06),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Today\'s Progress',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                              ),
                            ),
                            Text(
                              '$completed/$total',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFFFF9800),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: const Color(0xFFFF9800).withOpacity(0.15),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
                          ),
                        ),
                        if (completed == total && total > 0) ...[
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '🎉 All challenges completed! Amazing job!',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          // ── Section Title ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                'Today\'s Challenges',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain,
                ),
              ).animate().fadeIn(delay: 200.ms),
            ),
          ),

          // ── Challenge List ────────────────────────────────────────────
          challengesAsync.when(
            data: (challenges) => SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              sliver: SliverList.builder(
                itemCount: challenges.length,
                itemBuilder: (context, index) {
                  return _ChallengeCard(
                    challenge: challenges[index],
                    onComplete: () {
                      ref.read(dailyChallengesProvider.notifier)
                          .completeChallenge(challenges[index].id);
                      ref.invalidate(challengeStatsProvider);
                    },
                    delay: (index * 80).ms,
                  );
                },
              ),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: Color(0xFFFF9800))),
            ),
            error: (_, __) => SliverFillRemaining(
              child: Center(
                child: Text('Could not load challenges',
                    style: GoogleFonts.poppins(color: AppColors.textLight)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Badge ───────────────────────────────────────────────────────────────
class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color color;
  final Duration delay;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.emoji,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 10,
                color: AppColors.textLight,
              ),
            ),
          ],
        ),
      ).animate().fadeIn(duration: 350.ms, delay: delay).slideY(begin: 0.15),
    );
  }
}

// ─── Challenge Card ───────────────────────────────────────────────────────────
class _ChallengeCard extends StatefulWidget {
  final WellnessChallenge challenge;
  final VoidCallback onComplete;
  final Duration delay;

  const _ChallengeCard({
    required this.challenge,
    required this.onComplete,
    required this.delay,
  });

  @override
  State<_ChallengeCard> createState() => _ChallengeCardState();
}

class _ChallengeCardState extends State<_ChallengeCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isCompleted = widget.challenge.completed;
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: AnimatedOpacity(
          opacity: isCompleted ? 0.7 : 1.0,
          duration: const Duration(milliseconds: 300),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCompleted
                  ? widget.challenge.color.withOpacity(0.06)
                  : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isCompleted
                    ? AppColors.success.withOpacity(0.3)
                    : widget.challenge.color.withOpacity(0.15),
                width: isCompleted ? 2 : 1.5,
              ),
              boxShadow: [
                if (!isCompleted)
                  BoxShadow(
                    color: widget.challenge.color.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppColors.success.withOpacity(0.12)
                        : widget.challenge.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 28)
                        : Text(widget.challenge.emoji,
                            style: const TextStyle(fontSize: 28)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.challenge.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isCompleted
                              ? AppColors.textLight
                              : AppColors.textMain,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.challenge.description,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: widget.challenge.color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '+${widget.challenge.points} pts',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: widget.challenge.color,
                              ),
                            ),
                          ),
                          if (isCompleted) ...[
                            const SizedBox(width: 8),
                            Text(
                              '✅ Completed',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (!isCompleted)
                  GestureDetector(
                    onTap: () {
                      widget.onComplete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '🎉 +${widget.challenge.points} points! Challenge completed!',
                            style: GoogleFonts.poppins(color: Colors.white),
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: widget.challenge.color,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: widget.challenge.color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Text(
                        'Done ✓',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 350.ms, delay: widget.delay).slideX(begin: 0.1),
      ),
    );
  }
}
