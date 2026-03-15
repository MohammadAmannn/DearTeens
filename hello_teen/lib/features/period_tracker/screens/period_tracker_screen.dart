import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/period_provider.dart';
import 'add_log_screen.dart';

// Phase color constants
const Color _phaseColorMenstrual = Color(0xFFE91E63);
const Color _phaseColorFollicular = Color(0xFF7C7CF8);
const Color _phaseColorOvulation = Color(0xFFFF9800);
const Color _phaseColorLuteal = Color(0xFF009688);

const List<Map<String, dynamic>> _phases = [
  {'name': 'Menstrual', 'days': 'Days 1-5', 'icon': Icons.water_drop_rounded, 'color': _phaseColorMenstrual, 'desc': 'Period occurs. Rest & self-care.'},
  {'name': 'Follicular', 'days': 'Days 6-13', 'icon': Icons.local_florist_rounded, 'color': _phaseColorFollicular, 'desc': 'Energy rises. Ideal for new starts.'},
  {'name': 'Ovulation', 'days': 'Day 14', 'icon': Icons.wb_sunny_rounded, 'color': _phaseColorOvulation, 'desc': 'Peak energy & confidence.'},
  {'name': 'Luteal', 'days': 'Days 15-28', 'icon': Icons.nightlight_rounded, 'color': _phaseColorLuteal, 'desc': 'Energy dips. Be gentle with yourself.'},
];

class PeriodTrackerScreen extends ConsumerWidget {
  const PeriodTrackerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cycleLogsAsync = ref.watch(cycleLogsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: cycleLogsAsync.when(
        data: (logs) {
          final nextPeriod = ref.read(periodProvider).predictNextPeriod(logs);
          final daysUntil = nextPeriod.difference(DateTime.now()).inDays;
          return _buildBody(context, logs, daysUntil, nextPeriod);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Colors.pink)),
        error: (error, _) => Center(
            child: Text('Error: $error',
                style: GoogleFonts.poppins(color: AppColors.textMain))),
      ),
    );
  }

  Widget _buildBody(BuildContext context, List<dynamic> logs, int daysUntil, DateTime nextPeriod) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 270,
          pinned: true,
          backgroundColor: Colors.pink,
          foregroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFC2185B), Color(0xFFE91E8C), Color(0xFFFF6B9A)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(top: -30, right: -30, child: _circle(200, Colors.white.withOpacity(0.05))),
                  Positioned(bottom: 20, left: -40, child: _circle(150, Colors.white.withOpacity(0.05))),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Period Tracker 🌸',
                              style: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                          Text('Track & understand your cycle',
                              style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70)),
                          const SizedBox(height: 20),
                          Center(child: _AnimatedCycleIndicator(daysUntil: daysUntil, nextPeriod: nextPeriod)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Cycle Phases Title
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Text('Cycle Phases',
                style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain)).animate().fadeIn(),
          ),
        ),

        // Phases horizontal scroll
        SliverToBoxAdapter(
          child: SizedBox(
            height: 130,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              itemCount: _phases.length,
              itemBuilder: (context, index) {
                return _PhaseChip(phase: _phases[index], delay: (index * 100).ms);
              },
            ),
          ),
        ),

        // Logs Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('My Period Logs',
                    style: GoogleFonts.poppins(
                        fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                GestureDetector(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddLogScreen())),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                          colors: [Color(0xFFC2185B), Color(0xFFFF6B9A)]),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pink.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text('Add Log',
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),
          ),
        ),

        if (logs.isEmpty)
          SliverToBoxAdapter(child: _buildEmptyLogs().animate().fadeIn(duration: 400.ms))
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final log = logs[index];
                final startStr = '${log.periodStart.toLocal()}'.split(' ')[0];
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
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.pink.withOpacity(0.2)),
                      boxShadow: [BoxShadow(
                          color: Colors.pink.withOpacity(0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                    colors: [Color(0xFFE91E8C), Color(0xFFFF6B9A)]),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.water_drop_rounded,
                                  color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('$startStr → $endStr',
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: AppColors.textMain)),
                                  if (duration != null)
                                    Text('Duration: $duration',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: AppColors.textLight)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (log.symptoms.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: (log.symptoms as List).map<Widget>((symptom) =>
                                Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.pink.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.pink.withOpacity(0.25)),
                              ),
                              child: Text(symptom.toString(),
                                  style: GoogleFonts.poppins(
                                      color: const Color(0xFFC2185B),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600)),
                            )).toList(),
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms, delay: (index * 80).ms),
                );
              },
              childCount: logs.length,
            ),
          ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
      ],
    );
  }

  Widget _circle(double size, Color color) {
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }

  Widget _buildEmptyLogs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.pink.withOpacity(0.18)),
        boxShadow: [BoxShadow(
            color: Colors.pink.withOpacity(0.08), blurRadius: 16)],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
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
          Text('Tap "Add Log" to start tracking',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textLight),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Animated Cycle Indicator
// -----------------------------------------------------------------------------
class _AnimatedCycleIndicator extends StatelessWidget {
  final int daysUntil;
  final DateTime nextPeriod;

  const _AnimatedCycleIndicator({required this.daysUntil, required this.nextPeriod});

  @override
  Widget build(BuildContext context) {
    String daysText;
    String subText;
    if (daysUntil > 0) {
      daysText = '$daysUntil days';
      subText = 'Until next period';
    } else if (daysUntil == 0) {
      daysText = 'Today';
      subText = 'Period expected';
    } else {
      daysText = '${-daysUntil}d late';
      subText = 'Consider logging';
    }

    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.18),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 2.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(daysText, style: GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
          Text(subText, style: GoogleFonts.poppins(fontSize: 11, color: Colors.white.withOpacity(0.8)), textAlign: TextAlign.center),
        ],
      ),
    ).animate()
        .scale(begin: const Offset(0.6, 0.6), duration: 700.ms, curve: Curves.elasticOut)
        .fadeIn(duration: 400.ms);
  }
}

// -----------------------------------------------------------------------------
// Phase Chip
// -----------------------------------------------------------------------------
class _PhaseChip extends StatelessWidget {
  final Map<String, dynamic> phase;
  final Duration delay;

  const _PhaseChip({required this.phase, required this.delay});

  @override
  Widget build(BuildContext context) {
    final phaseColor = phase['color'] as Color;
    return Container(
      width: 152,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: phaseColor.withOpacity(0.22), width: 1.5),
        boxShadow: [BoxShadow(
            color: phaseColor.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: phaseColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(phase['icon'] as IconData, color: phaseColor, size: 20),
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
    ).animate().fadeIn(duration: 400.ms, delay: delay).slideX(begin: 0.2);
  }
}
