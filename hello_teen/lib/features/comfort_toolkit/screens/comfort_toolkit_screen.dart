import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

// ─── Toolkit Data ──────────────────────────────────────────────────────────────
class ToolkitItem {
  final String title;
  final String subtitle;
  final String description;
  final String emoji;
  final Color color;
  final IconData icon;
  final List<String> steps;
  final String duration;
  final String benefit;

  const ToolkitItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.emoji,
    required this.color,
    required this.icon,
    required this.steps,
    required this.duration,
    required this.benefit,
  });
}

const List<ToolkitItem> _toolkitItems = [
  ToolkitItem(
    title: '4-7-8 Breathing',
    subtitle: 'Instant Calm',
    description: 'A powerful breathing technique to quickly reduce anxiety and calm your nervous system.',
    emoji: '🌬️',
    color: Color(0xFF7C7CF8),
    icon: Icons.air_rounded,
    duration: '5 minutes',
    benefit: 'Reduces anxiety by 60%',
    steps: [
      'Find a comfortable seated position',
      'Breathe in through your nose for 4 counts',
      'Hold your breath for 7 counts',
      'Exhale completely through your mouth for 8 counts',
      'Repeat 4 times for best results',
    ],
  ),
  ToolkitItem(
    title: 'Period Pain Relief',
    subtitle: 'Comfort Moves',
    description: 'Gentle stretches and techniques specifically designed to ease menstrual cramps naturally.',
    emoji: '🌸',
    color: Color(0xFFE91E63),
    icon: Icons.healing_rounded,
    duration: '10 minutes',
    benefit: 'Reduces cramps naturally',
    steps: [
      'Apply a warm heating pad to your lower belly',
      'Child\'s pose: kneel and fold forward gently for 1 minute',
      'Cat-cow stretch: alternate arching and rounding your back',
      'Supine twist: lie down and gently twist your knees side to side',
      'Hip circles: stand and make slow circles with your hips',
      'Stay hydrated! Drink warm water with ginger or chamomile tea',
    ],
  ),
  ToolkitItem(
    title: 'Desk Stretches',
    subtitle: 'Study Break',
    description: 'Quick stretches you can do anywhere to release tension from sitting and studying.',
    emoji: '🧘‍♀️',
    color: Color(0xFF4CAF50),
    icon: Icons.self_improvement_rounded,
    duration: '3 minutes',
    benefit: 'Relieves tension & fatigue',
    steps: [
      'Neck rolls: slowly roll your head in circles, 5 each direction',
      'Shoulder shrugs: lift shoulders to ears, hold 3 sec, release',
      'Chest opener: clasp hands behind back, squeeze shoulder blades',
      'Seated forward fold: hinge at hips, reach for your toes',
      'Wrist circles: rotate wrists 10 times each direction',
    ],
  ),
  ToolkitItem(
    title: 'Stress SOS',
    subtitle: '5-4-3-2-1 Method',
    description: 'A grounding technique to instantly bring you back to the present when feeling overwhelmed.',
    emoji: '🧠',
    color: Color(0xFFFF9800),
    icon: Icons.psychology_rounded,
    duration: '2 minutes',
    benefit: 'Stops panic attacks',
    steps: [
      'Notice 5 things you can SEE around you right now',
      'Notice 4 things you can TOUCH — feel their texture',
      'Notice 3 things you can HEAR in your environment',
      'Notice 2 things you can SMELL nearby',
      'Notice 1 thing you can TASTE right now',
      'Take 3 deep breaths. You are safe and grounded!',
    ],
  ),
  ToolkitItem(
    title: 'Positive Affirmations',
    subtitle: 'Daily Confidence Boost',
    description: 'Powerful affirmations to build self-esteem and start each day with confidence.',
    emoji: '💫',
    color: Color(0xFFFF6B9A),
    icon: Icons.star_rounded,
    duration: '2 minutes',
    benefit: 'Builds self-confidence',
    steps: [
      'Stand in front of a mirror and look into your own eyes',
      '\"I am enough exactly as I am right now\"',
      '\"My body is amazing and I treat it with kindness\"',
      '\"My feelings are valid and I handle them with grace\"',
      '\"I am growing stronger and wiser every single day\"',
      'Repeat each affirmation 3 times with feeling!',
    ],
  ),
  ToolkitItem(
    title: 'Progressive Relaxation',
    subtitle: 'Full Body Release',
    description: 'Release tension from every muscle group systematically for deep relaxation.',
    emoji: '✨',
    color: Color(0xFF43C6AC),
    icon: Icons.spa_rounded,
    duration: '10 minutes',
    benefit: 'Deep muscle relaxation',
    steps: [
      'Lie down comfortably on your back',
      'Start with your feet: tense for 5 sec, then relax completely',
      'Move up to your calves, thighs, then stomach',
      'Continue with your chest, arms, and hands',
      'Finally tense your face muscles, then let go',
      'Breathe deeply and enjoy the full body relaxation',
    ],
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────
class ComfortToolkitScreen extends StatefulWidget {
  const ComfortToolkitScreen({Key? key}) : super(key: key);

  @override
  State<ComfortToolkitScreen> createState() => _ComfortToolkitScreenState();
}

class _ComfortToolkitScreenState extends State<ComfortToolkitScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Breathing', 'Stretching', 'Mental'];

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
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2E7D32), Color(0xFF43C6AC), Color(0xFF4ECDC4)],
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
                        )),
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
                                  child: const Icon(Icons.spa_rounded,
                                      color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Comfort Toolkit 🌿',
                                        style: GoogleFonts.poppins(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    Text('Self-care for difficult moments',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white70)),
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

          // ── Emergency Banner ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 16, 20, 4),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.success.withOpacity(0.12),
                    AppColors.accent.withOpacity(0.06),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.success.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Text('🆘', style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Feeling really low?',
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textMain),
                        ),
                        Text(
                          'Start with the 4-7-8 breathing below. It works in 2 minutes.',
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),

          // ── Toolkit Grid ───────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.78,
              ),
              itemCount: _toolkitItems.length,
              itemBuilder: (context, index) {
                return _ToolkitCard(
                  item: _toolkitItems[index],
                  delay: (index * 80).ms,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Toolkit Card ─────────────────────────────────────────────────────────────
class _ToolkitCard extends StatefulWidget {
  final ToolkitItem item;
  final Duration delay;

  const _ToolkitCard({required this.item, required this.delay});

  @override
  State<_ToolkitCard> createState() => _ToolkitCardState();
}

class _ToolkitCardState extends State<_ToolkitCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _showDetail(context);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: widget.item.color.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.item.color.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gradient top
              Container(
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.item.color.withOpacity(0.15),
                      widget.item.color.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(22)),
                ),
                child: Center(
                  child: Text(
                    widget.item.emoji,
                    style: const TextStyle(fontSize: 44),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.title,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.item.subtitle,
                        style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: widget.item.color,
                            fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(Icons.timer_rounded,
                              size: 12, color: AppColors.textLight),
                          const SizedBox(width: 3),
                          Text(
                            widget.item.duration,
                            style: GoogleFonts.poppins(
                                fontSize: 10,
                                color: AppColors.textLight),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: widget.item.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                              color: widget.item.color.withOpacity(0.2)),
                        ),
                        child: Text(
                          'Start →',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: widget.item.color,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 350.ms, delay: widget.delay).slideY(begin: 0.15),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ToolkitDetailSheet(item: widget.item),
    );
  }
}

// ─── Detail Sheet ─────────────────────────────────────────────────────────────
class _ToolkitDetailSheet extends StatelessWidget {
  final ToolkitItem item;

  const _ToolkitDetailSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
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
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(24),
                children: [
                  // Header
                  Row(
                    children: [
                      Text(item.emoji,
                          style: const TextStyle(fontSize: 48)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                              ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: item.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                item.benefit,
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: item.color,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Description
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      item.description,
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Info row
                  Row(
                    children: [
                      _InfoChip(
                          icon: Icons.timer_rounded,
                          label: item.duration,
                          color: item.color),
                      const SizedBox(width: 10),
                      _InfoChip(
                          icon: Icons.fitness_center_rounded,
                          label: '${item.steps.length} steps',
                          color: item.color),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Step-by-Step Guide',
                    style: GoogleFonts.poppins(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 14),

                  ...item.steps.asMap().entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: item.color.withOpacity(0.12)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: item.color,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                '${entry.key + 1}',
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              entry.value,
                              style: GoogleFonts.poppins(
                                fontSize: 13.5,
                                color: AppColors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ).animate()
                        .fadeIn(duration: 300.ms, delay: (entry.key * 80).ms)
                        .slideX(begin: 0.1);
                  }).toList(),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: item.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text('Done! I feel better 💕',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
