import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../home/screens/home_screen.dart';
import '../../mood_companion/screens/mood_companion_screen.dart';
import '../../health_insights/screens/health_insights_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../comfort_toolkit/screens/comfort_toolkit_screen.dart';
import '../../daily_challenges/screens/daily_challenges_screen.dart';
import '../../knowledge_library/screens/knowledge_library_screen.dart';
import '../../ai_recommendations/screens/ai_recommendations_screen.dart';
import '../../health_timeline/screens/health_timeline_screen.dart';
import '../../community/screens/community_screen.dart';
import 'login_screen.dart';
import '../providers/auth_provider.dart';


class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _heartCtrl;
  late final AnimationController _textCtrl;
  late final AnimationController _ringCtrl;
  late final AnimationController _particleCtrl;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));

    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _particleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _animate();
  }

  Future<void> _animate() async {
    await Future.delayed(200.ms);
    _heartCtrl.forward();
    await Future.delayed(400.ms);
    _textCtrl.forward();

    // Init notifications in background
    NotificationService.instance.init().catchError((_) {});

    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    final user = ref.read(authProvider).currentUser;
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => user != null
            ? const MainShell()
            : const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: 600.ms,
      ),
    );
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    _textCtrl.dispose();
    _ringCtrl.dispose();
    _particleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
              Color(0xFF0F3460),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // ── Animated background particles ──────────────────────────────
            ..._buildParticles(),

            // ── Glowing ring ────────────────────────────────────────────────
            Center(
              child: AnimatedBuilder(
                animation: _ringCtrl,
                builder: (_, __) => Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer pulsing ring
                    Container(
                      width: 200 + _ringCtrl.value * 20,
                      height: 200 + _ringCtrl.value * 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(
                              0.08 + (1 - _ringCtrl.value) * 0.12),
                          width: 1.5,
                        ),
                      ),
                    ),
                    // Inner ring
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.18),
                            AppColors.secondary.withOpacity(0.08),
                            Colors.transparent,
                          ],
                          stops: const [0, 0.6, 1],
                        ),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                    ),
                    // Core – heart icon
                    ScaleTransition(
                      scale: CurvedAnimation(
                        parent: _heartCtrl,
                        curve: Curves.elasticOut,
                      ),
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF6B9A), Color(0xFF7C7CF8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.5),
                              blurRadius: 30,
                              spreadRadius: 5,
                            ),
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.3),
                              blurRadius: 50,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.favorite_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Logo text ────────────────────────────────────────────────────
            Align(
              alignment: const Alignment(0, 0.38),
              child: FadeTransition(
                opacity: _textCtrl,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.4),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: _textCtrl, curve: Curves.easeOutCubic)),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [Color(0xFFFF6B9A), Color(0xFF7C7CF8)],
                        ).createShader(bounds),
                        child: Text(
                          'DearTeens',
                          style: GoogleFonts.poppins(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Your wellness companion ✨',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Version tag ──────────────────────────────────────────────────
            Align(
              alignment: const Alignment(0, 0.96),
              child: Text(
                'v1.0.0  •  Made with ❤️ for teens',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.white.withOpacity(0.3),
                ),
              ).animate(delay: 1500.ms).fadeIn(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildParticles() {
    final positions = [
      [0.12, 0.1], [0.85, 0.08], [0.05, 0.45], [0.92, 0.38],
      [0.2, 0.78], [0.75, 0.82], [0.5, 0.05], [0.45, 0.92],
      [0.6, 0.55], [0.3, 0.62],
    ];
    final emojis = ['💜', '✨', '🌸', '💫', '⭐', '🎀', '💕', '🌺', '💎', '🦋'];

    return positions.asMap().entries.map((e) {
      final i = e.key;
      final pos = e.value;
      return Positioned(
        left: MediaQuery.of(context).size.width * pos[0],
        top: MediaQuery.of(context).size.height * pos[1],
        child: AnimatedBuilder(
          animation: _particleCtrl,
          builder: (_, __) => Opacity(
            opacity: (0.1 + _particleCtrl.value * 0.25)
                .clamp(0.05, 0.35),
            child: Transform.translate(
              offset: Offset(
                0,
                -8 * (_particleCtrl.value + i * 0.1) * (i.isEven ? 1 : -1),
              ),
              child: Text(
                emojis[i % emojis.length],
                style: TextStyle(fontSize: 14 + (i % 3) * 4.0),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// MAIN SHELL – Premium Bottom Navigation
// ═══════════════════════════════════════════════════════════════════════════════

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late final AnimationController _navCtrl;

  final List<_NavItem> _navItems = const [
    _NavItem(icon: Icons.home_rounded,        label: 'Home',      color: Color(0xFFFF6B9A)),
    _NavItem(icon: Icons.spa_rounded,         label: 'Wellness',  color: Color(0xFF7C7CF8)),
    _NavItem(icon: Icons.psychology_rounded,  label: 'Mood',      color: Color(0xFFE91E63)),
    _NavItem(icon: Icons.insights_rounded,    label: 'Insights',  color: Color(0xFF4CAF50)),
    _NavItem(icon: Icons.person_rounded,      label: 'Profile',   color: Color(0xFFFF9800)),
  ];

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _navCtrl = AnimationController(
      vsync: this,
      duration: 300.ms,
    );

    _screens = const [
      HomeScreen(),
      _WellnessHub(),
      _MoodCenter(),
      _InsightsCenter(),
      _ProfileCenter(),
    ];
  }

  @override
  void dispose() {
    _navCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1A1A2E).withOpacity(0.12),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _navItems.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final selected = _currentIndex == i;
              return _NavButton(
                item: item,
                selected: selected,
                onTap: () {
                  if (_currentIndex != i) {
                    setState(() => _currentIndex = i);
                    HapticFeedback.lightImpact();
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Color color;
  const _NavItem({required this.icon, required this.label, required this.color});
}

class _NavButton extends StatelessWidget {
  final _NavItem item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: 300.ms,
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: selected ? 16 : 12,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: selected ? item.color.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: 300.ms,
              child: Icon(
                item.icon,
                color: selected ? item.color : AppColors.textHint,
                size: selected ? 24 : 22,
              ),
            ),
            AnimatedSize(
              duration: 300.ms,
              curve: Curves.easeOutCubic,
              child: selected
                  ? Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        item.label,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: item.color,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}


// ══════════════════════════════════════════════════════
// Shell Tab Screens (wrappers that navigate to features)
// ══════════════════════════════════════════════════════


/// Wellness Hub tab – quick launcher to all 4 new wellness features
class _WellnessHub extends StatelessWidget {
  const _WellnessHub();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: const Color(0xFF7C7CF8),
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF5E5CE6), Color(0xFF7C7CF8), Color(0xFFAE9EF4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Wellness Hub 🌿',
                            style: GoogleFonts.poppins(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white)),
                        Text('Your personal wellness toolkit',
                            style: GoogleFonts.poppins(
                                fontSize: 13, color: Colors.white70)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _HubCard(
                  title: 'Self-Care Toolkit',
                  subtitle: 'Breathing, meditation & stretching',
                  emoji: '🧘‍♀️',
                  gradient: const [Color(0xFF4ECDC4), Color(0xFF43C6AC)],
                  onTap: () => Navigator.push(context, _slide(const ComfortToolkitScreen())),
                  delay: 0.ms,
                ),
                _HubCard(
                  title: 'Daily Challenges',
                  subtitle: 'Complete goals · Earn points · Build streaks',
                  emoji: '🏆',
                  gradient: const [Color(0xFFFF9800), Color(0xFFFFB74D)],
                  onTap: () => Navigator.push(context, _slide(const DailyChallengesScreen())),
                  delay: 80.ms,
                ),
                _HubCard(
                  title: 'AI Recommendations',
                  subtitle: 'Personalized tips just for you',
                  emoji: '✨',
                  gradient: const [Color(0xFF9C27B0), Color(0xFFCE93D8)],
                  onTap: () => Navigator.push(context, _slide(const AiRecommendationsScreen())),
                  delay: 160.ms,
                ),
                _HubCard(
                  title: 'Knowledge Library',
                  subtitle: 'Safe health education for teens',
                  emoji: '📚',
                  gradient: const [Color(0xFF2196F3), Color(0xFF64B5F6)],
                  onTap: () => Navigator.push(context, _slide(const KnowledgeLibraryScreen())),
                  delay: 240.ms,
                ),
                _HubCard(
                  title: 'Health Timeline',
                  subtitle: 'Your personal wellness journey',
                  emoji: '📋',
                  gradient: const [Color(0xFF00897B), Color(0xFF4DB6AC)],
                  onTap: () => Navigator.push(context, _slide(const HealthTimelineScreen())),
                  delay: 320.ms,
                ),
                _HubCard(
                  title: 'Community',
                  subtitle: 'Connect · Share · Support',
                  emoji: '🤝',
                  gradient: const [Color(0xFFE91E63), Color(0xFFF48FB1)],
                  onTap: () => Navigator.push(context, _slide(const CommunityScreen())),
                  delay: 400.ms,
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

Route _slide(Widget page) => PageRouteBuilder(
      pageBuilder: (_, a, __) => page,
      transitionsBuilder: (_, a, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: 350.ms,
    );

class _HubCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> gradient;
  final VoidCallback onTap;
  final Duration delay;

  const _HubCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.gradient,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_HubCard> createState() => _HubCardState();
}

class _HubCardState extends State<_HubCard> {
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
        scale: _pressed ? 0.97 : 1.0,
        duration: 120.ms,
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          height: 90,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: widget.gradient[0].withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                right: -10, top: -10,
                child: Container(
                  width: 90, height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Text(widget.emoji, style: const TextStyle(fontSize: 34)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.title,
                              style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                          const SizedBox(height: 2),
                          Text(widget.subtitle,
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.white70)),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white70, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 350.ms, delay: widget.delay).slideX(begin: 0.1),
      ),
    );
  }
}

// ── Mood Center tab ───────────────────────────────────────────────────────────
class _MoodCenter extends StatelessWidget {
  const _MoodCenter();
  @override
  Widget build(BuildContext context) => const MoodCompanionScreen();
}

// ── Insights Center tab ───────────────────────────────────────────────────────
class _InsightsCenter extends StatelessWidget {
  const _InsightsCenter();
  @override
  Widget build(BuildContext context) => const HealthInsightsScreen();
}

// ── Profile Center tab ────────────────────────────────────────────────────────
class _ProfileCenter extends StatelessWidget {
  const _ProfileCenter();
  @override
  Widget build(BuildContext context) => const ProfileScreen();
}
