import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';

class EmergencySupportScreen extends StatelessWidget {
  const EmergencySupportScreen({super.key});

  void _call(BuildContext context, String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch dialer',
                style: GoogleFonts.poppins(color: Colors.white)),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  void _copyNumber(BuildContext context, String number) {
    Clipboard.setData(ClipboardData(text: number));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Number copied to clipboard 📋',
            style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: const Color(0xFFE53935),
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFB71C1C), Color(0xFFE53935), Color(0xFFEF9A9A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(children: [
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
                  SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.emergency_rounded,
                                  color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('Emergency Support',
                                    style: GoogleFonts.poppins(
                                        fontSize: 22, fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                Text('You are not alone. Help is here.',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12, color: Colors.white70)),
                              ],
                            ),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── You matter banner ────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B9A), Color(0xFF7C7CF8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Text('💜', style: TextStyle(fontSize: 36)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('You matter. You are loved.',
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(
                                'Whatever you\'re going through, there are people who care and want to help.',
                                style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.white.withOpacity(0.85),
                                    height: 1.4)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 24),

                _SectionHeader(
                    title: 'Crisis Helplines 🆘', delay: 100.ms),
                const SizedBox(height: 12),

                _HelplineCard(
                  country: 'International',
                  name: 'International Association for Suicide Prevention',
                  number: null,
                  website: 'https://www.iasp.info/resources/Crisis_Centres/',
                  description: 'Find crisis centres worldwide',
                  emoji: '🌍',
                  color: const Color(0xFF1565C0),
                  onCall: (_) {},
                  onCopy: (_) {},
                  delay: 150.ms,
                ),
                _HelplineCard(
                  country: 'India',
                  name: 'iCall Helpline',
                  number: '9152987821',
                  description: 'Free counselling in multiple languages',
                  emoji: '🇮🇳',
                  color: const Color(0xFFE64A19),
                  onCall: (ctx) => _call(ctx, '9152987821'),
                  onCopy: (ctx) => _copyNumber(ctx, '9152987821'),
                  delay: 230.ms,
                ),
                _HelplineCard(
                  country: 'India',
                  name: 'Vandrevala Foundation',
                  number: '1860-2662-345',
                  description: '24/7 mental health support, free of cost',
                  emoji: '🇮🇳',
                  color: const Color(0xFF4CAF50),
                  onCall: (ctx) => _call(ctx, '18602662345'),
                  onCopy: (ctx) => _copyNumber(ctx, '18602662345'),
                  delay: 310.ms,
                ),
                _HelplineCard(
                  country: 'USA',
                  name: '988 Suicide & Crisis Lifeline',
                  number: '988',
                  description: 'Call or text 988 for free, confidential support',
                  emoji: '🇺🇸',
                  color: const Color(0xFF1976D2),
                  onCall: (ctx) => _call(ctx, '988'),
                  onCopy: (ctx) => _copyNumber(ctx, '988'),
                  delay: 390.ms,
                ),
                _HelplineCard(
                  country: 'UK',
                  name: 'Samaritans',
                  number: '116 123',
                  description: 'Free 24/7 listening service',
                  emoji: '🇬🇧',
                  color: const Color(0xFF6A1B9A),
                  onCall: (ctx) => _call(ctx, '116123'),
                  onCopy: (ctx) => _copyNumber(ctx, '116123'),
                  delay: 470.ms,
                ),

                const SizedBox(height: 24),
                _SectionHeader(title: 'If You\'re In Danger Right Now 🚨', delay: 500.ms),
                const SizedBox(height: 12),

                _EmergencyCallButton(delay: 550.ms),

                const SizedBox(height: 24),
                _SectionHeader(title: 'Coping Strategies 🧘', delay: 600.ms),
                const SizedBox(height: 12),

                ..._copingStrategies.asMap().entries.map((entry) =>
                  _CopingCard(
                    tip: entry.value,
                    delay: (650 + entry.key * 60).ms,
                  ),
                ),

                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF9C27B0).withOpacity(0.2)),
                  ),
                  child: Text(
                    '⚠️ This app is not a crisis service. If you are in immediate danger, please call your local emergency number (112 / 911 / 999) right now.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: const Color(0xFF6A1B9A), height: 1.5),
                  ),
                ).animate().fadeIn(delay: 900.ms),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  static const List<Map<String, String>> _copingStrategies = [
    {'emoji': '🌬️', 'title': '4-7-8 Breathing', 'desc': 'Breathe in 4 counts, hold 7, exhale 8. Repeat 4 times to calm instantly.'},
    {'emoji': '🖐️', 'title': '5-4-3-2-1 Grounding', 'desc': 'Name 5 things you see, 4 you can touch, 3 hear, 2 smell, 1 taste.'},
    {'emoji': '🚶', 'title': 'Move Your Body', 'desc': 'Walk, stretch, or dance for 5 minutes. Movement shifts your mental state.'},
    {'emoji': '📞', 'title': 'Reach Out', 'desc': 'Text a friend, family member, or trusted adult. You don\'t have to face it alone.'},
    {'emoji': '✍️', 'title': 'Write It Out', 'desc': 'Journal your feelings. Getting thoughts out of your head helps process them.'},
  ];
}

// ── Reusable sub-widgets ───────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  final Duration delay;
  const _SectionHeader({required this.title, required this.delay});

  @override
  Widget build(BuildContext context) => Text(title,
          style: GoogleFonts.poppins(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textMain,
          ))
      .animate()
      .fadeIn(duration: 300.ms, delay: delay);
}

class _HelplineCard extends StatelessWidget {
  final String country;
  final String name;
  final String? number;
  final String? website;
  final String description;
  final String emoji;
  final Color color;
  final Duration delay;
  final void Function(BuildContext) onCall;
  final void Function(BuildContext) onCopy;

  const _HelplineCard({
    required this.country,
    required this.name,
    this.number,
    this.website,
    required this.description,
    required this.emoji,
    required this.color,
    required this.delay,
    required this.onCall,
    required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(country,
                          style: GoogleFonts.poppins(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: color,
                              letterSpacing: 0.5)),
                    ),
                    const SizedBox(height: 3),
                    Text(name,
                        style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textMain)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(description,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: AppColors.textSecondary, height: 1.4)),
          if (number != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => onCall(context),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.call_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 6),
                          Text('Call $number',
                              style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => onCopy(context),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.copy_rounded, color: color, size: 18),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 350.ms, delay: delay).slideY(begin: 0.1);
  }
}

class _EmergencyCallButton extends StatelessWidget {
  final Duration delay;
  const _EmergencyCallButton({required this.delay});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse('tel:112');
        if (await canLaunchUrl(uri)) launchUrl(uri);
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE53935).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emergency_rounded, color: Colors.white, size: 26),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Call Emergency Services',
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                Text('Tap to dial 112 (Global Emergency)',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: Colors.white70)),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms, delay: delay).scale(begin: const Offset(0.9, 0.9));
  }
}

class _CopingCard extends StatelessWidget {
  final Map<String, String> tip;
  final Duration delay;
  const _CopingCard({required this.tip, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Text(tip['emoji']!, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tip['title']!,
                    style: GoogleFonts.poppins(
                        fontSize: 13, fontWeight: FontWeight.bold,
                        color: AppColors.textMain)),
                const SizedBox(height: 2),
                Text(tip['desc']!,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.textSecondary, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms, delay: delay);
  }
}
