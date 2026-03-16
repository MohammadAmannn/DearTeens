import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';

// ─── Timeline Event Model ─────────────────────────────────────────────────────
class TimelineEvent {
  final String id;
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final IconData icon;
  final DateTime timestamp;
  final String type;

  const TimelineEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.icon,
    required this.timestamp,
    required this.type,
  });
}

// ─── Provider ─────────────────────────────────────────────────────────────────
final healthTimelineProvider = FutureProvider<List<TimelineEvent>>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return [];

  final events = <TimelineEvent>[];

  try {
    // Fetch mood logs
    final moodSnap = await FirebaseFirestore.instance
        .collection('mood_companion_logs')
        .where('userId', isEqualTo: uid)
        .orderBy('timestamp', descending: true)
        .limit(15)
        .get();

    for (final doc in moodSnap.docs) {
      final data = doc.data();
      final mood = data['mood'] ?? '';
      final ts = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
      final moodEmojis = {
        'happy': '😊', 'calm': '😌', 'sad': '😢',
        'anxious': '😰', 'excited': '🤩',
      };
      events.add(TimelineEvent(
        id: doc.id,
        title: 'Mood Logged',
        subtitle: 'Feeling ${mood.toString().isNotEmpty ? mood : 'unspecified'}',
        emoji: moodEmojis[mood] ?? '💭',
        color: const Color(0xFFFF6B9A),
        icon: Icons.favorite_rounded,
        timestamp: ts,
        type: 'mood',
      ));
    }

    // Fetch challenge completions
    final challengeSnap = await FirebaseFirestore.instance
        .collection('wellness_challenges')
        .where('userId', isEqualTo: uid)
        .where('completed', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .limit(15)
        .get();

    for (final doc in challengeSnap.docs) {
      final data = doc.data();
      final challengeId = data['challengeId'] ?? '';
      final ts = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
      events.add(TimelineEvent(
        id: doc.id,
        title: 'Challenge Completed',
        subtitle: _challengeLabel(challengeId),
        emoji: '🏆',
        color: const Color(0xFFFF9800),
        icon: Icons.emoji_events_rounded,
        timestamp: ts,
        type: 'challenge',
      ));
    }

    // Fetch period logs if available
    try {
      final periodSnap = await FirebaseFirestore.instance
          .collection('period_logs')
          .where('userId', isEqualTo: uid)
          .orderBy('date', descending: true)
          .limit(10)
          .get();

      for (final doc in periodSnap.docs) {
        final data = doc.data();
        final ts = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();
        events.add(TimelineEvent(
          id: doc.id,
          title: 'Period Logged',
          subtitle: 'Cycle day recorded',
          emoji: '🌸',
          color: const Color(0xFFE91E63),
          icon: Icons.water_drop_rounded,
          timestamp: ts,
          type: 'period',
        ));
      }
    } catch (_) {}

    // Fetch mood tracker (old mental health logs)
    try {
      final mentalSnap = await FirebaseFirestore.instance
          .collection('mood_logs')
          .where('userId', isEqualTo: uid)
          .orderBy('timestamp', descending: true)
          .limit(10)
          .get();

      for (final doc in mentalSnap.docs) {
        final data = doc.data();
        final mood = data['mood'] ?? '';
        final ts = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
        events.add(TimelineEvent(
          id: doc.id,
          title: 'Health Check-in',
          subtitle: 'Mood: $mood',
          emoji: '📊',
          color: const Color(0xFF7C7CF8),
          icon: Icons.insights_rounded,
          timestamp: ts,
          type: 'health',
        ));
      }
    } catch (_) {}

    // Sort all by timestamp descending
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events;
  } catch (_) {
    return events;
  }
});

String _challengeLabel(String challengeId) {
  final labels = {
    'water_8': 'Drink 8 Glasses of Water',
    'breathing_2min': 'Practice Breathing for 2 Min',
    'positive_thought': 'Write One Positive Thought',
    'walk_10min': 'Walk for 10 Minutes',
    'log_mood': 'Log Your Mood Today',
    'stretch_5min': 'Do 5 Minutes of Stretching',
    'healthy_snack': 'Eat a Healthy Snack',
    'gratitude_3': 'Write 3 Gratitude Items',
    'screen_break': 'Take a 15-Min Screen Break',
    'learn_something': 'Learn Something New',
  };
  return labels[challengeId] ?? 'Wellness Challenge';
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class HealthTimelineScreen extends ConsumerWidget {
  const HealthTimelineScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timelineAsync = ref.watch(healthTimelineProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFF00897B),
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00695C), Color(0xFF00897B), Color(0xFF4DB6AC)],
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
                                  child: const Icon(Icons.timeline_rounded,
                                      color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Health Timeline 📋',
                                        style: GoogleFonts.poppins(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    Text('Your personal wellness journey',
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

          // ── Timeline Content ────────────────────────────────────────────
          timelineAsync.when(
            data: (events) {
              if (events.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('📋', style: const TextStyle(fontSize: 56)),
                        const SizedBox(height: 16),
                        Text(
                          'Your Timeline is Empty',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Start logging moods, completing challenges,\nand tracking your health to see your journey!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Group events by date
              final groupedEvents = <String, List<TimelineEvent>>{};
              for (final event in events) {
                final dateKey = _formatDateKey(event.timestamp);
                groupedEvents.putIfAbsent(dateKey, () => []).add(event);
              }

              final dateKeys = groupedEvents.keys.toList();

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                sliver: SliverList.builder(
                  itemCount: dateKeys.length,
                  itemBuilder: (context, dateIndex) {
                    final dateKey = dateKeys[dateIndex];
                    final dayEvents = groupedEvents[dateKey]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date header
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, top: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00897B).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                      color: const Color(0xFF00897B).withOpacity(0.2)),
                                ),
                                child: Text(
                                  dateKey,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF00897B),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: AppColors.cardBorder,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${dayEvents.length} events',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: AppColors.textLight,
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 300.ms,
                            delay: (dateIndex * 100).ms),

                        // Timeline events for this date
                        ...dayEvents.asMap().entries.map((entry) {
                          final event = entry.value;
                          final isLast = entry.key == dayEvents.length - 1;
                          return _TimelineItem(
                            event: event,
                            isLast: isLast,
                            delay: (dateIndex * 100 + entry.key * 60).ms,
                          );
                        }),
                      ],
                    );
                  },
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: Color(0xFF00897B)),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 48, color: AppColors.textHint),
                    const SizedBox(height: 12),
                    Text('Could not load timeline',
                        style: GoogleFonts.poppins(color: AppColors.textLight)),
                    const SizedBox(height: 8),
                    Text(
                      e.toString(),
                      style: GoogleFonts.poppins(
                          fontSize: 11, color: AppColors.textHint),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(healthTimelineProvider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00897B),
                      ),
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

String _formatDateKey(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final eventDay = DateTime(date.year, date.month, date.day);
  final diff = today.difference(eventDay).inDays;

  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (diff < 7) return '$diff days ago';

  final months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}

String _formatTime(DateTime date) {
  final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
  final period = date.hour >= 12 ? 'PM' : 'AM';
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute $period';
}

// ─── Timeline Item ────────────────────────────────────────────────────────────
class _TimelineItem extends StatelessWidget {
  final TimelineEvent event;
  final bool isLast;
  final Duration delay;

  const _TimelineItem({
    required this.event,
    required this.isLast,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line + dot
          SizedBox(
            width: 40,
            child: Column(
              children: [
                Container(
                  width: 14, height: 14,
                  decoration: BoxDecoration(
                    color: event.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: event.color.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: event.color.withOpacity(0.2),
                    ),
                  ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: event.color.withOpacity(0.12)),
                boxShadow: [
                  BoxShadow(
                    color: event.color.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(
                      color: event.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(event.emoji, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.title,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          event.subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _formatTime(event.timestamp),
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms, delay: delay).slideX(begin: 0.1);
  }
}
