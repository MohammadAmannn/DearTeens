import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

// ─── Article Model ─────────────────────────────────────────────────────────────
class KnowledgeArticle {
  final String title;
  final String summary;
  final String emoji;
  final List<String> sections;
  final List<String> tips;

  const KnowledgeArticle({
    required this.title,
    required this.summary,
    required this.emoji,
    required this.sections,
    required this.tips,
  });
}

// ─── Category Model ────────────────────────────────────────────────────────────
class KnowledgeCategory {
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final IconData icon;
  final List<KnowledgeArticle> articles;

  const KnowledgeCategory({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.icon,
    required this.articles,
  });
}

// ─── Data ──────────────────────────────────────────────────────────────────────
const List<KnowledgeCategory> _categories = [
  KnowledgeCategory(
    title: 'Puberty Basics',
    subtitle: 'Understanding your body\'s changes',
    emoji: '🌱',
    color: Color(0xFF4CAF50),
    icon: Icons.child_care_rounded,
    articles: [
      KnowledgeArticle(
        title: 'What is Puberty?',
        summary: 'A complete guide to understanding the natural changes your body goes through.',
        emoji: '🌟',
        sections: [
          'Puberty is a natural process where your body transitions from childhood to adulthood. It typically begins between ages 8-13 for girls and 9-14 for boys.',
          'During puberty, your brain releases hormones that signal your body to start developing. These hormones include estrogen, progesterone, and testosterone.',
          'Every person\'s puberty journey is unique — some start earlier, some later. Both are completely normal!',
        ],
        tips: [
          'Puberty usually lasts 2-5 years',
          'It\'s normal to feel confused or emotional',
          'Talk to a trusted adult if you have questions',
          'Everyone goes through it at their own pace',
        ],
      ),
      KnowledgeArticle(
        title: 'Growth Spurts',
        summary: 'Why you\'re suddenly growing so fast and what to expect.',
        emoji: '📏',
        sections: [
          'Growth spurts are periods of rapid physical growth. During puberty, you might grow several inches in just a few months!',
          'Girls typically experience their growth spurt between ages 10-14, while boys usually experience theirs between ages 12-16.',
          'You might notice your clothes don\'t fit anymore, and that\'s perfectly normal. Your body is doing exactly what it\'s supposed to do.',
        ],
        tips: [
          'Eat nutritious meals to support growth',
          'Get 8-10 hours of sleep — growth hormone is released during sleep',
          'Stay active with regular exercise',
          'Growing pains are real and normal',
        ],
      ),
      KnowledgeArticle(
        title: 'Emotional Changes',
        summary: 'Understanding mood swings and new feelings during puberty.',
        emoji: '🎭',
        sections: [
          'Mood swings during puberty are caused by changing hormone levels. You might feel happy one moment and upset the next — this is totally normal.',
          'You may develop new types of feelings, including crushes or romantic interests. These are natural parts of growing up.',
          'It\'s important to develop healthy ways to manage your emotions, like talking to friends, journaling, or physical activity.',
        ],
        tips: [
          'Mood swings are temporary and will stabilize',
          'Keep a mood journal to track your feelings',
          'Exercise releases feel-good endorphins',
          'It\'s okay to ask for help when emotions feel overwhelming',
        ],
      ),
    ],
  ),
  KnowledgeCategory(
    title: 'Menstrual Health',
    subtitle: 'Everything about your cycle',
    emoji: '🌸',
    color: Color(0xFFE91E63),
    icon: Icons.water_drop_rounded,
    articles: [
      KnowledgeArticle(
        title: 'Understanding Your Period',
        summary: 'A comprehensive guide to menstruation and what to expect.',
        emoji: '📖',
        sections: [
          'A period, or menstruation, is the monthly shedding of the uterine lining. It typically lasts 3-7 days and occurs roughly every 21-35 days.',
          'Your first period (menarche) usually arrives between ages 9-16. It may be irregular at first, and that\'s completely normal.',
          'During your period, you lose about 2-3 tablespoons of blood. Using pads, tampons, or menstrual cups are all safe options for managing your period.',
        ],
        tips: [
          'Track your cycle to know when to expect your period',
          'Keep supplies in your bag just in case',
          'Cramps are normal — a warm compress can help',
          'See a doctor if periods are extremely heavy or painful',
        ],
      ),
      KnowledgeArticle(
        title: 'PMS and Managing Symptoms',
        summary: 'Understanding premenstrual syndrome and how to feel better.',
        emoji: '💊',
        sections: [
          'PMS (Premenstrual Syndrome) affects up to 90% of women. Symptoms can include mood swings, bloating, cramps, headaches, and fatigue.',
          'These symptoms usually occur 1-2 weeks before your period starts and improve once your period begins.',
          'Lifestyle changes like regular exercise, balanced nutrition, and adequate sleep can significantly reduce PMS symptoms.',
        ],
        tips: [
          'Reduce salt intake to minimize bloating',
          'Gentle exercise like yoga helps with cramps',
          'Dark chocolate (in moderation) can improve mood',
          'Stay hydrated — aim for 8 glasses of water daily',
        ],
      ),
      KnowledgeArticle(
        title: 'Cycle Phases Explained',
        summary: 'The four phases of your menstrual cycle and what happens in each.',
        emoji: '🔄',
        sections: [
          'Phase 1 — Menstruation (Days 1-5): The uterine lining sheds. You may feel tired and have cramps.',
          'Phase 2 — Follicular (Days 6-14): Estrogen rises, energy increases, and you may feel more social and creative.',
          'Phase 3 — Ovulation (Day 14): An egg is released. You might feel your best during this time with peak energy.',
          'Phase 4 — Luteal (Days 15-28): Progesterone rises, PMS symptoms may appear, and you might crave comfort foods.',
        ],
        tips: [
          'Align activities with your cycle phases for optimal wellbeing',
          'High-energy workouts are best during the follicular phase',
          'Be gentle with yourself during the luteal phase',
          'Tracking your cycle helps you understand your body better',
        ],
      ),
    ],
  ),
  KnowledgeCategory(
    title: 'Mental Health',
    subtitle: 'Taking care of your mind',
    emoji: '🧠',
    color: Color(0xFF7C7CF8),
    icon: Icons.psychology_rounded,
    articles: [
      KnowledgeArticle(
        title: 'Anxiety in Teens',
        summary: 'Understanding anxiety and learning coping strategies.',
        emoji: '😰',
        sections: [
          'Anxiety is one of the most common mental health challenges teens face. It\'s your body\'s natural response to stress, but sometimes it can feel overwhelming.',
          'Symptoms include racing heart, sweaty palms, difficulty concentrating, and excessive worry. These are your body\'s fight-or-flight response activating.',
          'Remember: having anxiety doesn\'t mean something is wrong with you. It\'s a treatable condition, and many successful people manage anxiety effectively.',
        ],
        tips: [
          'Practice the 5-4-3-2-1 grounding technique',
          'Deep breathing activates your parasympathetic nervous system',
          'Regular physical activity reduces anxiety by 48%',
          'Talk to a counselor — therapy is a sign of strength',
        ],
      ),
      KnowledgeArticle(
        title: 'Building Self-Esteem',
        summary: 'Developing a healthy self-image during your teen years.',
        emoji: '💪',
        sections: [
          'Self-esteem is how you feel about yourself. During the teen years, it can fluctuate a lot due to social pressures, body changes, and academic stress.',
          'Social media can negatively impact self-esteem. Remember that what you see online is usually a carefully curated highlight reel, not real life.',
          'Building self-esteem takes time and practice. Focus on your strengths, celebrate small victories, and be kind to yourself.',
        ],
        tips: [
          'Write down 3 things you\'re grateful for each day',
          'Limit social media to 30 minutes per day',
          'Surround yourself with supportive people',
          'Practice positive self-talk daily',
        ],
      ),
      KnowledgeArticle(
        title: 'Dealing with Stress',
        summary: 'Healthy ways to manage stress from school, friends, and life.',
        emoji: '🌊',
        sections: [
          'Stress is a normal part of life, but chronic stress can affect your physical and mental health. Common teen stressors include school, friendships, family issues, and future worries.',
          'Your body responds to stress by releasing cortisol. While short-term stress can be motivating, long-term stress can cause headaches, sleep problems, and mood changes.',
          'Developing healthy stress management skills now will benefit you throughout your entire life.',
        ],
        tips: [
          'Break big tasks into smaller, manageable steps',
          'Practice time management with a planner',
          'Take regular breaks — the Pomodoro technique works!',
          'Physical activity is one of the best stress relievers',
        ],
      ),
    ],
  ),
  KnowledgeCategory(
    title: 'Body Hygiene',
    subtitle: 'Healthy habits for a healthy body',
    emoji: '🧼',
    color: Color(0xFF43C6AC),
    icon: Icons.sanitizer_rounded,
    articles: [
      KnowledgeArticle(
        title: 'Skincare Basics',
        summary: 'Building a simple, effective skincare routine for teens.',
        emoji: '✨',
        sections: [
          'During puberty, your skin produces more oil, which can lead to acne. A simple skincare routine can make a huge difference.',
          'The basics: Cleanse, moisturize, and apply sunscreen daily. That\'s it! You don\'t need expensive or complicated products.',
          'Acne is incredibly common in teens — about 85% of teens experience it. It\'s not caused by dirty skin, and picking at pimples can make things worse.',
        ],
        tips: [
          'Wash your face twice daily with a gentle cleanser',
          'Never skip sunscreen — even on cloudy days',
          'Change your pillowcase regularly',
          'Drink plenty of water for healthy, glowing skin',
        ],
      ),
      KnowledgeArticle(
        title: 'Body Odor & Hygiene',
        summary: 'Why your body suddenly smells different and what to do about it.',
        emoji: '🚿',
        sections: [
          'During puberty, your sweat glands become more active, especially in the underarms and groin area. Bacteria on your skin breaks down sweat, causing body odor.',
          'This is completely normal! Using deodorant or antiperspirant, showering daily, and wearing clean clothes are the best ways to manage body odor.',
          'Natural body odor is not something to be ashamed of — it\'s a sign that your body is maturing. Proper hygiene habits simply help you feel fresh and confident.',
        ],
        tips: [
          'Shower daily, especially after exercise',
          'Apply deodorant each morning',
          'Wear breathable fabrics like cotton',
          'Change underwear and socks daily',
        ],
      ),
      KnowledgeArticle(
        title: 'Dental Health Essentials',
        summary: 'Taking care of your teeth and gums during the teen years.',
        emoji: '😁',
        sections: [
          'Good dental habits during your teen years set the foundation for lifelong oral health. Brush twice daily for two minutes and floss once a day.',
          'If you have braces, extra care is needed. Food particles can easily get trapped, so use an interdental brush and be extra thorough when brushing.',
          'Limit sugary drinks and snacks. Soda, energy drinks, and candy can erode tooth enamel and cause cavities.',
        ],
        tips: [
          'Replace your toothbrush every 3 months',
          'Use fluoride toothpaste for cavity protection',
          'Visit your dentist every 6 months',
          'Drink water instead of sugary beverages',
        ],
      ),
    ],
  ),
  KnowledgeCategory(
    title: 'Nutrition',
    subtitle: 'Fueling your growing body right',
    emoji: '🥗',
    color: Color(0xFFFF9800),
    icon: Icons.restaurant_rounded,
    articles: [
      KnowledgeArticle(
        title: 'Teen Nutrition Guide',
        summary: 'What your growing body needs to thrive.',
        emoji: '🍎',
        sections: [
          'During puberty, your body needs extra nutrients to support rapid growth. Teens need about 2,200-2,800 calories per day, depending on activity level.',
          'Focus on a balanced diet with plenty of fruits, vegetables, whole grains, lean proteins, and dairy. These provide essential vitamins and minerals for growth.',
          'Iron is especially important for girls who have started their periods. Foods like spinach, beans, and fortified cereals are great iron sources.',
        ],
        tips: [
          'Eat breakfast every day — it boosts concentration',
          'Include protein in every meal for muscle growth',
          'Aim for 5 servings of fruits and vegetables daily',
          'Calcium-rich foods build strong bones during growth',
        ],
      ),
      KnowledgeArticle(
        title: 'Healthy Eating Habits',
        summary: 'Building a positive relationship with food.',
        emoji: '🥑',
        sections: [
          'Healthy eating isn\'t about restriction — it\'s about nourishment. Your body needs fuel to grow, learn, and play.',
          'Avoid comparing your eating habits or body to others. Everyone\'s nutritional needs are different based on their unique body, activity level, and genetics.',
          'Mindful eating means paying attention to hunger and fullness cues, eating without distractions, and enjoying your food without guilt.',
        ],
        tips: [
          'Listen to your body\'s hunger and fullness signals',
          'No food is "good" or "bad" — balance is key',
          'Cook meals at home when possible',
          'Stay hydrated — sometimes thirst feels like hunger',
        ],
      ),
      KnowledgeArticle(
        title: 'Hydration & Energy',
        summary: 'Why water is your body\'s best friend.',
        emoji: '💧',
        sections: [
          'Water makes up about 60% of your body weight and is essential for every bodily function. Teens should aim for 8-10 glasses of water per day.',
          'Dehydration can cause headaches, fatigue, difficulty concentrating, and mood changes — all things that can impact your school performance and social life.',
          'While sports drinks have their place during intense exercise, water is the best choice for everyday hydration. Limit sugary drinks and energy drinks.',
        ],
        tips: [
          'Carry a reusable water bottle everywhere',
          'Drink water first thing in the morning',
          'Add lemon or cucumber for natural flavor',
          'Set hydration reminders on your phone',
        ],
      ),
    ],
  ),
];

// ─── Screen ───────────────────────────────────────────────────────────────────
class KnowledgeLibraryScreen extends StatefulWidget {
  const KnowledgeLibraryScreen({Key? key}) : super(key: key);

  @override
  State<KnowledgeLibraryScreen> createState() => _KnowledgeLibraryScreenState();
}

class _KnowledgeLibraryScreenState extends State<KnowledgeLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<KnowledgeCategory> get _filteredCategories {
    if (_searchQuery.isEmpty) return _categories;
    return _categories.where((cat) {
      final catMatch = cat.title.toLowerCase().contains(_searchQuery);
      final articleMatch = cat.articles.any((a) =>
          a.title.toLowerCase().contains(_searchQuery) ||
          a.summary.toLowerCase().contains(_searchQuery));
      return catMatch || articleMatch;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            backgroundColor: const Color(0xFF2196F3),
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF42A5F5), Color(0xFF7C7CF8)],
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
                      ),
                    ),
                    Positioned(
                      bottom: -20, left: -20,
                      child: Container(
                        width: 120, height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.04),
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
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.menu_book_rounded,
                                      color: Colors.white, size: 22),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Knowledge Library 📚',
                                        style: GoogleFonts.poppins(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white)),
                                    Text('Safe health education for teens',
                                        style: GoogleFonts.poppins(
                                            fontSize: 12, color: Colors.white70)),
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

          // ── Search Bar ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
                  style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textMain),
                  decoration: InputDecoration(
                    hintText: 'Search articles...',
                    hintStyle: GoogleFonts.poppins(color: AppColors.textHint, fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textHint),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.textHint),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 400.ms),
          ),

          // ── Category Grid ──────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.85,
              ),
              itemCount: _filteredCategories.length,
              itemBuilder: (context, index) {
                return _CategoryCard(
                  category: _filteredCategories[index],
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

// ─── Category Card ────────────────────────────────────────────────────────────
class _CategoryCard extends StatefulWidget {
  final KnowledgeCategory category;
  final Duration delay;

  const _CategoryCard({required this.category, required this.delay});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => _CategoryDetailScreen(category: widget.category),
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: widget.category.color.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: widget.category.color.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 90,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.category.color.withOpacity(0.15),
                      widget.category.color.withOpacity(0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 10, top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: widget.category.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${widget.category.articles.length} articles',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: widget.category.color,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        widget.category.emoji,
                        style: const TextStyle(fontSize: 44),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.category.title,
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
                        widget.category.subtitle,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 7),
                        decoration: BoxDecoration(
                          color: widget.category.color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: widget.category.color.withOpacity(0.2)),
                        ),
                        child: Text(
                          'Explore →',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: widget.category.color,
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
}

// ─── Category Detail Screen ──────────────────────────────────────────────────
class _CategoryDetailScreen extends StatelessWidget {
  final KnowledgeCategory category;

  const _CategoryDetailScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: category.color,
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [category.color, category.color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: -30, right: -30,
                      child: Container(
                        width: 160, height: 160,
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
                        child: Row(
                          children: [
                            Text(category.emoji, style: const TextStyle(fontSize: 40)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(category.title,
                                      style: GoogleFonts.poppins(
                                          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                                  Text('${category.articles.length} articles',
                                      style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70)),
                                ],
                              ),
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            sliver: SliverList.builder(
              itemCount: category.articles.length,
              itemBuilder: (context, index) {
                final article = category.articles[index];
                return _ArticleCard(
                  article: article,
                  color: category.color,
                  delay: (index * 100).ms,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Article Card ─────────────────────────────────────────────────────────────
class _ArticleCard extends StatefulWidget {
  final KnowledgeArticle article;
  final Color color;
  final Duration delay;

  const _ArticleCard({required this.article, required this.color, required this.delay});

  @override
  State<_ArticleCard> createState() => _ArticleCardState();
}

class _ArticleCardState extends State<_ArticleCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _openArticle(context);
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.color.withOpacity(0.15)),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: widget.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(widget.article.emoji, style: const TextStyle(fontSize: 28)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.article.title,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      widget.article.summary,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, size: 16, color: widget.color),
            ],
          ),
        ).animate().fadeIn(duration: 350.ms, delay: widget.delay).slideX(begin: 0.1),
      ),
    );
  }

  void _openArticle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ArticleDetailSheet(article: widget.article, color: widget.color),
    );
  }
}

// ─── Article Detail Sheet ─────────────────────────────────────────────────────
class _ArticleDetailSheet extends StatelessWidget {
  final KnowledgeArticle article;
  final Color color;

  const _ArticleDetailSheet({required this.article, required this.color});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
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
                      Text(article.emoji, style: const TextStyle(fontSize: 44)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          article.title,
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sections
                  ...article.sections.asMap().entries.map((entry) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: color.withOpacity(0.1)),
                      ),
                      child: Text(
                        entry.value,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ).animate()
                        .fadeIn(duration: 300.ms, delay: (entry.key * 100).ms)
                        .slideY(begin: 0.1);
                  }),

                  const SizedBox(height: 16),

                  // Tips section
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.tips_and_updates_rounded, color: color, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Quick Tips',
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ...article.tips.map((tip) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    width: 6, height: 6,
                                    decoration: BoxDecoration(
                                      color: color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      tip,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: Text('Got it! ✨',
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
