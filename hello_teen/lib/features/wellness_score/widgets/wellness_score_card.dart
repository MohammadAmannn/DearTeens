import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';

// ─── Provider ─────────────────────────────────────────────────────────────────
final wellnessScoreProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return _defaultScore();

  try {
    final today = DateTime.now();
    final weekAgo = today.subtract(const Duration(days: 7));
    final startOfDay = DateTime(today.year, today.month, today.day);

    // Fetch mood logs (last 7 days)
    final moodSnap = await FirebaseFirestore.instance
        .collection('mood_companion_logs')
        .where('userId', isEqualTo: uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
        .get();

    // Fetch today's challenges
    final challengeSnap = await FirebaseFirestore.instance
        .collection('wellness_challenges')
        .where('userId', isEqualTo: uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    // Calculate sub-scores
    final moodScore = _calcMoodScore(moodSnap.docs);
    final activityScore = math.min(100, challengeSnap.docs.length * 20);
    final consistencyScore = _calcConsistencyScore(moodSnap.docs);

    final overall =
        ((moodScore * 0.4) + (activityScore * 0.35) + (consistencyScore * 0.25))
            .round();

    return {
      'overall': overall.clamp(0, 100),
      'mood': moodScore.clamp(0, 100),
      'activity': activityScore.clamp(0, 100),
      'consistency': consistencyScore.clamp(0, 100),
      'moodLogs': moodSnap.docs.length,
      'challengesDone': challengeSnap.docs.length,
    };
  } catch (_) {
    return _defaultScore();
  }
});

Map<String, dynamic> _defaultScore() => {
      'overall': 72,
      'mood': 65,
      'activity': 80,
      'consistency': 70,
      'moodLogs': 0,
      'challengesDone': 0,
    };

int _calcMoodScore(List<QueryDocumentSnapshot> docs) {
  if (docs.isEmpty) return 50;
  // mood stored as int 1-5; map to 0-100
  final scores = docs.map((d) {
    final m = d.data() as Map<String, dynamic>;
    final v = (m['mood'] as num?)?.toInt() ?? 3;
    return (v - 1) * 25; // 0,25,50,75,100
  }).toList();
  return (scores.reduce((a, b) => a + b) / scores.length).round();
}

int _calcConsistencyScore(List<QueryDocumentSnapshot> docs) {
  if (docs.isEmpty) return 40;
  // How many distinct days in the week had a log
  final days = docs.map((d) {
    final ts = ((d.data() as Map<String, dynamic>)['timestamp'] as Timestamp?)
        ?.toDate();
    return ts != null ? '${ts.year}-${ts.month}-${ts.day}' : '';
  }).toSet();
  return math.min(100, (days.length / 7 * 100).round());
}

// ─── Widget ──────────────────────────────────────────────────────────────────
class WellnessScoreCard extends ConsumerWidget {
  const WellnessScoreCard({super.key});

  String _label(int score) {
    if (score >= 85) return 'Thriving 🌟';
    if (score >= 70) return 'Doing Well 💚';
    if (score >= 55) return 'Getting There 🌱';
    if (score >= 40) return 'Needs Care 💛';
    return 'Reach Out 💙';
  }

  Color _scoreColor(int score) {
    if (score >= 85) return const Color(0xFF00C853);
    if (score >= 70) return const Color(0xFF4CAF50);
    if (score >= 55) return const Color(0xFFFF9800);
    if (score >= 40) return const Color(0xFFFF6B9A);
    return const Color(0xFF7C7CF8);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(wellnessScoreProvider);

    return async.when(
      loading: () => _buildSkeleton(),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        final score = (data['overall'] as int).clamp(0, 100);
        final mood = (data['mood'] as int).clamp(0, 100);
        final activity = (data['activity'] as int).clamp(0, 100);
        final consistency = (data['consistency'] as int).clamp(0, 100);
        final color = _scoreColor(score);

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Circular arc score
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CustomPaint(
                      painter: _ArcPainter(score: score, color: color),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$score',
                              style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: color,
                              ),
                            ),
                            Text(
                              '/100',
                              style: GoogleFonts.poppins(
                                  fontSize: 9, color: AppColors.textHint),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Wellness Score',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textLight,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _label(score),
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _MiniBar(label: 'Mood', value: mood / 100, color: AppColors.primary),
                        const SizedBox(height: 5),
                        _MiniBar(label: 'Activity', value: activity / 100, color: const Color(0xFF7C7CF8)),
                        const SizedBox(height: 5),
                        _MiniBar(label: 'Streak', value: consistency / 100, color: AppColors.success),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        )
            .animate()
            .fadeIn(duration: 500.ms, delay: 300.ms)
            .slideY(begin: 0.15);
      },
    );
  }

  Widget _buildSkeleton() => Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      );
}

// ─── Mini progress bar row ────────────────────────────────────────────────────
class _MiniBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _MiniBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 56,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: AppColors.textLight,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 6,
              backgroundColor: color.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${(value * 100).round()}%',
          style: GoogleFonts.poppins(
            fontSize: 9,
            color: AppColors.textHint,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Arc painter ──────────────────────────────────────────────────────────────
class _ArcPainter extends CustomPainter {
  final int score;
  final Color color;

  const _ArcPainter({required this.score, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = math.min(cx, cy) - 8;
    const startAngle = math.pi * 0.75;
    const sweepFull = math.pi * 1.5;
    final sweepScore = sweepFull * (score / 100);

    // Track
    final trackPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      sweepFull,
      false,
      trackPaint,
    );

    // Progress
    final progressPaint = Paint()
      ..shader = SweepGradient(
        colors: [color.withOpacity(0.5), color],
        startAngle: startAngle,
        endAngle: startAngle + sweepScore,
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: radius),
      startAngle,
      sweepScore,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.score != score;
}
