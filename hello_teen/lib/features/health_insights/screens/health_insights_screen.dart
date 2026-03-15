import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../mental_health/providers/mood_provider.dart';

class HealthInsightsScreen extends ConsumerWidget {
  const HealthInsightsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moodLogsAsync = ref.watch(moodLogsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5C35D4), Color(0xFF7C7CF8), Color(0xFF9C9CF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(top: -30, right: -30,
                        child: Container(width: 180, height: 180,
                            decoration: BoxDecoration(shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.06)))),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Health Insights 📊',
                                style: GoogleFonts.poppins(
                                    fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('Your wellness trends at a glance',
                                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            backgroundColor: const Color(0xFF7C7CF8),
            foregroundColor: Colors.white,
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            sliver: moodLogsAsync.when(
              data: (logs) => SliverList(
                delegate: SliverChildListDelegate([
                  _buildSummaryRow(context, logs),
                  const SizedBox(height: 28),
                  Text('Mood Trends (Last 14 Days)',
                      style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain)).animate().fadeIn(),
                  const SizedBox(height: 16),
                  _buildMoodLineChart(context, logs),
                  const SizedBox(height: 28),
                  Text('Mood Distribution',
                      style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain)).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 16),
                  _buildMoodBarChart(context, logs),
                  const SizedBox(height: 28),
                  Text('Wellness Score',
                      style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain)).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: 16),
                  _buildWellnessScore(logs),
                  const SizedBox(height: 40),
                ]),
              ),
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: Color(0xFF7C7CF8))),
              ),
              error: (e, _) => SliverFillRemaining(
                child: Center(
                    child: Text('Error loading insights: $e',
                        style: GoogleFonts.poppins(color: AppColors.textMain))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, List<dynamic> logs) {
    final totalLogs = logs.length;
    double avgMood = 0;
    int positiveDays = 0;
    if (logs.isNotEmpty) {
      avgMood = logs.fold(0.0, (sum, log) => sum + log.moodLevel) / logs.length;
      positiveDays = logs.where((log) => log.moodLevel >= 4).length;
    }

    return Row(
      children: [
        _buildStatCard(context, 'Total Logs', '$totalLogs',
            Icons.calendar_today_rounded, AppColors.primary, delay: 0.ms),
        const SizedBox(width: 12),
        _buildStatCard(context, 'Avg Mood', avgMood.toStringAsFixed(1),
            Icons.mood_rounded, AppColors.secondary, delay: 100.ms),
        const SizedBox(width: 12),
        _buildStatCard(context, 'Happy Days', '$positiveDays',
            Icons.wb_sunny_rounded, AppColors.warning, delay: 200.ms),
      ],
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color, {required Duration delay}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.18)),
          boxShadow: [BoxShadow(
              color: color.withOpacity(0.12), blurRadius: 14, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain)),
            const SizedBox(height: 2),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 10, color: AppColors.textLight)),
          ],
        ),
      ).animate().fadeIn(duration: 400.ms, delay: delay).slideY(begin: 0.15),
    );
  }

  Widget _buildMoodLineChart(BuildContext context, List<dynamic> logs) {
    if (logs.isEmpty) return _emptyChart(context, 'No mood data yet. Start logging!');
    final recentLogs = logs.length > 14 ? logs.sublist(logs.length - 14) : logs;
    final spots = <FlSpot>[];
    for (int i = 0; i < recentLogs.length; i++) {
      spots.add(FlSpot(i.toDouble(), recentLogs[i].moodLevel.toDouble()));
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [BoxShadow(
            color: AppColors.secondary.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(color: AppColors.cardBorder, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final labels = ['', '😢', '😰', '😌', '🤩', '😊'];
                  final idx = value.toInt();
                  if (idx < 1 || idx > 5) return const SizedBox.shrink();
                  return SideTitleWidget(
                      meta: meta,
                      child: Text(labels[idx], style: const TextStyle(fontSize: 12)));
                },
              ),
            ),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: 0, maxY: 6,
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              curveSmoothness: 0.4,
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                  radius: 5, color: Colors.white, strokeWidth: 2.5, strokeColor: AppColors.primary,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [AppColors.primary.withOpacity(0.2), AppColors.primary.withOpacity(0)],
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 200.ms);
  }

  Widget _buildMoodBarChart(BuildContext context, List<dynamic> logs) {
    if (logs.isEmpty) return _emptyChart(context, 'Log moods to see distribution');

    final moodCounts = <String, int>{'Happy': 0, 'Excited': 0, 'Calm': 0, 'Anxious': 0, 'Sad': 0};
    final moodLevelMap = {5: 'Happy', 4: 'Excited', 3: 'Calm', 2: 'Anxious', 1: 'Sad'};
    for (final log in logs) {
      final moodName = moodLevelMap[log.moodLevel];
      if (moodName != null) moodCounts[moodName] = (moodCounts[moodName] ?? 0) + 1;
    }

    final colors = [AppColors.primary, AppColors.warning, AppColors.secondary,
        const Color(0xFF9C27B0), const Color(0xFF2196F3)];
    final maxCount = moodCounts.values.fold(0, (a, b) => a > b ? a : b);

    return Container(
      height: 200,
      padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [BoxShadow(
            color: AppColors.secondary.withOpacity(0.08), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (maxCount + 1).toDouble(),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (v) => FlLine(color: AppColors.cardBorder, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final labels = ['😊', '🤩', '😌', '😰', '😢'];
                  final idx = value.toInt();
                  if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                  return SideTitleWidget(meta: meta,
                      child: Text(labels[idx], style: const TextStyle(fontSize: 16)));
                },
              ),
            ),
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(5, (i) {
            final keys = ['Happy', 'Excited', 'Calm', 'Anxious', 'Sad'];
            final count = moodCounts[keys[i]] ?? 0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: count.toDouble(),
                  gradient: LinearGradient(
                    colors: [colors[i], colors[i].withOpacity(0.6)],
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  ),
                  width: 28,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                ),
              ],
            );
          }),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 300.ms);
  }

  Widget _buildWellnessScore(List<dynamic> logs) {
    double score = 50;
    if (logs.isNotEmpty) {
      final recentLogs = logs.length > 7 ? logs.sublist(logs.length - 7) : logs;
      final avg = recentLogs.fold(0.0, (sum, log) => sum + log.moodLevel) / recentLogs.length;
      score = ((avg / 5) * 100).clamp(0, 100);
    }

    Color scoreColor = AppColors.error;
    String scoreLabel = 'Needs Attention';
    if (score >= 70) { scoreColor = AppColors.success; scoreLabel = 'Excellent 🌟'; }
    else if (score >= 50) { scoreColor = AppColors.warning; scoreLabel = 'Good 😊'; }
    else if (score >= 30) { scoreColor = Colors.amber; scoreLabel = 'Fair 😐'; }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scoreColor.withOpacity(0.1), scoreColor.withOpacity(0.03)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: scoreColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90, height: 90,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  backgroundColor: scoreColor.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  strokeWidth: 8,
                ),
                Center(
                  child: Text('${score.toInt()}%',
                      style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.bold, color: scoreColor)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Wellness Score',
                    style: GoogleFonts.poppins(
                        fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(scoreLabel,
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.bold, color: scoreColor)),
                const SizedBox(height: 8),
                Text(
                  logs.isEmpty
                      ? 'Start logging your mood to calculate your wellness score.'
                      : 'Based on your last ${logs.length > 7 ? 7 : logs.length} mood entries.',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textLight, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms, delay: 400.ms);
  }

  Widget _emptyChart(BuildContext context, String message) {
    return Container(
      height: 160,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.bar_chart_rounded, size: 40, color: AppColors.cardBorder),
          const SizedBox(height: 12),
          Text(message,
              style: GoogleFonts.poppins(color: AppColors.textLight, fontSize: 13)),
        ],
      ),
    );
  }
}
