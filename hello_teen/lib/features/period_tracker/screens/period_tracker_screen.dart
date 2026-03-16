import 'dart:math' as dart_math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/period_provider.dart';
import 'add_log_screen.dart';

// ─── Phase Constants ──────────────────────────────────────────────────────────
const Color _phaseColorMenstrual = Color(0xFFE91E63);
const Color _phaseColorFollicular = Color(0xFF7C7CF8);
const Color _phaseColorOvulation = Color(0xFFFF9800);
const Color _phaseColorLuteal = Color(0xFF009688);

const List<Map<String, dynamic>> _phases = [
  {
    'name': 'Menstrual',
    'days': 'Days 1-5',
    'icon': Icons.water_drop_rounded,
    'color': _phaseColorMenstrual,
    'desc': 'Period occurs. Rest & self-care recommended.',
    'emoji': '🩸',
    'tip': 'Use a warm compress for cramp relief. Stay hydrated and rest when possible.',
  },
  {
    'name': 'Follicular',
    'days': 'Days 6-13',
    'icon': Icons.local_florist_rounded,
    'color': _phaseColorFollicular,
    'desc': 'Energy rises. Great for new starts!',
    'emoji': '🌸',
    'tip': 'Your energy is rising! Great time for exercise, socializing, and trying new things.',
  },
  {
    'name': 'Ovulation',
    'days': 'Day ~14',
    'icon': Icons.wb_sunny_rounded,
    'color': _phaseColorOvulation,
    'desc': 'Peak energy & confidence.',
    'emoji': '☀️',
    'tip': 'You may feel more confident and social. Skin may glow! Peak energy time.',
  },
  {
    'name': 'Luteal',
    'days': 'Days 15-28',
    'icon': Icons.nightlight_rounded,
    'color': _phaseColorLuteal,
    'desc': 'Energy dips. Be gentle with yourself.',
    'emoji': '🌙',
    'tip': 'PMS symptoms may appear. Reduce caffeine, prioritize sleep, and be kind to yourself.',
  },
];

// ─── Symptom Data ─────────────────────────────────────────────────────────────
const Map<String, String> _symptomEmojis = {
  'Cramps': '😣',
  'Headache': '🤕',
  'Bloating': '🫧',
  'Fatigue': '😴',
  'Acne': '😓',
  'Mood Swings': '🎭',
  'Backache': '🔙',
};

// ─── Screen ───────────────────────────────────────────────────────────────────
class PeriodTrackerScreen extends ConsumerWidget {
  const PeriodTrackerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycleLogsAsync = ref.watch(cycleLogsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AddLogScreen())),
        backgroundColor: _phaseColorMenstrual,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: Text('Log Period',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13)),
      ),
      body: cycleLogsAsync.when(
        data: (logs) {
          final nextPeriod =
              ref.read(periodProvider).predictNextPeriod(logs);
          final daysUntil =
              nextPeriod.difference(DateTime.now()).inDays;
          return _buildBody(context, logs, daysUntil, nextPeriod);
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: _phaseColorMenstrual)),
        error: (error, _) => Center(
            child: Text('Error: $error',
                style: GoogleFonts.poppins(color: AppColors.textMain))),
      ),
    );
  }

  // ─── Current Phase + Tips ──────────────────────────────────────────────────
  Map<String, dynamic> _getCurrentPhase(int daysUntil) {
    int day = 28 - daysUntil;
    if (day < 1) day = 1;
    if (day > 28) day = 28;
    if (day <= 5) return _phases[0];
    if (day <= 13) return _phases[1];
    if (day <= 14) return _phases[2];
    return _phases[3];
  }

  // ─── Main Body ─────────────────────────────────────────────────────────────
  Widget _buildBody(BuildContext context, List<dynamic> logs, int daysUntil,
      DateTime nextPeriod) {
    final currentPhase = _getCurrentPhase(daysUntil);
    final avgCycleLength = _calcAvgCycle(logs);
    final avgPeriodDuration = _calcAvgDuration(logs);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Gradient Header with Cycle Wheel ──────────────────────────
        SliverAppBar(
          expandedHeight: 340,
          pinned: true,
          backgroundColor: const Color(0xFFC2185B),
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFFC2185B),
                    Color(0xFFE91E8C),
                    Color(0xFFFF6B9A)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                      top: -50,
                      right: -50,
                      child: _circle(
                          220, Colors.white.withOpacity(0.05))),
                  Positioned(
                      bottom: -20,
                      left: -30,
                      child: _circle(
                          160, Colors.white.withOpacity(0.04))),
                  Positioned(
                      top: 80,
                      right: 50,
                      child: _circle(
                          60, Colors.white.withOpacity(0.03))),
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 8, 20, 0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title row
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Period Tracker',
                                        style:
                                            GoogleFonts.poppins(
                                                fontSize: 22,
                                                fontWeight:
                                                    FontWeight
                                                        .bold,
                                                color: Colors
                                                    .white)),
                                    Text(
                                        'Track & understand your cycle 🌸',
                                        style:
                                            GoogleFonts.poppins(
                                                fontSize: 12,
                                                color: Colors
                                                    .white70)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Cycle Wheel
                          _AnimatedCycleIndicator(
                              daysUntil: daysUntil,
                              nextPeriod: nextPeriod),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Current Phase Card ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: _CurrentPhaseCard(phase: currentPhase, daysUntil: daysUntil),
          ),
        ),

        // ── Cycle Stats Row ───────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Row(
              children: [
                _StatCard(
                  label: 'Avg Cycle',
                  value: avgCycleLength > 0
                      ? '${avgCycleLength}d'
                      : '--',
                  icon: Icons.loop_rounded,
                  color: _phaseColorFollicular,
                  delay: 0.ms,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Avg Period',
                  value: avgPeriodDuration > 0
                      ? '${avgPeriodDuration}d'
                      : '--',
                  icon: Icons.water_drop_rounded,
                  color: _phaseColorMenstrual,
                  delay: 100.ms,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: 'Logged',
                  value: '${logs.length}',
                  icon: Icons.calendar_month_rounded,
                  color: _phaseColorLuteal,
                  delay: 200.ms,
                ),
              ],
            ),
          ),
        ),

        // ── Cycle Phases Title ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Text('Cycle Phases',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain))
                .animate()
                .fadeIn(),
          ),
        ),

        // ── Phases Horizontal Scroll ──────────────────────────────────
        SliverToBoxAdapter(
          child: SizedBox(
            height: 145,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              itemCount: _phases.length,
              itemBuilder: (context, index) {
                return _PhaseChip(
                    phase: _phases[index],
                    delay: (index * 100).ms);
              },
            ),
          ),
        ),

        // ── Symptom Insights (if logs exist) ──────────────────────────
        if (logs.isNotEmpty)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _SymptomInsightsCard(logs: logs),
            ),
          ),

        // ── Self-Care Tips ────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: _SelfCareTipsCard(phase: currentPhase),
          ),
        ),

        // ── Logs Header ───────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.history_rounded,
                        color: _phaseColorMenstrual, size: 20),
                    const SizedBox(width: 8),
                    Text('Period History',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain)),
                  ],
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),
          ),
        ),

        // ── Logs List ─────────────────────────────────────────────────
        if (logs.isEmpty)
          SliverToBoxAdapter(
              child: _buildEmptyLogs()
                  .animate()
                  .fadeIn(duration: 400.ms))
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final log = logs[index];
                return _PeriodLogCard(log: log, index: index);
              },
              childCount: logs.length,
            ),
          ),

        // FAB clearance
        const SliverPadding(padding: EdgeInsets.only(bottom: 90)),
      ],
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────
  int _calcAvgCycle(List<dynamic> logs) {
    if (logs.length < 2) return 0;
    int totalDays = 0;
    int count = 0;
    for (int i = 0; i < logs.length - 1; i++) {
      final int diff =
          (logs[i].periodStart.difference(logs[i + 1].periodStart).inDays as int).abs();
      if (diff > 0 && diff < 60) {
        totalDays += diff;
        count++;
      }
    }
    return count > 0 ? (totalDays / count).round() : 28;
  }

  int _calcAvgDuration(List<dynamic> logs) {
    final logsWithEnd =
        logs.where((l) => l.periodEnd != null).toList();
    if (logsWithEnd.isEmpty) return 0;
    int total = 0;
    for (final l in logsWithEnd) {
      total += (l.periodEnd!.difference(l.periodStart).inDays as int) + 1;
    }
    return (total / logsWithEnd.length).round();
  }

  Widget _circle(double size, Color color) {
    return Container(
        width: size,
        height: size,
        decoration:
            BoxDecoration(shape: BoxShape.circle, color: color));
  }

  Widget _buildEmptyLogs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border:
            Border.all(color: Colors.pink.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
              color: Colors.pink.withOpacity(0.08),
              blurRadius: 16)
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xFFFFCDD2), Color(0xFFFFEBEE)]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.water_drop_outlined,
                size: 36, color: Color(0xFFE91E8C)),
          ),
          const SizedBox(height: 16),
          Text('No cycles logged yet',
              style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain)),
          const SizedBox(height: 8),
          Text(
              'Tap the "Log Period" button below to start tracking',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textLight),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ─── Current Phase Card ───────────────────────────────────────────────────────
class _CurrentPhaseCard extends StatelessWidget {
  final Map<String, dynamic> phase;
  final int daysUntil;

  const _CurrentPhaseCard({required this.phase, required this.daysUntil});

  @override
  Widget build(BuildContext context) {
    final color = phase['color'] as Color;
    int day = 28 - daysUntil;
    if (day < 1) day = 1;
    if (day > 28) day = 28;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.15), color.withOpacity(0.04)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(phase['emoji'] as String,
                  style: const TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'CURRENT PHASE • DAY $day',
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: color,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${phase['name']} Phase',
                  style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain),
                ),
                Text(
                  phase['desc'] as String,
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textLight),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Duration delay;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.18)),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain)),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 10, color: AppColors.textLight)),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms, delay: delay).slideY(begin: 0.15),
    );
  }
}

// ─── Symptom Insights Card ────────────────────────────────────────────────────
class _SymptomInsightsCard extends StatelessWidget {
  final List<dynamic> logs;

  const _SymptomInsightsCard({required this.logs});

  @override
  Widget build(BuildContext context) {
    // Aggregate symptom counts
    final symptomCounts = <String, int>{};
    for (final log in logs) {
      for (final s in log.symptoms) {
        symptomCounts[s] = (symptomCounts[s] ?? 0) + 1;
      }
    }
    if (symptomCounts.isEmpty) return const SizedBox.shrink();

    final sortedSymptoms = symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topSymptoms = sortedSymptoms.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
              color: _phaseColorMenstrual.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _phaseColorMenstrual.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.analytics_rounded,
                    color: _phaseColorMenstrual, size: 18),
              ),
              const SizedBox(width: 10),
              Text('Symptom Insights',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain)),
            ],
          ),
          const SizedBox(height: 14),
          ...topSymptoms.map((entry) {
            final emoji = _symptomEmojis[entry.key] ?? '•';
            final maxCount = topSymptoms.first.value;
            final ratio = entry.value / maxCount;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 10),
                  Text(entry.key,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMain)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: ratio.clamp(0.1, 1.0),
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                  colors: [
                                    _phaseColorMenstrual,
                                    Color(0xFFFF6B9A)
                                  ]),
                              borderRadius:
                                  BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${entry.value}x',
                      style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w700)),
                ],
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1);
  }
}

// ─── Self Care Tips Card ──────────────────────────────────────────────────────
class _SelfCareTipsCard extends StatelessWidget {
  final Map<String, dynamic> phase;

  const _SelfCareTipsCard({required this.phase});

  @override
  Widget build(BuildContext context) {
    final color = phase['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 14,
              offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.lightbulb_rounded,
                    color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Text('Phase Tip 💡',
                  style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withOpacity(0.15)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(phase['emoji'] as String,
                    style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    phase['tip'] as String,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.1);
  }
}

// ─── Period Log Card ──────────────────────────────────────────────────────────
class _PeriodLogCard extends StatelessWidget {
  final dynamic log;
  final int index;

  const _PeriodLogCard({required this.log, required this.index});

  @override
  Widget build(BuildContext context) {
    final startStr =
        '${log.periodStart.toLocal()}'.split(' ')[0];
    final endStr = log.periodEnd != null
        ? '${log.periodEnd!.toLocal()}'.split(' ')[0]
        : 'Ongoing';
    final duration = log.periodEnd != null
        ? '${log.periodEnd!.difference(log.periodStart).inDays + 1} days'
        : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border:
              Border.all(color: Colors.pink.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
                color: Colors.pink.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [
                          Color(0xFFE91E8C),
                          Color(0xFFFF6B9A)
                        ]),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                      Icons.water_drop_rounded,
                      color: Colors.white,
                      size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text('$startStr → $endStr',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppColors.textMain)),
                      if (duration != null)
                        Row(
                          children: [
                            Icon(Icons.timer_outlined,
                                size: 12,
                                color: AppColors.textLight),
                            const SizedBox(width: 4),
                            Text('Duration: $duration',
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color:
                                        AppColors.textLight)),
                          ],
                        ),
                    ],
                  ),
                ),
                if (log.periodEnd == null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _phaseColorMenstrual
                          .withOpacity(0.1),
                      borderRadius:
                          BorderRadius.circular(8),
                    ),
                    child: Text('Active',
                        style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: _phaseColorMenstrual,
                            fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
            if (log.symptoms.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (log.symptoms as List)
                    .map<Widget>((symptom) {
                  final emoji =
                      _symptomEmojis[symptom.toString()] ?? '•';
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:
                          Colors.pink.withOpacity(0.06),
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.pink
                              .withOpacity(0.2)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(emoji,
                            style: const TextStyle(
                                fontSize: 12)),
                        const SizedBox(width: 4),
                        Text(symptom.toString(),
                            style: GoogleFonts.poppins(
                                color: const Color(
                                    0xFFC2185B),
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.w600)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ).animate()
          .fadeIn(duration: 400.ms, delay: (index * 80).ms),
    );
  }
}

// ─── Animated Cycle Indicator ─────────────────────────────────────────────────
class _AnimatedCycleIndicator extends StatefulWidget {
  final int daysUntil;
  final DateTime nextPeriod;

  const _AnimatedCycleIndicator(
      {required this.daysUntil, required this.nextPeriod});

  @override
  State<_AnimatedCycleIndicator> createState() =>
      _AnimatedCycleIndicatorState();
}

class _AnimatedCycleIndicatorState
    extends State<_AnimatedCycleIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500))
      ..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String daysText;
    String subText;
    if (widget.daysUntil > 0) {
      daysText = '${widget.daysUntil}';
      subText = 'days until\nnext period';
    } else if (widget.daysUntil == 0) {
      daysText = 'Today';
      subText = 'Period\nexpected';
    } else {
      daysText = '${-widget.daysUntil}';
      subText = 'days\nlate';
    }

    int currentDayOfCycle = 28 - widget.daysUntil;
    if (currentDayOfCycle < 1) currentDayOfCycle = 1;
    if (currentDayOfCycle > 28) currentDayOfCycle = 28;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 190,
          height: 190,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(190, 190),
                painter: _CycleWheelPainter(
                  currentDay: currentDayOfCycle,
                  progress: Curves.easeInOutCubic
                      .transform(_controller.value),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('Day $currentDayOfCycle',
                        style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color:
                                Colors.white.withOpacity(0.9))),
                  ),
                  const SizedBox(height: 4),
                  Text(daysText,
                      style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1)),
                  Text(subText,
                      style: GoogleFonts.poppins(
                          fontSize: 10,
                          color:
                              Colors.white.withOpacity(0.8),
                          height: 1.3),
                      textAlign: TextAlign.center),
                ],
              ),
            ],
          ),
        );
      },
    )
        .animate()
        .scale(
            begin: const Offset(0.7, 0.7),
            duration: 900.ms,
            curve: Curves.elasticOut)
        .fadeIn(duration: 400.ms);
  }
}

// ─── Cycle Wheel Painter ──────────────────────────────────────────────────────
class _CycleWheelPainter extends CustomPainter {
  final int currentDay;
  final double progress;

  _CycleWheelPainter(
      {required this.currentDay, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    const strokeWidth = 14.0;

    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    double startAngle = -dart_math.pi / 2;
    const totalDays = 28.0;

    void drawPhaseSegment(
        int startDay, int endDay, Color color) {
      final days = endDay - startDay + 1;
      final sweepAngle =
          (days / totalDays) * dart_math.pi * 2 * progress;
      final segmentStart = startAngle +
          ((startDay - 1) / totalDays) *
              dart_math.pi *
              2 *
              progress;

      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          segmentStart,
          sweepAngle,
          false,
          paint);
    }

    drawPhaseSegment(1, 5, _phaseColorMenstrual);
    drawPhaseSegment(6, 13, _phaseColorFollicular);
    drawPhaseSegment(14, 14, _phaseColorOvulation);
    drawPhaseSegment(15, 28, _phaseColorLuteal);

    final currentAngle = startAngle +
        ((currentDay - 1) / totalDays) *
            dart_math.pi *
            2 *
            progress;
    final dotX =
        center.dx + radius * dart_math.cos(currentAngle);
    final dotY =
        center.dy + radius * dart_math.sin(currentAngle);

    if (progress > 0.9) {
      canvas.drawCircle(
          Offset(dotX, dotY), 12, Paint()..color = Colors.white);
      canvas.drawCircle(Offset(dotX, dotY), 5,
          Paint()..color = const Color(0xFFC2185B));
    }
  }

  @override
  bool shouldRepaint(covariant _CycleWheelPainter oldDelegate) {
    return oldDelegate.currentDay != currentDay ||
        oldDelegate.progress != progress;
  }
}

// ─── Phase Chip ───────────────────────────────────────────────────────────────
class _PhaseChip extends StatelessWidget {
  final Map<String, dynamic> phase;
  final Duration delay;

  const _PhaseChip({required this.phase, required this.delay});

  @override
  Widget build(BuildContext context) {
    final phaseColor = phase['color'] as Color;
    return GestureDetector(
      onTap: () => _showPhaseDetail(context),
      child: Container(
        width: 148,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: phaseColor.withOpacity(0.22), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: phaseColor.withOpacity(0.12),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: phaseColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(phase['emoji'] as String,
                        style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 12, color: phaseColor.withOpacity(0.5)),
              ],
            ),
            const SizedBox(height: 8),
            Text(phase['name'] as String,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: AppColors.textMain)),
            Text(phase['days'] as String,
                style: GoogleFonts.poppins(
                    fontSize: 10,
                    color: phaseColor,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Expanded(
              child: Text(phase['desc'] as String,
                  style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: AppColors.textSecondary,
                      height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ).animate()
          .fadeIn(duration: 400.ms, delay: delay)
          .slideX(begin: 0.2),
    );
  }

  void _showPhaseDetail(BuildContext context) {
    final phaseColor = phase['color'] as Color;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
              top: Radius.circular(28)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.cardBorder,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: phaseColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(phase['emoji'] as String,
                          style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${phase['name']} Phase',
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain),
                      ),
                      Text(phase['days'] as String,
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: phaseColor,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                phase['desc'] as String,
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: phaseColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: phaseColor.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('💡 Tip for this phase',
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: phaseColor)),
                    const SizedBox(height: 6),
                    Text(
                      phase['tip'] as String,
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textMain,
                          height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
