import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../education/screens/education_hub_screen.dart';
import '../../ai_assistant/screens/ai_assistant_screen.dart';
import '../../mental_health/screens/mental_health_screen.dart';
import '../../myth_buster/screens/myth_buster_screen.dart';
import '../../period_tracker/screens/period_tracker_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../profile/providers/profile_provider.dart';
import '../../health_insights/screens/health_insights_screen.dart';
import '../../mood_companion/screens/mood_companion_screen.dart';
import '../../body_timeline/screens/body_timeline_screen.dart';
import '../../community/screens/community_screen.dart';
import '../../comfort_toolkit/screens/comfort_toolkit_screen.dart';
import '../../gamified_learning/screens/gamified_learning_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../knowledge_library/screens/knowledge_library_screen.dart';
import '../../ai_recommendations/screens/ai_recommendations_screen.dart';
import '../../daily_challenges/screens/daily_challenges_screen.dart';
import '../../health_timeline/screens/health_timeline_screen.dart';
import '../../wellness_score/widgets/wellness_score_card.dart';
import '../../emergency/screens/emergency_support_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getGreetingEmoji() {
    final hour = DateTime.now().hour;
    if (hour < 12) return '☀️';
    if (hour < 17) return '🌤️';
    return '🌙';
  }

  final List<Map<String, dynamic>> _healthTips = [
    {
      'tip': 'Drink at least 8 glasses of water today. Staying hydrated boosts energy and mood!',
      'emoji': '💧',
      'color': AppColors.secondary,
    },
    {
      'tip': 'Take 5 deep breaths when you feel stressed. Your mental health matters!',
      'emoji': '🌸',
      'color': AppColors.primary,
    },
    {
      'tip': 'A good night\'s sleep (8-9 hours) helps your body grow and heal!',
      'emoji': '😴',
      'color': Color(0xFF6C63FF),
    },
    {
      'tip': 'Eating fruits and veggies gives your skin a natural healthy glow!',
      'emoji': '🥦',
      'color': AppColors.success,
    },
    {
      'tip': 'A 15-minute walk can significantly boost your mood and reduce anxiety!',
      'emoji': '🚶‍♀️',
      'color': AppColors.accent,
    },
  ];

  late int _tipIndex;

  @override
  void initState() {
    super.initState();
    _tipIndex = DateTime.now().day % _healthTips.length;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsyncValue = ref.watch(userProfileStreamProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: userProfileAsyncValue.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          final isGirl = profile['gender']?.toString().toLowerCase() == 'girl';
          final firstName = profile['name']?.toString().split(' ').first ?? 'Teen';
          return _buildBody(context, firstName, isGirl);
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
        error: (error, _) => _buildBody(context, 'Teen', true),
      ),
    );
  }

  Widget _buildBody(BuildContext context, String firstName, bool isGirl) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 900 ? 4 : screenWidth > 600 ? 3 : 2;
    final features = _buildFeatures(isGirl);
    final quickAccess = _buildQuickAccess(isGirl);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Premium Header ──────────────────────────────────
        SliverAppBar(
          expandedHeight: 240,
          floating: false,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          actions: [
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.settings_rounded,
                    color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.person_rounded, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            collapseMode: CollapseMode.pin,
            background: _buildHeader(firstName),
          ),
        ),

        // ── Daily Tip ────────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
            child: _buildDailyTipCard(),
          ),
        ),

        // ── Wellness Score Card ───────────────────────────────
        const SliverToBoxAdapter(
          child: WellnessScoreCard(),
        ),

        // ── Quick Access Row ─────────────────────────────────
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Quick Access',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const EmergencySupportScreen())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE53935).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE53935).withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emergency_rounded,
                                color: Color(0xFFE53935), size: 14),
                            const SizedBox(width: 4),
                            Text('SOS',
                                style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFE53935))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(),
              ),
              SizedBox(
                height: 88,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  itemCount: quickAccess.length,
                  itemBuilder: (context, index) {
                    final item = quickAccess[index];
                    return _QuickAccessItem(
                      label: item['label'] as String,
                      emoji: item['emoji'] as String,
                      color: item['color'] as Color,
                      onTap: item['onTap'] as VoidCallback,
                      delay: (index * 70).ms,
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),

        // ── Section Title ────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              screenWidth > 600 ? 28 : 20,
              8,
              20,
              14,
            ),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 22,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: AppColors.primaryGradient,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'All Features',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
          ),
        ),

        // ── Feature Grid ─────────────────────────────────────
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            screenWidth > 600 ? 24 : 16,
            0,
            screenWidth > 600 ? 24 : 16,
            40,
          ),
          sliver: SliverGrid.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: screenWidth > 600 ? 0.88 : 0.82,
            ),
            itemCount: features.length,
            itemBuilder: (context, index) {
              final feature = features[index];
              return _FeatureCard(
                title: feature['title'] as String,
                subtitle: feature['subtitle'] as String,
                imagePath: feature['imagePath'] as String,
                color: feature['color'] as Color,
                icon: feature['icon'] as IconData,
                onTap: feature['onTap'] as VoidCallback,
                delay: (index * 70).ms,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(String firstName) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFFF6B9A), Color(0xFF7C7CF8), Color(0xFF4ECDC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40, right: -40,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            bottom: -20, left: -30,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            top: 60, right: 80,
            child: Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_getGreeting()} ${_getGreetingEmoji()}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.white.withOpacity(0.95),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ).animate().fadeIn(duration: 500.ms),
                        const SizedBox(height: 10),
                        Text(
                          '$firstName! 👋',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
                        const SizedBox(height: 8),
                        Text(
                          'Your health, your journey ✨',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w400,
                          ),
                        ).animate().fadeIn(duration: 700.ms),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        width: 82, height: 82,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(
                            0.15 + _pulseController.value * 0.08,
                          ),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(
                                  0.1 + _pulseController.value * 0.15),
                              blurRadius: 20 + _pulseController.value * 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 40,
                        ),
                      );
                    },
                  ).animate().fadeIn(duration: 700.ms).scale(begin: const Offset(0.5, 0.5)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTipCard() {
    final tip = _healthTips[_tipIndex];
    final color = tip['color'] as Color;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.18), color.withOpacity(0.06)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(tip['emoji'] as String,
                  style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Today\'s Health Tip',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tip['tip'] as String,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: AppColors.textMain,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms, delay: 200.ms).slideY(begin: 0.1);
  }

  List<Map<String, dynamic>> _buildQuickAccess(bool isGirl) {
    return [
      {
        'label': 'Mood',
        'emoji': '💭',
        'color': AppColors.primary,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const MoodCompanionScreen())),
      },
      {
        'label': 'AI Chat',
        'emoji': '🤖',
        'color': AppColors.secondary,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AiAssistantScreen())),
      },
      if (isGirl) {
        'label': 'Tracker',
        'emoji': '🌸',
        'color': Colors.pink,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const PeriodTrackerScreen())),
      },
      {
        'label': 'Breathe',
        'emoji': '🌬️',
        'color': AppColors.accent,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ComfortToolkitScreen())),
      },
      {
        'label': 'Community',
        'emoji': '🤝',
        'color': AppColors.warning,
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CommunityScreen())),
      },
      {
        'label': 'Challenges',
        'emoji': '🏆',
        'color': const Color(0xFFFF9800),
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const DailyChallengesScreen())),
      },
      {
        'label': 'Library',
        'emoji': '📚',
        'color': const Color(0xFF2196F3),
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const KnowledgeLibraryScreen())),
      },
      {
        'label': '🆘 SOS',
        'emoji': '🆘',
        'color': const Color(0xFFE53935),
        'onTap': () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const EmergencySupportScreen())),
      },
    ].whereType<Map<String, dynamic>>().toList();
  }

  List<Map<String, dynamic>> _buildFeatures(bool isGirl) {
    final features = <Map<String, dynamic>>[
      {
        'title': 'AI Assistant',
        'subtitle': 'Ask anything anonymously',
        'imagePath': 'assets/images/ai_assistant.png',
        'color': AppColors.secondary,
        'icon': Icons.smart_toy_rounded,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AiAssistantScreen())),
      },
      {
        'title': 'Mood Companion',
        'subtitle': 'Daily emotional check-in',
        'imagePath': 'assets/images/mood_companion.png',
        'color': AppColors.primary,
        'icon': Icons.favorite_rounded,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const MoodCompanionScreen())),
      },
      {
        'title': 'Learning Journey',
        'subtitle': 'Earn XP & badges',
        'imagePath': 'assets/images/education.png',
        'color': const Color(0xFF7C7CF8),
        'icon': Icons.school_rounded,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const GamifiedLearningScreen())),
      },
      {
        'title': 'Education Hub',
        'subtitle': 'Learn about your body',
        'imagePath': 'assets/images/education.png',
        'color': AppColors.primary,
        'icon': Icons.menu_book_rounded,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const EducationHubScreen())),
      },
      {
        'title': 'Mental Wellness',
        'subtitle': 'Mood & breathing tools',
        'imagePath': 'assets/images/mental_health.png',
        'color': AppColors.success,
        'icon': Icons.spa_rounded,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const MentalHealthScreen())),
      },
      {
        'title': 'Comfort Toolkit',
        'subtitle': 'Self-care for hard moments',
        'imagePath': 'assets/images/breathing_exercise.png',
        'color': const Color(0xFF43C6AC),
        'icon': Icons.healing_rounded,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ComfortToolkitScreen())),
      },
      {
        'title': 'Body Timeline',
        'subtitle': 'Puberty journey ages 10-18',
        'imagePath': 'assets/images/puberty_timeline.png',
        'color': const Color(0xFF9C27B0),
        'icon': Icons.timeline_rounded,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const BodyTimelineScreen())),
      },
      {
        'title': 'Safe Community',
        'subtitle': 'Ask questions anonymously',
        'imagePath': 'assets/images/community.png',
        'color': AppColors.secondary,
        'icon': Icons.forum_rounded,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const CommunityScreen())),
      },
      {
        'title': 'Myth vs Fact',
        'subtitle': 'Bust health myths',
        'imagePath': 'assets/images/myth_fact.png',
        'color': AppColors.warning,
        'icon': Icons.fact_check_rounded,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const MythBusterScreen())),
      },
      {
        'title': 'Health Insights',
        'subtitle': 'View your trends',
        'imagePath': 'assets/images/health_insights.png',
        'color': const Color(0xFF6C63FF),
        'icon': Icons.insights_rounded,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const HealthInsightsScreen())),
      },
      {
        'title': 'Knowledge Library',
        'subtitle': 'Safe health education',
        'imagePath': 'assets/images/knowledge_library.png',
        'color': const Color(0xFF2196F3),
        'icon': Icons.menu_book_rounded,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const KnowledgeLibraryScreen())),
      },
      {
        'title': 'Daily Challenges',
        'subtitle': 'Earn points & badges',
        'imagePath': 'assets/images/challenges.png',
        'color': const Color(0xFFFF9800),
        'icon': Icons.emoji_events_rounded,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const DailyChallengesScreen())),
      },
      {
        'title': 'AI Recommendations',
        'subtitle': 'Personalized wellness tips',
        'imagePath': 'assets/images/recommendations.png',
        'color': const Color(0xFF9C27B0),
        'icon': Icons.auto_awesome_rounded,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const AiRecommendationsScreen())),
      },
      {
        'title': 'Health Timeline',
        'subtitle': 'Your wellness journey',
        'imagePath': 'assets/images/timeline.png',
        'color': const Color(0xFF00897B),
        'icon': Icons.timeline_rounded,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const HealthTimelineScreen())),
      },
      {
        'title': 'Emergency Support',
        'subtitle': 'Crisis helplines & coping tools',
        'imagePath': 'assets/images/emergency.png',
        'color': const Color(0xFFE53935),
        'icon': Icons.emergency_rounded,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const EmergencySupportScreen())),
      },
    ];

    if (isGirl) {
      features.insert(3, {
        'title': 'Period Tracker',
        'subtitle': 'Track your cycle',
        'imagePath': 'assets/images/period_tracker.png',
        'color': Colors.pink,
        'icon': Icons.water_drop_rounded,
        'onTap': () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const PeriodTrackerScreen())),
      });
    }
    return features;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Quick Access Item
// ─────────────────────────────────────────────────────────────────────────────
class _QuickAccessItem extends StatefulWidget {
  final String label;
  final String emoji;
  final Color color;
  final VoidCallback onTap;
  final Duration delay;

  const _QuickAccessItem({
    required this.label,
    required this.emoji,
    required this.color,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_QuickAccessItem> createState() => _QuickAccessItemState();
}

class _QuickAccessItemState extends State<_QuickAccessItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: 70,
          margin: const EdgeInsets.only(right: 12),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: widget.color.withOpacity(0.25), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: widget.color.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(widget.emoji,
                      style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.label,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ).animate().fadeIn(duration: 300.ms, delay: widget.delay).slideY(begin: 0.2),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Feature Card
// ─────────────────────────────────────────────────────────────────────────────
class _FeatureCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String imagePath;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;
  final Duration delay;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.color,
    required this.icon,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.color.withOpacity(0.18),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              children: [
                Positioned(
                  top: 0, left: 0, right: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          widget.color.withOpacity(0.08),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.color.withOpacity(0.15),
                              widget.color.withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: widget.color.withOpacity(0.25),
                            width: 1.5,
                          ),
                        ),
                        child: ClipOval(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Image.asset(
                              widget.imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => Icon(
                                widget.icon,
                                color: widget.color,
                                size: 32,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        widget.title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          widget.subtitle,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 10.5,
                            color: AppColors.textLight,
                            height: 1.35,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.color,
                              widget.color.withOpacity(0.75)
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'Explore →',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ).animate().fadeIn(duration: 400.ms, delay: widget.delay).slideY(begin: 0.15),
      ),
    );
  }
}
