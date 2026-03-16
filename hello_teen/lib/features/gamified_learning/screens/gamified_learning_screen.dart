import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';

// ─── Data Models ──────────────────────────────────────────────────────────────
class LearningLevel {
  final int level;
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final List<LearningLesson> lessons;
  final String badgeLabel;

  const LearningLevel({
    required this.level,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.lessons,
    required this.badgeLabel,
  });
}

class LearningLesson {
  final String title;
  final String content;
  final String emoji;
  final int points;
  final List<QuizQuestion> quiz;

  const LearningLesson({
    required this.title,
    required this.content,
    required this.emoji,
    required this.points,
    required this.quiz,
  });
}

class QuizQuestion {
  final String question;
  final List<String> options;
  final int correctIndex;

  const QuizQuestion({
    required this.question,
    required this.options,
    required this.correctIndex,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Curriculum Data
// ─────────────────────────────────────────────────────────────────────────────
final List<LearningLevel> _levels = [
  LearningLevel(
    level: 1,
    title: 'Understanding Puberty',
    subtitle: 'The basics of body changes',
    emoji: '🌱',
    color: const Color(0xFF4CAF50),
    badgeLabel: 'Puberty Explorer',
    lessons: const [
      LearningLesson(
        title: 'What is Puberty?',
        emoji: '🔬',
        points: 50,
        content: '''Puberty is the natural process where your body transitions from a child\'s body to an adult body.

It\'s driven by hormones — chemical messengers in your blood — that signal your body to start making changes.

**When does it happen?**
For girls, puberty typically begins between ages 8-13. For boys, it usually starts between 9-14.

**Key hormones involved:**
• Estrogen — the main female hormone
• Progesterone — important for the menstrual cycle
• Testosterone — present in all genders

Remember: Every person\'s timeline is unique and that\'s perfectly normal! 🌟''',
        quiz: [
          QuizQuestion(
            question: 'What triggers the changes of puberty?',
            options: ['Diet changes', 'Hormones', 'Exercise', 'Age alone'],
            correctIndex: 1,
          ),
          QuizQuestion(
            question: 'When does puberty typically begin for girls?',
            options: ['5-7 years', '8-13 years', '15-17 years', '18+ years'],
            correctIndex: 1,
          ),
        ],
      ),
      LearningLesson(
        title: 'Physical Changes',
        emoji: '💪',
        points: 60,
        content: '''During puberty, your body goes through many exciting physical changes!

**Common changes for all teens:**
• Growth spurts — you may grow several inches in a year
• Body hair appears in new places
• Skin becomes oilier (hello, acne!)
• Body odor changes — deodorant becomes important
• Sweat glands become more active

**For girls specifically:**
• Breasts develop (this can start as early as 8!)
• Hips widen to create an adult body shape
• Pubic and underarm hair appears
• Menstruation (periods) begins

All of these changes are completely normal signs that your body is growing and maturing. 💕''',
        quiz: [
          QuizQuestion(
            question: 'What causes acne during puberty?',
            options: ['Too much sugar', 'Hormones making skin oilier', 'Not washing enough', 'Stress only'],
            correctIndex: 1,
          ),
        ],
      ),
      LearningLesson(
        title: 'Emotional Changes',
        emoji: '🧠',
        points: 55,
        content: '''Puberty doesn\'t just change your body — it changes your brain too!

**Why emotions feel bigger:**
Your brain is literally rewiring itself during puberty. The prefrontal cortex (decision-making center) is still developing, while the emotional center (amygdala) is very active.

**Common emotional experiences:**
• Mood swings that feel intense
• Greater self-consciousness
• Stronger peer influence
• Developing romantic feelings
• Questioning your identity

**Healthy coping strategies:**
• Journaling your feelings
• Talking to trusted adults
• Exercise and creative outlets
• Getting enough sleep (8-9 hours!)

Your feelings are completely valid! 💙''',
        quiz: [
          QuizQuestion(
            question: 'Why do mood swings happen during puberty?',
            options: ['Pure bad behaviour', 'Brain rewiring + hormones', 'Just teenage drama', 'Only if sick'],
            correctIndex: 1,
          ),
        ],
      ),
    ],
  ),
  LearningLevel(
    level: 2,
    title: 'Menstrual Health',
    subtitle: 'Understanding your cycle',
    emoji: '🌸',
    color: const Color(0xFFE91E63),
    badgeLabel: 'Cycle Champion',
    lessons: const [
      LearningLesson(
        title: 'Your Menstrual Cycle',
        emoji: '🔄',
        points: 70,
        content: '''Your menstrual cycle is a monthly process your body goes through to prepare for a possible pregnancy.

**The 4 phases:**
1. **Menstrual Phase (Days 1-5):** Your uterus sheds its lining — this is your period!
2. **Follicular Phase (Days 6-13):** Your body prepares an egg. Energy rises!
3. **Ovulation (Day 14):** An egg is released. You\'re at peak energy.
4. **Luteal Phase (Days 15-28):** If no pregnancy, the lining prepares to shed again.

**Average cycle length:** 21-35 days (28 days is just average!)

**Normal period duration:** 2-7 days

It\'s completely normal for cycles to be irregular at first — it can take 1-2 years to regulate. 🌊''',
        quiz: [
          QuizQuestion(
            question: 'How many phases does the menstrual cycle have?',
            options: ['2', '3', '4', '5'],
            correctIndex: 2,
          ),
          QuizQuestion(
            question: 'What is the average menstrual cycle length?',
            options: ['14 days', '21-35 days', '45 days', '7 days'],
            correctIndex: 1,
          ),
        ],
      ),
      LearningLesson(
        title: 'Managing Symptoms',
        emoji: '💊',
        points: 65,
        content: '''Period symptoms are real and manageable! Here\'s your guide:

**Common symptoms:**
• Cramps (dysmenorrhea) — most common
• Bloating and water retention
• Breast tenderness
• Mood changes (PMS)
• Lower back pain
• Fatigue

**Natural relief methods:**
🔥 **Heat therapy:** Warm pad on lower belly
🏃 **Exercise:** Gentle movement helps cramps
💧 **Hydration:** Warm water and herbal teas
🧘 **Yoga:** Child\'s pose, cat-cow are great
😴 **Rest:** Honor your body\'s need for sleep
🥗 **Diet:** Reduce salt, increase iron & magnesium

**When to see a doctor:**
• Very heavy bleeding (soaking through pads hourly)
• Severe pain that stops you from daily activities
• No period after 16 years of age

You deserve to feel comfortable! 💕''',
        quiz: [
          QuizQuestion(
            question: 'What\'s a natural way to relieve period cramps?',
            options: ['Eat more sugar', 'Apply heat and gentle exercise', 'Stay in bed all week', 'Take any pill you find'],
            correctIndex: 1,
          ),
        ],
      ),
      LearningLesson(
        title: 'Period Products Guide',
        emoji: '🛡️',
        points: 60,
        content: '''There are many period product options — find what works best for you!

**Pads/Sanitary napkins:**
• Stick to the outside of underwear
• Available in different sizes and absorbencies
• Best for beginners
• Change every 4-6 hours

**Tampons:**
• Inserted into the vagina
• Can be worn during swimming!
• Change every 4-8 hours (never more than 8!)
• Start with the smallest size

**Menstrual Cups:**
• Reusable silicone cup
• Eco-friendly and cost-effective
• Can be worn up to 12 hours
• Requires practice to insert correctly

**Period Underwear:**
• Looks like regular underwear
• Has absorbent layers built in
• Reusable and eco-friendly
• Great as backup protection

Experiment to find your perfect combination! 🌸''',
        quiz: [
          QuizQuestion(
            question: 'How long can a tampon be safely worn?',
            options: ['24 hours', 'All day, no limit', 'Up to 8 hours', '2 hours'],
            correctIndex: 2,
          ),
        ],
      ),
    ],
  ),
  LearningLevel(
    level: 3,
    title: 'Emotional Wellness',
    subtitle: 'Mind & mental health mastery',
    emoji: '💜',
    color: const Color(0xFF7C7CF8),
    badgeLabel: 'Wellness Warrior',
    lessons: const [
      LearningLesson(
        title: 'Understanding Emotions',
        emoji: '❤️',
        points: 60,
        content: '''Emotions are messages from your body — let\'s learn to understand them!

**The emotion wheel has core emotions:**
❤️ **Joy** → Contentment, Gratitude, Excitement
💙 **Sadness** → Grief, Disappointment, Loneliness
💛 **Fear** → Anxiety, Worry, Insecurity
🧡 **Anger** → Frustration, Irritability, Resentment
💚 **Surprise** → Shock, Amazement, Confusion
💜 **Disgust** → Aversion, Repulsion, Discomfort

**Why emotions happen:**
They\'re evolutionary signals to guide your behavior!

**Healthy vs. unhealthy expression:**
✅ Journaling, talking, exercise, creative arts
❌ Bottling up, explosive outbursts, self-harm

**Emotional intelligence skills:**
1. Name the emotion
2. Locate it in your body
3. Understand the trigger
4. Choose a healthy response

You are the author of your emotional story! 🌟''',
        quiz: [
          QuizQuestion(
            question: 'What\'s a healthy way to express anger?',
            options: ['Shout at someone', 'Journal about it or exercise', 'Bottle it up forever', 'Ignore it'],
            correctIndex: 1,
          ),
        ],
      ),
      LearningLesson(
        title: 'Stress & Anxiety',
        emoji: '🧘',
        points: 70,
        content: '''Stress and anxiety are normal — but managing them is a superpower!

**What is stress?**
Your body\'s response to perceived threats. During stress, cortisol and adrenaline are released.

**Signs of healthy stress:**
• Motivates you to study before a test
• Helps you prepare for presentations
• Temporary and situation-specific

**Signs of unhealthy stress:**
• Constant worry even when things are fine
• Physical symptoms: headaches, stomach aches
• Difficulty sleeping or concentrating
• Avoiding activities you used to enjoy

**5 evidence-based coping strategies:**
1. **Box breathing:** 4-4-4-4 pattern
2. **Progressive muscle relaxation**
3. **Mindfulness:** 5 senses grounding
4. **Physical activity:** 30 min walk
5. **Social connection:** Talk to someone

When to seek help: If anxiety is affecting your daily life, please talk to a trusted adult or counselor. That takes real courage! 💪''',
        quiz: [
          QuizQuestion(
            question: 'Which is a healthy coping strategy for stress?',
            options: ['Avoiding all social contact', 'Box breathing and exercise', 'Staying up all night', 'Eating unhealthy food'],
            correctIndex: 1,
          ),
        ],
      ),
    ],
  ),
  LearningLevel(
    level: 4,
    title: 'Body Confidence',
    subtitle: 'Love the skin you\'re in',
    emoji: '💪',
    color: const Color(0xFFFF9800),
    badgeLabel: 'Confidence Queen',
    lessons: const [
      LearningLesson(
        title: 'Body Image & Self-Love',
        emoji: '🪞',
        points: 75,
        content: '''Your body is amazing — and you deserve to feel that way!

**What is body image?**
How you see, think, and feel about your body. It\'s shaped by:
• Media and social media
• Peer comments
• Family messages
• Cultural standards

**The truth about media:**
99% of images are digitally edited. The "perfect" body doesn\'t exist!

**Signs of positive body image:**
• Appreciating what your body CAN do
• Not spending excessive time on appearance
• Eating based on hunger, not guilt
• Moving your body for joy, not punishment

**Building body confidence:**
❤️ Focus on function, not appearance
🧴 Care for your body with good hygiene
👗 Wear clothes that make you feel great
📱 Curate your social media feed
📝 Write body appreciation lists

**Affirmation:** \"My worth is not determined by my appearance. I am so much more than my body!\" 💎''',
        quiz: [
          QuizQuestion(
            question: 'What percentage of media images are digitally edited?',
            options: ['About 10%', 'Almost none', 'About 50%', 'The vast majority'],
            correctIndex: 3,
          ),
        ],
      ),
      LearningLesson(
        title: 'Nutrition & Teen Health',
        emoji: '🥗',
        points: 65,
        content: '''Fuel your body right — it\'s doing incredible work!

**Why nutrition matters now:**
Your body is building 90% of your bone density during teen years! What you eat now shapes your future health.

**Key nutrients for teens:**
🦴 **Calcium:** 1300mg/day (dairy, leafy greens, fortified foods)
🩸 **Iron:** Especially important during periods (meat, beans, spinach)
☀️ **Vitamin D:** Bone health (sunlight, fortified milk)
🧠 **Omega-3:** Brain health (fish, flaxseeds, walnuts)
💊 **Folate:** Cell growth (leafy greens, legumes)

**The teen hunger cues:**
During growth spurts, you may eat more — that\'s completely normal!

**Red flags to avoid:**
❌ Skipping meals (slows metabolism + energy)
❌ Extreme diets (dangerous for growing bodies)
❌ Diet pills or supplements without doctor advice
❌ Eating based on emotions alone

**Simple daily goal:**
Eat the rainbow! Each color vegetable/fruit gives different nutrients. 🌈''',
        quiz: [
          QuizQuestion(
            question: 'Which nutrient is especially critical during menstruation?',
            options: ['Vitamin C', 'Iron', 'Vitamin A', 'Protein only'],
            correctIndex: 1,
          ),
        ],
      ),
    ],
  ),
];

// ─── Provider ─────────────────────────────────────────────────────────────────
final learningProgressProvider =
    NotifierProvider<LearningProgressNotifier, Map<String, bool>>(() {
  return LearningProgressNotifier();
});

class LearningProgressNotifier extends Notifier<Map<String, bool>> {
  @override
  Map<String, bool> build() {
    _load();
    return {};
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('lesson_')).toSet();
    final progress = <String, bool>{};
    for (final key in keys) {
      progress[key] = prefs.getBool(key) ?? false;
    }
    state = progress;
  }

  Future<void> completeLesson(String lessonKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(lessonKey, true);
    state = {...state, lessonKey: true};
  }

  int get totalPoints {
    int points = 0;
    for (final level in _levels) {
      for (final lesson in level.lessons) {
        final key = 'lesson_${level.level}_${lesson.title}';
        if (state[key] == true) points += lesson.points;
      }
    }
    return points;
  }

  int get completedLessons => state.values.where((v) => v).length;
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class GamifiedLearningScreen extends ConsumerWidget {
  const GamifiedLearningScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(learningProgressProvider);
    final notifier = ref.read(learningProgressProvider.notifier);

    int totalLessons = _levels.fold(0, (sum, l) => sum + l.lessons.length);
    int completedCount = notifier.completedLessons;
    int totalPoints = notifier.totalPoints;
    double overallProgress = totalLessons > 0 ? completedCount / totalLessons : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF5C35F5),
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4527A0), Color(0xFF7C7CF8), Color(0xFFAA9FF8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -30, right: -30,
                      child: Container(
                        width: 200, height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.06),
                        ),
                      ),
                    ),
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Learning Journey 📚',
                                        style: GoogleFonts.poppins(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    Text('Unlock knowledge, earn badges!',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12,
                                            color: Colors.white70)),
                                  ],
                                ),
                                const Spacer(),
                                // XP Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color:
                                            Colors.white.withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Text('⭐',
                                          style: TextStyle(fontSize: 16)),
                                      const SizedBox(width: 6),
                                      Text('$totalPoints XP',
                                          style: GoogleFonts.poppins(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Overall progress
                            Text(
                              '$completedCount of $totalLessons lessons completed',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Stack(
                              children: [
                                Container(
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: overallProgress,
                                  child: Container(
                                    height: 10,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withOpacity(0.6),
                                          blurRadius: 6,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ).animate().slideX(begin: -1, end: 0, duration: 800.ms, curve: Curves.easeOut),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Badges Row ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Text(
                    'Your Badges',
                    style: GoogleFonts.poppins(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain),
                  ),
                ),
                SizedBox(
                  height: 90,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    itemCount: _levels.length,
                    itemBuilder: (context, index) {
                      final level = _levels[index];
                      final levelCompleted = level.lessons.every((lesson) {
                        final key = 'lesson_${level.level}_${lesson.title}';
                        return progress[key] == true;
                      });
                      return _BadgeChip(
                        label: level.badgeLabel,
                        emoji: level.emoji,
                        color: level.color,
                        isEarned: levelCompleted,
                        delay: (index * 100).ms,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Levels ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
              child: Text(
                'Learning Levels',
                style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain),
              ),
            ),
          ),

          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final level = _levels[index];
                final completedInLevel = level.lessons
                    .where((l) =>
                        progress['lesson_${level.level}_${l.title}'] ==
                        true)
                    .length;
                final levelProgress =
                    completedInLevel / level.lessons.length;
                final isUnlocked = index == 0 ||
                    _levels[index - 1].lessons.every((l) =>
                        progress['lesson_${_levels[index - 1].level}_${l.title}'] ==
                        true);

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: _LevelCard(
                    level: level,
                    progress: levelProgress,
                    isUnlocked: isUnlocked,
                    completedCount: completedInLevel,
                    onTap: isUnlocked
                        ? () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _LevelDetailScreen(
                                    level: level, progressMap: progress),
                              ),
                            ).then((_) => ref.invalidate(learningProgressProvider))
                        : null,
                    delay: (index * 100).ms,
                  ),
                );
              },
              childCount: _levels.length,
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }
}

// ─── Badge Chip ───────────────────────────────────────────────────────────────
class _BadgeChip extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final bool isEarned;
  final Duration delay;

  const _BadgeChip({
    required this.label,
    required this.emoji,
    required this.color,
    required this.isEarned,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: isEarned ? color.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEarned ? color.withOpacity(0.3) : AppColors.cardBorder,
          width: 1.5,
        ),
        boxShadow: isEarned
            ? [BoxShadow(color: color.withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: isEarned ? 1.1 : 0.85,
            duration: const Duration(milliseconds: 300),
            child: Text(
              isEarned ? emoji : '🔒',
              style: TextStyle(
                fontSize: isEarned ? 30 : 24,
                color: isEarned ? null : AppColors.textHint,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.poppins(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isEarned ? color : AppColors.textHint,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: delay).scale(begin: const Offset(0.8, 0.8));
  }
}

// ─── Level Card ───────────────────────────────────────────────────────────────
class _LevelCard extends StatefulWidget {
  final LearningLevel level;
  final double progress;
  final bool isUnlocked;
  final int completedCount;
  final VoidCallback? onTap;
  final Duration delay;

  const _LevelCard({
    required this.level,
    required this.progress,
    required this.isUnlocked,
    required this.completedCount,
    required this.onTap,
    required this.delay,
  });

  @override
  State<_LevelCard> createState() => _LevelCardState();
}

class _LevelCardState extends State<_LevelCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isComplete = widget.progress >= 1.0;

    return GestureDetector(
      onTapDown: widget.isUnlocked ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.isUnlocked
          ? (_) {
              setState(() => _pressed = false);
              widget.onTap?.call();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Opacity(
          opacity: widget.isUnlocked ? 1.0 : 0.55,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: widget.level.color.withOpacity(0.2),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.level.color.withOpacity(0.1),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Card header
                Container(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.level.color.withOpacity(0.2),
                              widget.level.color.withOpacity(0.06),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(widget.level.emoji,
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
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: widget.level.color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'LEVEL ${widget.level.level}',
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: widget.level.color,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.level.title,
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textMain,
                              ),
                            ),
                            Text(
                              widget.level.subtitle,
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: AppColors.textLight),
                            ),
                          ],
                        ),
                      ),
                      if (isComplete)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check_circle_rounded,
                              color: AppColors.success, size: 22),
                        )
                      else if (!widget.isUnlocked)
                        const Icon(Icons.lock_rounded,
                            color: AppColors.textHint, size: 24),
                    ],
                  ),
                ),
                // Progress bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${widget.completedCount}/${widget.level.lessons.length} lessons',
                            style: GoogleFonts.poppins(
                                fontSize: 11, color: AppColors.textLight),
                          ),
                          Text(
                            '${(widget.progress * 100).toInt()}%',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: widget.level.color,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: widget.progress.clamp(0.0, 1.0),
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    widget.level.color,
                                    widget.level.color.withOpacity(0.6),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ).animate().slideX(
                              begin: -1,
                              end: 0,
                              duration: 700.ms,
                              delay: widget.delay,
                              curve: Curves.easeOut),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms, delay: widget.delay).slideY(begin: 0.1),
        ),
      ),
    );
  }
}

// ─── Level Detail Screen ──────────────────────────────────────────────────────
class _LevelDetailScreen extends ConsumerStatefulWidget {
  final LearningLevel level;
  final Map<String, bool> progressMap;

  const _LevelDetailScreen(
      {required this.level, required this.progressMap});

  @override
  ConsumerState<_LevelDetailScreen> createState() =>
      _LevelDetailScreenState();
}

class _LevelDetailScreenState extends ConsumerState<_LevelDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(learningProgressProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 130,
            pinned: true,
            backgroundColor: widget.level.color,
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.level.color.withOpacity(0.9),
                      widget.level.color,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.level.emoji} Level ${widget.level.level}',
                          style: GoogleFonts.poppins(
                              fontSize: 14, color: Colors.white70),
                        ),
                        Text(
                          widget.level.title,
                          style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final lesson = widget.level.lessons[index];
                final key = 'lesson_${widget.level.level}_${lesson.title}';
                final isComplete = progress[key] == true;

                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
                  child: _LessonCard(
                    lesson: lesson,
                    levelColor: widget.level.color,
                    isCompleted: isComplete,
                    index: index,
                    onComplete: () async {
                      await ref
                          .read(learningProgressProvider.notifier)
                          .completeLesson(key);
                    },
                  ),
                );
              },
              childCount: widget.level.lessons.length,
            ),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
        ],
      ),
    );
  }
}

// ─── Lesson Card ──────────────────────────────────────────────────────────────
class _LessonCard extends StatefulWidget {
  final LearningLesson lesson;
  final Color levelColor;
  final bool isCompleted;
  final int index;
  final Future<void> Function() onComplete;

  const _LessonCard({
    required this.lesson,
    required this.levelColor,
    required this.isCompleted,
    required this.index,
    required this.onComplete,
  });

  @override
  State<_LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<_LessonCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: widget.isCompleted
              ? AppColors.success.withOpacity(0.3)
              : widget.levelColor.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: widget.isCompleted
                ? AppColors.success.withOpacity(0.08)
                : widget.levelColor.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: widget.isCompleted
                          ? AppColors.success.withOpacity(0.1)
                          : widget.levelColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        widget.isCompleted ? '✅' : widget.lesson.emoji,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.lesson.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                        Row(
                          children: [
                            Text('⭐ ${widget.lesson.points} XP',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: widget.isCompleted
                                      ? AppColors.success
                                      : AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                )),
                            const SizedBox(width: 8),
                            Text('• ${widget.lesson.quiz.length} quiz',
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: AppColors.textLight,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textLight,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Divider(height: 1, color: AppColors.cardBorder),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.lesson.content,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!widget.isCompleted)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showQuiz(context),
                        icon: const Icon(Icons.quiz_rounded, size: 18),
                        label: Text(
                          'Take Quiz & Earn ${widget.lesson.points} XP',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: widget.levelColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle_outline_rounded,
                              color: AppColors.success, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Completed! ${widget.lesson.points} XP earned',
                            style: GoogleFonts.poppins(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                                fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 350.ms, delay: (widget.index * 80).ms);
  }

  void _showQuiz(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _QuizScreen(
          lesson: widget.lesson,
          levelColor: widget.levelColor,
          onComplete: widget.onComplete,
        ),
      ),
    );
  }
}

// ─── Quiz Screen ──────────────────────────────────────────────────────────────
class _QuizScreen extends StatefulWidget {
  final LearningLesson lesson;
  final Color levelColor;
  final Future<void> Function() onComplete;

  const _QuizScreen({
    required this.lesson,
    required this.levelColor,
    required this.onComplete,
  });

  @override
  State<_QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<_QuizScreen> {
  int _currentQuestion = 0;
  int? _selectedAnswer;
  int _correctAnswers = 0;
  bool _showResult = false;
  bool _answered = false;

  void _selectAnswer(int index) {
    if (_answered) return;
    setState(() {
      _selectedAnswer = index;
      _answered = true;
      if (index == widget.lesson.quiz[_currentQuestion].correctIndex) {
        _correctAnswers++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_currentQuestion < widget.lesson.quiz.length - 1) {
        setState(() {
          _currentQuestion++;
          _selectedAnswer = null;
          _answered = false;
        });
      } else {
        setState(() => _showResult = true);
        if (_correctAnswers == widget.lesson.quiz.length) {
          widget.onComplete();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) return _buildResultScreen();

    final question = widget.lesson.quiz[_currentQuestion];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: widget.levelColor,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Quiz: ${widget.lesson.title}',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(6),
          child: LinearProgressIndicator(
            value: (_currentQuestion + 1) / widget.lesson.quiz.length,
            backgroundColor: Colors.white.withOpacity(0.3),
            valueColor: const AlwaysStoppedAnimation(Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Question ${_currentQuestion + 1} of ${widget.lesson.quiz.length}',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textLight),
            ),
            const SizedBox(height: 12),
            Text(
              question.question,
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain,
                height: 1.3,
              ),
            ).animate().fadeIn().slideY(begin: -0.05),
            const SizedBox(height: 28),
            ...question.options.asMap().entries.map((entry) {
              final i = entry.key;
              final isCorrect = i == question.correctIndex;
              final isSelected = _selectedAnswer == i;

              Color bgColor = Colors.white;
              Color borderColor = AppColors.cardBorder;
              Color textColor = AppColors.textMain;

              if (_answered) {
                if (isCorrect) {
                  bgColor = AppColors.success.withOpacity(0.12);
                  borderColor = AppColors.success;
                  textColor = AppColors.success;
                } else if (isSelected) {
                  bgColor = AppColors.error.withOpacity(0.08);
                  borderColor = AppColors.error;
                  textColor = AppColors.error;
                }
              } else if (isSelected) {
                bgColor = widget.levelColor.withOpacity(0.1);
                borderColor = widget.levelColor;
                textColor = widget.levelColor;
              }

              return GestureDetector(
                onTap: () => _selectAnswer(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: borderColor.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + i),
                            style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: borderColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: textColor,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      if (_answered && isCorrect)
                        const Icon(Icons.check_circle_rounded,
                            color: AppColors.success, size: 22),
                      if (_answered && isSelected && !isCorrect)
                        const Icon(Icons.cancel_rounded,
                            color: AppColors.error, size: 22),
                    ],
                  ),
                ).animate().fadeIn(duration: 250.ms, delay: (i * 80).ms),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final allCorrect = _correctAnswers == widget.lesson.quiz.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedScale(
                scale: 1.0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.elasticOut,
                child: Text(
                  allCorrect ? '🎉' : '🌟',
                  style: const TextStyle(fontSize: 80),
                ),
              ).animate().scale(begin: const Offset(0.3, 0.3), duration: 600.ms, curve: Curves.elasticOut),
              const SizedBox(height: 24),
              Text(
                allCorrect ? 'Perfect Score!' : 'Great try!',
                style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textMain),
              ),
              const SizedBox(height: 8),
              Text(
                '$_correctAnswers/${widget.lesson.quiz.length} correct',
                style: GoogleFonts.poppins(
                    fontSize: 18, color: AppColors.textSecondary),
              ),
              if (allCorrect) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.success.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star_rounded, color: AppColors.warning, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        '+${widget.lesson.points} XP earned!',
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.levelColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: Text('Continue Learning',
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
