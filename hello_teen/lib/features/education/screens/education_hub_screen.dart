import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import 'topic_detail_screen.dart';

class EducationTopic {
  final String title;
  final String imagePath;
  final String description;
  final List<String> bulletPoints;
  final Color color;
  final IconData icon;
  final List<Map<String, dynamic>> quiz;

  const EducationTopic({
    required this.title,
    required this.imagePath,
    required this.description,
    required this.bulletPoints,
    required this.color,
    required this.icon,
    this.quiz = const [],
  });
}

class EducationHubScreen extends StatelessWidget {
  const EducationHubScreen({Key? key}) : super(key: key);

  static const List<EducationTopic> topics = [
    EducationTopic(
      title: 'Puberty',
      imagePath: 'assets/images/education.png',
      description: 'Understanding the physical and emotional changes during puberty is the first step to feeling comfortable in your own body.',
      color: Color(0xFFFF6B9A),
      icon: Icons.child_care_rounded,
      bulletPoints: [
        '🌱 Body changes: growth spurts, acne, body hair are all totally normal.',
        '🧠 Hormonal changes lead to mood swings and new feelings.',
        '💪 Developing a healthy body image and self-confidence.',
        '✅ Why these changes are completely normal and part of growing up.',
      ],
      quiz: [
        {'q': 'At what age does puberty typically begin for girls?', 'options': ['6-8 years', '8-13 years', '15-17 years', '18+ years'], 'answer': 1},
        {'q': 'Which hormone is mainly responsible for puberty in girls?', 'options': ['Testosterone', 'Estrogen', 'Insulin', 'Adrenaline'], 'answer': 1},
        {'q': 'Is it normal for puberty to start at different ages?', 'options': ['No, all teens start at the same age', 'Yes, it varies for everyone', 'Only if there is a health problem', 'It depends on diet only'], 'answer': 1},
      ],
    ),
    EducationTopic(
      title: 'Menstrual Health',
      imagePath: 'assets/images/period_tracker.png',
      description: 'A comprehensive guide to understanding your menstrual cycle, managing symptoms, and practicing good hygiene.',
      color: Color(0xFFE91E63),
      icon: Icons.water_drop_rounded,
      bulletPoints: [
        '🌊 What is a period and why does it happen each month.',
        '📅 Understanding the 4 phases of your menstrual cycle.',
        '🌸 How to use pads, tampons, or menstrual cups safely.',
        '💊 Managing cramps and PMS symptoms effectively.',
        '🏃‍♀️ Exercise during your period is usually beneficial!',
      ],
      quiz: [
        {'q': 'How many phases does the menstrual cycle have?', 'options': ['2', '3', '4', '5'], 'answer': 2},
        {'q': 'What is the average length of a menstrual cycle?', 'options': ['14 days', '21-35 days', '45 days', '60 days'], 'answer': 1},
        {'q': 'Can you exercise during your period?', 'options': ['Never', 'Only light exercise', 'Yes, it can help with cramps', 'Only yoga'], 'answer': 2},
      ],
    ),
    EducationTopic(
      title: 'Hygiene',
      imagePath: 'assets/images/ai_assistant.png',
      description: 'As your body changes, your hygiene needs change too. Learn how to take care of yourself daily with expert tips.',
      color: Color(0xFF7C7CF8),
      icon: Icons.soap_rounded,
      bulletPoints: [
        '🚿 Daily showers and the right deodorant make a big difference.',
        '✨ Skincare basics for acne-prone teenage skin.',
        '🦷 Dental hygiene and maintaining fresh breath.',
        '🌿 Proper intimate hygiene: gentle, unscented products only.',
        '👚 Changing clothes and washing them regularly matters!',
      ],
      quiz: [
        {'q': 'How often should teenagers shower?', 'options': ['Once a week', 'Every other day minimum', 'Daily is recommended', 'Monthly'], 'answer': 2},
        {'q': 'What causes acne during puberty?', 'options': ['Eating too much sugar', 'Hormones and bacteria in pores', 'Not washing face enough', 'Using sunscreen'], 'answer': 1},
      ],
    ),
    EducationTopic(
      title: 'Nutrition',
      imagePath: 'assets/images/health_insights.png',
      description: 'What you eat impacts your growth, energy levels, and mood. Discover how to fuel your body the right way.',
      color: Color(0xFF4CAF50),
      icon: Icons.restaurant_rounded,
      bulletPoints: [
        '🥦 Balancing proteins, carbs, and healthy fats for growth.',
        '💧 Importance of hydration — drink 8+ glasses of water daily!',
        '🍎 Healthy snacking: fruits, nuts, yogurt are great choices.',
        '🩺 Food that supports menstrual health (iron, magnesium).',
        '🚫 Avoid: excessive sugar, processed foods, and crash diets.',
      ],
      quiz: [
        {'q': 'How many glasses of water should teens drink daily?', 'options': ['2-3', '4-5', '8+', '1-2'], 'answer': 2},
        {'q': 'Which nutrient is especially important during menstruation?', 'options': ['Vitamin C', 'Iron', 'Calcium', 'Protein'], 'answer': 1},
        {'q': 'Is skipping breakfast a good idea for teens?', 'options': ['Yes, saves calories', 'No, breakfast supports brain function', 'Only on weekdays', 'Depends on the person'], 'answer': 1},
      ],
    ),
    EducationTopic(
      title: 'Emotional Health',
      imagePath: 'assets/images/mental_health.png',
      description: 'Your mind matters just as much as your body. Learn strategies to cope with stress, anxiety, and big emotions.',
      color: Color(0xFF9C27B0),
      icon: Icons.psychology_rounded,
      bulletPoints: [
        '🧠 Recognizing signs of stress, anxiety, and burnout.',
        '📓 Healthy coping: journaling, exercise, creative outlets.',
        '😴 The importance of 8-9 hours of sleep each night.',
        '🤝 When and how to seek help from a trusted adult.',
        '💬 Talking about feelings is a sign of strength, not weakness!',
      ],
      quiz: [
        {'q': 'How many hours of sleep do teens need per night?', 'options': ['5-6', '6-7', '8-10', '12+'], 'answer': 2},
        {'q': 'Which is a healthy way to cope with stress?', 'options': ['Avoiding all activities', 'Journaling or exercising', 'Ignoring all problems', 'Staying up all night'], 'answer': 1},
        {'q': 'Asking for mental health help means you are:', 'options': ['Weak', 'Strong and self-aware', 'Broken', 'Overreacting'], 'answer': 1},
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFE91E8C), AppColors.primary, Color(0xFFFF8CB8)],
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
                            Text('Education Hub 📚',
                                style: GoogleFonts.poppins(
                                    fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('Learn at your own pace',
                                style: GoogleFonts.poppins(fontSize: 13, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Text(
                '${topics.length} Topics Available',
                style: GoogleFonts.poppins(
                    fontSize: 14, color: AppColors.textLight),
              ).animate().fadeIn(),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final topic = topics[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: _TopicCard(topic: topic, delay: (index * 100).ms),
                );
              },
              childCount: topics.length,
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------
// Topic Card
// -----------------------------------------------------------------------
class _TopicCard extends StatefulWidget {
  final EducationTopic topic;
  final Duration delay;

  const _TopicCard({required this.topic, required this.delay});

  @override
  State<_TopicCard> createState() => _TopicCardState();
}

class _TopicCardState extends State<_TopicCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TopicDetailScreen(topic: widget.topic)),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
                color: widget.topic.color.withOpacity(0.18), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.topic.color.withOpacity(0.12),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left gradient panel
              Container(
                width: 90,
                height: 108,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.topic.color.withOpacity(0.18),
                      widget.topic.color.withOpacity(0.06),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(22),
                    bottomLeft: Radius.circular(22),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.topic.icon, color: widget.topic.color, size: 36),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: widget.topic.color.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${widget.topic.quiz.length} Q',
                        style: GoogleFonts.poppins(
                            fontSize: 9,
                            color: widget.topic.color,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.topic.title,
                        style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.topic.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                            height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(Icons.menu_book_rounded,
                              size: 13, color: widget.topic.color),
                          const SizedBox(width: 4),
                          Text('${widget.topic.bulletPoints.length} lessons',
                              style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: widget.topic.color,
                                  fontWeight: FontWeight.w600)),
                          const Spacer(),
                          Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: widget.topic.color.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.arrow_forward_ios_rounded,
                                size: 13, color: widget.topic.color),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms, delay: widget.delay).slideY(begin: 0.1),
      ),
    );
  }
}
