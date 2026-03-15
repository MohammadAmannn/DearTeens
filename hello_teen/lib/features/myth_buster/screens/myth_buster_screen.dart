import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class MythFactPair {
  final String myth;
  final String fact;
  final String category;
  final Color color;

  const MythFactPair(this.myth, this.fact,
      {this.category = 'Health', this.color = AppColors.warning});
}

class MythBusterScreen extends StatefulWidget {
  const MythBusterScreen({Key? key}) : super(key: key);

  @override
  State<MythBusterScreen> createState() => _MythBusterScreenState();
}

class _MythBusterScreenState extends State<MythBusterScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;
  final Map<int, bool> _flippedCards = {};

  static const List<MythFactPair> pairs = [
    MythFactPair('Girls should not enter the kitchen or touch holy items during periods.',
        'Menstruation is a completely natural biological process. It does not make a person impure or dirty in any way.',
        category: 'Menstrual Health', color: Color(0xFFE91E63)),
    MythFactPair('Shaving makes body hair grow back thicker and darker.',
        'Shaving cuts the hair at the surface, giving it a blunt tip which may feel coarse, but it does NOT change its thickness or color.',
        category: 'Hygiene', color: AppColors.secondary),
    MythFactPair('Eating chocolate or greasy foods directly causes acne.',
        'Acne is primarily caused by hormones, genetics, and bacteria. A balanced diet helps overall skin health, but no single food directly causes acne.',
        category: 'Nutrition', color: AppColors.success),
    MythFactPair('Only girls go through emotional changes during puberty.',
        'Boys also experience significant hormonal shifts during puberty that cause mood swings, irritability, and strong emotions — just like girls.',
        category: 'Puberty', color: AppColors.primary),
    MythFactPair('You can\'t swim or play sports on your period.',
        'Exercise can actually help relieve cramps! Using a tampon or menstrual cup makes swimming completely safe and sanitary.',
        category: 'Menstrual Health', color: Color(0xFFE91E63)),
    MythFactPair('If you have a wet dream, there is something wrong with you.',
        'Wet dreams are completely normal and healthy during male puberty as the body begins producing testosterone and sperm.',
        category: 'Puberty', color: AppColors.primary),
    MythFactPair('Using deodorant causes breast cancer.',
        'Extensive research has found NO direct link between the use of antiperspirants or deodorants and breast cancer risk.',
        category: 'Hygiene', color: AppColors.secondary),
    MythFactPair('Periods should always be exactly 28 days apart.',
        'A normal cycle can range from 21 to 35 days. It\'s especially common for teenagers to have irregular cycles in their first few years.',
        category: 'Menstrual Health', color: Color(0xFFE91E63)),
    MythFactPair('Mental health issues like anxiety are just "phases" teens go through.',
        'Clinical anxiety and depression are real medical conditions that require understanding and sometimes professional help — not dismissal.',
        category: 'Mental Health', color: Color(0xFF9C27B0)),
    MythFactPair('Skipping meals is a good way to lose weight quickly.',
        'Skipping meals slows your metabolism and deprives your growing brain and body of essential nutrients. Balanced meals are key.',
        category: 'Nutrition', color: AppColors.success),
    MythFactPair('You only need to wear sunscreen when it is sunny outside.',
        'UV rays can damage your skin even on cloudy, rainy, or snowy days. Daily SPF application is always recommended.',
        category: 'Hygiene', color: AppColors.secondary),
    MythFactPair('Asking for help means you are weak.',
        'Reaching out to a counselor, parent, or doctor when you\'re struggling is a sign of strength and self-awareness.',
        category: 'Mental Health', color: Color(0xFF9C27B0)),
    MythFactPair('Boys stop growing at 16, and girls stop at 14.',
        'Everyone develops at their own pace. Men can continue growing into their early twenties, and women into their late teens.',
        category: 'Puberty', color: AppColors.primary),
    MythFactPair('Pads and tampons are the only ways to manage a period.',
        'There are many options today including menstrual cups, period underwear, and reusable cloth pads to suit your comfort and lifestyle.',
        category: 'Menstrual Health', color: Color(0xFFE91E63)),
    MythFactPair('You can "catch up" on sleep by sleeping extra on weekends.',
        'Irregular sleep patterns disrupt your body clock. Consistent sleep schedules are far more beneficial for teen health.',
        category: 'Mental Health', color: Color(0xFF9C27B0)),
    MythFactPair('Acne means you have bad hygiene.',
        'Acne is caused by hormones, genetics, and bacteria inside pores — not surface dirt. Over-washing can actually irritate skin more.',
        category: 'Hygiene', color: AppColors.secondary),
    MythFactPair('Cramps during periods are just an excuse to avoid activities.',
        'Period cramps (dysmenorrhea) are caused by real uterine contractions and can range from mild to severely painful. They\'re medically recognized.',
        category: 'Menstrual Health', color: Color(0xFFE91E63)),
    MythFactPair('If you\'re thin, you must be healthy.',
        'Health is about physical, mental, and nutritional wellbeing — not just body weight or size. Eating disorders can affect people of all sizes.',
        category: 'Nutrition', color: AppColors.success),
    MythFactPair('Hair loss during a shower means you are going bald.',
        'It\'s completely normal to lose 50-100 hairs per day as part of the natural hair growth cycle. Hormonal changes during puberty can slightly increase this.',
        category: 'Puberty', color: AppColors.primary),
    MythFactPair('Talking about your feelings makes problems worse.',
        'Research consistently shows that expressing emotions and talking through problems reduces anxiety and improves mental health outcomes for teens.',
        category: 'Mental Health', color: Color(0xFF9C27B0)),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const NeverScrollableScrollPhysics(),
        slivers: [
          // ── AppBar ───────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: AppColors.warning,
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF6D00), Color(0xFFFF9800)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(top: -30, right: -30,
                        child: _decCircle(180, Colors.white.withOpacity(0.06))),
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Myth vs Fact 💡',
                                style: GoogleFonts.poppins(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            Text('Swipe to learn the truth!',
                                style: GoogleFonts.poppins(
                                    fontSize: 13, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Counter & Category ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Progress bar
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_currentIndex + 1} of ${pairs.length}',
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: (_currentIndex + 1) / pairs.length,
                            backgroundColor: AppColors.cardBorder,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                pairs[_currentIndex].color),
                            minHeight: 5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: pairs[_currentIndex].color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: pairs[_currentIndex].color.withOpacity(0.3)),
                    ),
                    child: Text(
                      pairs[_currentIndex].category,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: pairs[_currentIndex].color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Card PageView ─────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: screenHeight * 0.56,
              child: PageView.builder(
                controller: _pageController,
                itemCount: pairs.length,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final pair = pairs[index];
                  final isFlipped = _flippedCards[index] ?? false;
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
                    child: _MythCard(
                      pair: pair,
                      isFlipped: isFlipped,
                      onTap: () =>
                          setState(() => _flippedCards[index] = !isFlipped),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Navigation ────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _NavButton(
                    icon: Icons.arrow_back_ios_rounded,
                    color: _currentIndex > 0
                        ? AppColors.warning
                        : AppColors.cardBorder,
                    onTap: _currentIndex > 0
                        ? () => _pageController.previousPage(
                            duration: 350.ms, curve: Curves.easeInOut)
                        : null,
                  ),
                  Text(
                    'Swipe to navigate',
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: AppColors.textLight),
                  ),
                  _NavButton(
                    icon: Icons.arrow_forward_ios_rounded,
                    color: _currentIndex < pairs.length - 1
                        ? AppColors.warning
                        : AppColors.cardBorder,
                    onTap: _currentIndex < pairs.length - 1
                        ? () => _pageController.nextPage(
                            duration: 350.ms, curve: Curves.easeInOut)
                        : null,
                  ),
                ],
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }

  Widget _decCircle(double size, Color color) =>
      Container(width: size, height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color));
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav Button
// ─────────────────────────────────────────────────────────────────────────────
class _NavButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _NavButton({required this.icon, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: onTap != null ? color.withOpacity(0.12) : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.4)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Myth Card
// ─────────────────────────────────────────────────────────────────────────────
class _MythCard extends StatelessWidget {
  final MythFactPair pair;
  final bool isFlipped;
  final VoidCallback onTap;

  const _MythCard(
      {required this.pair, required this.isFlipped, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final factColor = AppColors.success;
    final cardColor = isFlipped ? factColor : pair.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isFlipped
                ? [const Color(0xFFE8F5E9), const Color(0xFFF1F8E9)]
                : [
                    pair.color.withOpacity(0.08),
                    pair.color.withOpacity(0.03),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: cardColor.withOpacity(0.35),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: cardColor.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 10),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isFlipped
                        ? [AppColors.success, const Color(0xFF43C6AC)]
                        : [pair.color, pair.color.withOpacity(0.75)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: cardColor.withOpacity(0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isFlipped
                          ? Icons.check_circle_rounded
                          : Icons.help_outline_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isFlipped ? 'FACT ✓' : 'MYTH ✗',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Card Text
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: Text(
                  isFlipped ? pair.fact : pair.myth,
                  key: ValueKey(isFlipped),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: isFlipped
                        ? const Color(0xFF1B5E20)
                        : AppColors.textMain,
                    height: 1.55,
                  ),
                ),
              ),

              const Spacer(),

              // Hint
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app_rounded,
                        color: cardColor.withOpacity(0.7), size: 16),
                    const SizedBox(width: 6),
                    Text(
                      isFlipped ? 'Tap to see myth' : 'Tap to reveal fact',
                      style: GoogleFonts.poppins(
                        color: cardColor.withOpacity(0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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
