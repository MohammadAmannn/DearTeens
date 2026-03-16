import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

// ─── Timeline Data ─────────────────────────────────────────────────────────────
class TimelineAge {
  final int age;
  final String title;
  final String emoji;
  final Color color;
  final List<String> bodyChanges;
  final List<String> hormoneChanges;
  final List<String> emotionalChanges;
  final String encouragement;

  const TimelineAge({
    required this.age,
    required this.title,
    required this.emoji,
    required this.color,
    required this.bodyChanges,
    required this.hormoneChanges,
    required this.emotionalChanges,
    required this.encouragement,
  });
}

const List<TimelineAge> _timelineData = [
  TimelineAge(
    age: 10,
    title: 'The Beginning',
    emoji: '🌱',
    color: Color(0xFF4CAF50),
    bodyChanges: [
      'Slight growth in height',
      'Body may begin to develop curves',
      'Breast budding may start for some girls',
      'Body shape begins to change gradually',
    ],
    hormoneChanges: [
      'Estrogen levels begin to rise slowly',
      'Pituitary gland starts sending signals',
      'Very early hormonal shifts begin',
    ],
    emotionalChanges: [
      'Growing sense of independence',
      'More interest in peer relationships',
      'Beginning to form own opinions',
      'Still very close to family',
    ],
    encouragement: 'You\'re at the very beginning of an amazing journey. Every change happening is perfectly natural! 🌟',
  ),
  TimelineAge(
    age: 11,
    title: 'Seeds of Change',
    emoji: '🌿',
    color: Color(0xFF26A69A),
    bodyChanges: [
      'Breast development continues for girls',
      'Pubic and underarm hair may appear',
      'Hips may begin to widen',
      'Skin may become oilier',
      'Body odor changes — time for deodorant!',
    ],
    hormoneChanges: [
      'Estrogen production increases',
      'Ovaries grow and become active',
      'Growth hormone surges begin',
    ],
    emotionalChanges: [
      'Stronger friendships develop',
      'Mood swings may start',
      'More self-conscious about appearance',
      'Developing sense of identity',
    ],
    encouragement: 'These changes are signs your body is growing strong and healthy. You\'re doing amazing! 💪',
  ),
  TimelineAge(
    age: 12,
    title: 'Growing Strong',
    emoji: '🌸',
    color: Color(0xFFFF6B9A),
    bodyChanges: [
      'Breast development becomes more noticeable',
      'Growth spurt — you may grow 2-3 inches!',
      'First period may begin (menarche)',
      'Leg and arm hair appears',
      'Feet and hands grow quickly',
    ],
    hormoneChanges: [
      'Menstrual cycle may begin',
      'Estrogen and progesterone cycle starts',
      'Growth hormone at peak',
    ],
    emotionalChanges: [
      'Seeking more independence',
      'Strong peer influence',
      'Romantic feelings may emerge',
      'Increased empathy for others',
    ],
    encouragement: 'Getting your first period is a big milestone! It\'s completely normal and you\'re doing great. 🌸',
  ),
  TimelineAge(
    age: 13,
    title: 'Finding Your Flow',
    emoji: '🦋',
    color: Color(0xFF7C7CF8),
    bodyChanges: [
      'Periods become more regular',
      'Breast development continues',
      'Acne may increase — skincare is key!',
      'Body hair becomes more noticeable',
      'Waist and hip proportions change',
    ],
    hormoneChanges: [
      'Menstrual cycle becomes more predictable',
      'Testosterone contributes to acne',
      'Hormonal fluctuations throughout month',
    ],
    emotionalChanges: [
      'Identity exploration intensifies',
      'May feel misunderstood sometimes',
      'Deeper emotional connections',
      'Social media becomes more important',
    ],
    encouragement: 'Navigating these changes takes courage. Remember, everyone goes through this and you\'re not alone! 💕',
  ),
  TimelineAge(
    age: 14,
    title: 'Building Confidence',
    emoji: '⭐',
    color: Color(0xFFFF9800),
    bodyChanges: [
      'Growth continues but slows slightly',
      'Body contour becomes more defined',
      'Menstrual cycles regulate further',
      'Skin care routines become important',
    ],
    hormoneChanges: [
      'Hormones start to stabilize',
      'Menstrual cycle more predictable',
      'Growth hormone begins to decrease',
    ],
    emotionalChanges: [
      'Greater confidence in identity',
      'More complex thinking skills',
      'Critical of authority sometimes',
      'Stronger values and beliefs forming',
    ],
    encouragement: 'You\'re developing into your authentic self. Your uniqueness is your superpower! ⭐',
  ),
  TimelineAge(
    age: 15,
    title: 'Emerging Self',
    emoji: '🦄',
    color: Color(0xFF9C27B0),
    bodyChanges: [
      'Most girls near adult height',
      'Breast development nearly complete',
      'Body fat distribution stabilizes',
      'Menstrual cycles well-established',
    ],
    hormoneChanges: [
      'Hormonal patterns more consistent',
      'Reproductive system fully developing',
      'Hormonal balance improving',
    ],
    emotionalChanges: [
      'Stronger sense of self',
      'Future thinking and planning',
      'Deeper romantic and social feelings',
      'Managing stress and emotions better',
    ],
    encouragement: 'You\'re becoming the incredible person you\'re meant to be. Your future is so bright! 🌟',
  ),
  TimelineAge(
    age: 16,
    title: 'Coming Into Your Own',
    emoji: '🌺',
    color: Color(0xFFE91E63),
    bodyChanges: [
      'Most physical development complete',
      'Adult body shape established',
      'Skin may improve or stabilize',
      'Menstrual cycle well predictable',
    ],
    hormoneChanges: [
      'Hormones largely stabilized',
      'Reproductive system fully functional',
      'Adult hormone levels established',
    ],
    emotionalChanges: [
      'Solid personal identity forming',
      'Mature decision-making skills',
      'Balancing independence and responsibility',
      'Future planning becomes real',
    ],
    encouragement: 'Look how far you\'ve come! Your confidence and wisdom are growing every day! 🌺',
  ),
  TimelineAge(
    age: 17,
    title: 'Flourishing',
    emoji: '💫',
    color: Color(0xFF2196F3),
    bodyChanges: [
      'Physical growth essentially complete',
      'Adult body fully established',
      'Skin typically clearer than early teens',
      'Full adult energy levels',
    ],
    hormoneChanges: [
      'Hormones fully matured',
      'Menstrual cycle very predictable',
      'Adult reproductive system',
    ],
    emotionalChanges: [
      'Adult-like reasoning abilities',
      'Complex emotions are manageable',
      'Strong relationship skills',
      'Clearer view of life goals',
    ],
    encouragement: 'You\'ve navigated puberty like a champion! These years have shaped who you are. So proud! 💫',
  ),
  TimelineAge(
    age: 18,
    title: 'A New Chapter',
    emoji: '🌟',
    color: Color(0xFF43C6AC),
    bodyChanges: [
      'Adult body fully developed',
      'Physical maturity complete',
      'Metabolism stabilizes',
      'Adult health practices important',
    ],
    hormoneChanges: [
      'Full adult hormonal balance',
      'Monthly cycle well-established',
      'Adult endocrine system',
    ],
    emotionalChanges: [
      'Adult emotional maturity',
      'Clear personal values and goals',
      'Healthy coping mechanisms',
      'Ready for adult responsibilities',
    ],
    encouragement: 'You made it! You\'re a fully-fledged young adult. The world is ready for your amazing contribution! 🌟',
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────
class BodyTimelineScreen extends StatefulWidget {
  const BodyTimelineScreen({Key? key}) : super(key: key);

  @override
  State<BodyTimelineScreen> createState() => _BodyTimelineScreenState();
}

class _BodyTimelineScreenState extends State<BodyTimelineScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _bgController;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentAge = _timelineData[_currentPage];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Animated Header ────────────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  currentAge.color,
                  currentAge.color.withOpacity(0.7),
                  Colors.white,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // AppBar row
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded,
                              color: Colors.white),
                        ),
                        Expanded(
                          child: Text(
                            'Puberty Timeline',
                            style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            'Age ${currentAge.age}',
                            style: GoogleFonts.poppins(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Big emoji + title
                  Padding(
                    padding:
                        const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Row(
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          child: Text(
                            currentAge.emoji,
                            key: ValueKey(currentAge.age),
                            style: const TextStyle(fontSize: 56),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                child: Text(
                                  currentAge.title,
                                  key: ValueKey(currentAge.age),
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Text(
                                'Swipe to explore journey →',
                                style: GoogleFonts.poppins(
                                    fontSize: 12, color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Age slider / indicator dots
                  SizedBox(
                    height: 36,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _timelineData.length,
                      itemBuilder: (context, index) {
                        final isActive = index == _currentPage;
                        return GestureDetector(
                          onTap: () {
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(
                                    isActive ? 0.9 : 0.4),
                              ),
                            ),
                            child: Text(
                              '${_timelineData[index].age}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isActive
                                    ? currentAge.color
                                    : Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),

          // ── PageView ──────────────────────────────────────────────────
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemCount: _timelineData.length,
              itemBuilder: (context, index) {
                final ageData = _timelineData[index];
                return _TimelinePage(ageData: ageData);
              },
            ),
          ),

          // ── Navigation buttons ────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      ),
                      icon: const Icon(Icons.arrow_back_ios_rounded,
                          size: 16),
                      label: Text('Age ${_timelineData[_currentPage - 1].age}',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: currentAge.color,
                        side: BorderSide(color: currentAge.color.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (_currentPage > 0 && _currentPage < _timelineData.length - 1)
                  const SizedBox(width: 12),
                if (_currentPage < _timelineData.length - 1)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _pageController.nextPage(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                      ),
                      icon: Text(_timelineData[_currentPage + 1].emoji,
                          style: const TextStyle(fontSize: 16)),
                      label: Text('Age ${_timelineData[_currentPage + 1].age}',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: currentAge.color,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Timeline Page ─────────────────────────────────────────────────────────────
class _TimelinePage extends StatelessWidget {
  final TimelineAge ageData;

  const _TimelinePage({required this.ageData});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encouragement banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ageData.color.withOpacity(0.12),
                  ageData.color.withOpacity(0.04),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ageData.color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Text(ageData.emoji, style: const TextStyle(fontSize: 32)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    ageData.encouragement,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 20),

          // Body changes
          _SectionCard(
            title: 'Body Changes',
            icon: Icons.accessibility_new_rounded,
            color: ageData.color,
            items: ageData.bodyChanges,
            delay: 0.ms,
          ),

          const SizedBox(height: 14),

          // Hormone changes
          _SectionCard(
            title: 'Hormone Changes',
            icon: Icons.science_rounded,
            color: AppColors.secondary,
            items: ageData.hormoneChanges,
            delay: 100.ms,
          ),

          const SizedBox(height: 14),

          // Emotional changes
          _SectionCard(
            title: 'Emotional Changes',
            icon: Icons.psychology_rounded,
            color: const Color(0xFF9C27B0),
            items: ageData.emotionalChanges,
            delay: 200.ms,
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<String> items;
  final Duration delay;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain,
                  ),
                ),
              ],
            ),
          ),
          // Items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items.asMap().entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
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
                );
              }).toList(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms, delay: delay).slideY(begin: 0.1);
  }
}
