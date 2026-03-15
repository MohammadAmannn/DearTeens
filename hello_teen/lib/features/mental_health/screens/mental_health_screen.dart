import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/mood_provider.dart';

class MentalHealthScreen extends ConsumerStatefulWidget {
  const MentalHealthScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MentalHealthScreen> createState() => _MentalHealthScreenState();
}

class _MentalHealthScreenState extends ConsumerState<MentalHealthScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedMood;
  bool _isLoading = false;
  late TabController _tabController;
  final TextEditingController _journalController = TextEditingController();
  int _breathPhase = 0;
  bool _breathingActive = false;

  final List<Map<String, dynamic>> moods = [
    {'label': 'happy',   'display': 'Happy',   'emoji': '😊', 'color': AppColors.primary,              'level': 5},
    {'label': 'excited', 'display': 'Excited', 'emoji': '🤩', 'color': AppColors.warning,              'level': 4},
    {'label': 'calm',    'display': 'Calm',    'emoji': '😌', 'color': AppColors.secondary,            'level': 3},
    {'label': 'anxious', 'display': 'Anxious', 'emoji': '😰', 'color': const Color(0xFF9C27B0),        'level': 2},
    {'label': 'sad',     'display': 'Sad',     'emoji': '😢', 'color': const Color(0xFF2196F3),        'level': 1},
  ];

  final List<Map<String, dynamic>> _stressTips = [
    {'icon': Icons.music_note_rounded,      'title': 'Listen to Music',  'desc': 'Calm or upbeat music can shift your mood instantly.',           'color': Color(0xFF9C27B0)},
    {'icon': Icons.directions_walk_rounded, 'title': 'Take a Walk',      'desc': 'Fresh air and movement reduce stress hormones naturally.',      'color': AppColors.success},
    {'icon': Icons.book_rounded,            'title': 'Journal It Out',   'desc': 'Writing thoughts helps process emotions and clear your mind.',  'color': AppColors.warning},
    {'icon': Icons.people_rounded,          'title': 'Talk to Someone',  'desc': 'Share your feelings with a trusted friend or adult.',           'color': AppColors.primary},
    {'icon': Icons.self_improvement_rounded,'title': 'Meditate',         'desc': 'Even 5 minutes of mindfulness can reduce anxiety significantly.', 'color': AppColors.accent},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _journalController.dispose();
    super.dispose();
  }

  Future<void> _logMood() async {
    if (_selectedMood == null) return;
    setState(() => _isLoading = true);
    try {
      final moodMap = moods.firstWhere((m) => m['label'] == _selectedMood);
      await ref.read(moodProvider).addMoodLog(
        _selectedMood!,
        moodMap['level'],
        note: _journalController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text('Mood logged! Keep taking care of yourself 💕',
                    style: GoogleFonts.poppins(color: Colors.white)),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );
        setState(() {
          _selectedMood = null;
          _journalController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString(), style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.success,
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF43C6AC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(top: -30, right: -30,
                        child: _circle(180, Colors.white.withOpacity(0.05))),
                    Positioned(bottom: -20, left: -30,
                        child: _circle(120, Colors.white.withOpacity(0.05))),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Mental Wellness 🌿',
                                style: GoogleFonts.poppins(
                                    fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 2),
                            Text('Your daily wellness companion',
                                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF43C6AC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13),
                  unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w400, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Mood Log'),
                    Tab(text: 'Breathe'),
                    Tab(text: 'Tips'),
                  ],
                ),
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildMoodTabContent(),
            _buildBreathingTab(),
            _buildTipsTab(),
          ],
        ),
      ),
    );
  }

  Widget _circle(double size, Color color) =>
      Container(width: size, height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color));

  Widget _buildMoodTabContent() {
    final moodLogsAsync = ref.watch(moodLogsStreamProvider);
    final surface = Theme.of(context).colorScheme.surface;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Heading
          Text(
            'How are you feeling right now?',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textMain,
            ),
          ).animate().fadeIn(duration: 400.ms),
          const SizedBox(height: 20),

          // Mood Selector
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: moods.map((mood) {
              final isSelected = _selectedMood == mood['label'];
              return GestureDetector(
                onTap: () => setState(() => _selectedMood = mood['label']),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      width: isSelected ? 68 : 58,
                      height: isSelected ? 68 : 58,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (mood['color'] as Color).withOpacity(0.15)
                            : surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? (mood['color'] as Color)
                              : AppColors.cardBorder,
                          width: isSelected ? 2.5 : 1.5,
                        ),
                        boxShadow: [
                          if (isSelected)
                            BoxShadow(
                              color: (mood['color'] as Color).withOpacity(0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Center(
                        child: Text(mood['emoji'] as String,
                            style: TextStyle(fontSize: isSelected ? 30 : 26)),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mood['display'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        color: isSelected
                            ? (mood['color'] as Color)
                            : AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Journal Input
          TextField(
            controller: _journalController,
            maxLines: 3,
            style: GoogleFonts.poppins(
              color: AppColors.textMain,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Add a note about how you feel (optional)...',
              hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 13),
              filled: true,
              fillColor: surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.success, width: 2),
              ),
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: const Icon(Icons.edit_note_rounded, color: AppColors.success),
            ),
          ).animate().fadeIn(duration: 500.ms, delay: 200.ms),

          const SizedBox(height: 16),

          // Log Button
          if (_selectedMood != null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _logMood,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.check_rounded),
                label: Text(
                  _isLoading ? 'Saving...' : 'Log My Mood',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.9, 0.9)),
            ),

          const SizedBox(height: 32),

          // Mood History
          Text('Your Mood Trends',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain)),
          const SizedBox(height: 14),

          moodLogsAsync.when(
            data: (logs) {
              if (logs.isEmpty) {
                return Container(
                  height: 160,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bar_chart_rounded, size: 48, color: AppColors.cardBorder),
                      const SizedBox(height: 12),
                      Text('Log your first mood to see trends!',
                          style: GoogleFonts.poppins(
                              color: AppColors.textLight, fontSize: 13)),
                    ],
                  ),
                );
              }
              final recentLogs = logs.length > 7 ? logs.sublist(logs.length - 7) : logs;
              final spots = <FlSpot>[];
              for (int i = 0; i < recentLogs.length; i++) {
                spots.add(FlSpot(i.toDouble(), recentLogs[i].moodLevel.toDouble()));
              }
              return Container(
                height: 200,
                padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawHorizontalLine: true,
                      drawVerticalLine: false,
                      getDrawingHorizontalLine: (v) =>
                          FlLine(color: AppColors.cardBorder, strokeWidth: 1),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index < 0 || index >= recentLogs.length) {
                              return const SizedBox.shrink();
                            }
                            final log = recentLogs[index];
                            final emoji = moods.firstWhere(
                              (m) => m['level'] == log.moodLevel,
                              orElse: () => moods[2],
                            )['emoji'] as String;
                            return SideTitleWidget(
                              meta: meta,
                              child: Text(emoji, style: const TextStyle(fontSize: 14)),
                            );
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minY: 0,
                    maxY: 6,
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        curveSmoothness: 0.35,
                        color: AppColors.success,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                            radius: 5,
                            color: Colors.white,
                            strokeWidth: 2.5,
                            strokeColor: AppColors.success,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.success.withOpacity(0.2),
                              AppColors.success.withOpacity(0),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => SizedBox(
                height: 200,
                child: Center(
                    child: CircularProgressIndicator(color: AppColors.success))),
            error: (e, _) => SizedBox(
                height: 100,
                child: Center(
                    child: Text('$e',
                        style: GoogleFonts.poppins(color: AppColors.textLight)))),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBreathingTab() {
    final phases = ['Inhale...', 'Hold...', 'Exhale...'];
    final colors = [AppColors.secondary, AppColors.accent, AppColors.success];
    final currentColor = colors[_breathPhase];

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Box Breathing Exercise',
              style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain),
            ),
            const SizedBox(height: 8),
            Text(
              'Breathe in... hold... breathe out.\nReduces stress in minutes.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  color: AppColors.textLight, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 48),

            // Glow ring
            GestureDetector(
              onTap: () {
                if (!_breathingActive) {
                  setState(() => _breathingActive = true);
                  _startBreathing();
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer glow
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    width: _breathingActive
                        ? (_breathPhase == 0 ? 230 : (_breathPhase == 1 ? 230 : 165))
                        : 185,
                    height: _breathingActive
                        ? (_breathPhase == 0 ? 230 : (_breathPhase == 1 ? 230 : 165))
                        : 185,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: currentColor.withOpacity(0.06),
                    ),
                  ),
                  // Inner circle
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeInOut,
                    width: _breathingActive
                        ? (_breathPhase == 0 ? 190 : (_breathPhase == 1 ? 190 : 135))
                        : 155,
                    height: _breathingActive
                        ? (_breathPhase == 0 ? 190 : (_breathPhase == 1 ? 190 : 135))
                        : 155,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          currentColor.withOpacity(0.25),
                          currentColor.withOpacity(0.08),
                        ],
                      ),
                      border: Border.all(color: currentColor, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: currentColor.withOpacity(0.35),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.air_rounded, size: 36, color: currentColor),
                        const SizedBox(height: 8),
                        Text(
                          _breathingActive ? phases[_breathPhase] : 'Tap to Start',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: currentColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            if (_breathingActive)
              OutlinedButton(
                onPressed: () => setState(() {
                  _breathingActive = false;
                  _breathPhase = 0;
                }),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.cardBorder),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text('Stop', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),

            const SizedBox(height: 32),

            // Steps
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  _buildBreathingStep(1, 'Inhale', '4 seconds', colors[0]),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _buildBreathingStep(2, 'Hold', '4 seconds', colors[1]),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
                  _buildBreathingStep(3, 'Exhale', '4 seconds', colors[2]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startBreathing() async {
    while (_breathingActive && mounted) {
      for (int i = 0; i < 3; i++) {
        if (!_breathingActive || !mounted) break;
        setState(() => _breathPhase = i);
        await Future.delayed(const Duration(seconds: 4));
      }
    }
  }

  Widget _buildBreathingStep(int step, String label, String duration, Color color) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(
            child: Text('$step',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: color)),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.textMain)),
            Text(duration,
                style: GoogleFonts.poppins(
                    color: AppColors.textLight, fontSize: 12)),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(duration,
              style: GoogleFonts.poppins(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildTipsTab() {
    final surface = Theme.of(context).colorScheme.surface;
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: _stressTips.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Text(
              'Stress Relief Tips 💆‍♀️',
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain),
            ),
          ).animate().fadeIn();
        }
        final tip = _stressTips[index - 1];
        final tipColor = tip['color'] as Color;
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: tipColor.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: tipColor.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [tipColor.withOpacity(0.2), tipColor.withOpacity(0.06)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(tip['icon'] as IconData, color: tipColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip['title'] as String,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textMain),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        tip['desc'] as String,
                        style: GoogleFonts.poppins(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: ((index - 1) * 80).ms).slideX(begin: 0.1);
      },
    );
  }
}
