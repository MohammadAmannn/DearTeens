import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class MedicalDisclaimerScreen extends StatelessWidget {
  const MedicalDisclaimerScreen({Key? key}) : super(key: key);

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
            backgroundColor: const Color(0xFFE53935),
            foregroundColor: Colors.white,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFC62828), Color(0xFFE53935), Color(0xFFEF5350)],
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
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.medical_information_rounded,
                                  color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Medical Disclaimer',
                                    style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                Text('Important health information',
                                    style: GoogleFonts.poppins(
                                        fontSize: 12, color: Colors.white70)),
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Warning Banner
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3E0),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFFF9800).withOpacity(0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          color: Color(0xFFFF9800), size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'This application provides educational information only and does not replace professional medical advice.',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE65100),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),

                const SizedBox(height: 20),

                // Sections
                _buildSection(
                  icon: Icons.info_outline_rounded,
                  title: 'General Information',
                  color: const Color(0xFF2196F3),
                  content: 'DearTeens (TeenCare) is designed to provide general health '
                      'education and wellness tools for teenagers. The information '
                      'presented in this app is for educational purposes only and '
                      'should not be interpreted as medical advice, diagnosis, or '
                      'treatment recommendations.',
                  delay: 100.ms,
                ),

                _buildSection(
                  icon: Icons.local_hospital_rounded,
                  title: 'Not a Medical Service',
                  color: const Color(0xFFE91E63),
                  content: 'This app does NOT provide medical services. It is not a '
                      'substitute for professional medical advice, diagnosis, or '
                      'treatment. Never disregard professional medical advice or delay '
                      'seeking it because of something you have read in this app.',
                  delay: 200.ms,
                ),

                _buildSection(
                  icon: Icons.psychology_rounded,
                  title: 'AI-Generated Content',
                  color: const Color(0xFF7C7CF8),
                  content: 'Some features in this app use artificial intelligence to '
                      'generate suggestions and recommendations. AI-generated content '
                      'is not reviewed by medical professionals and may contain '
                      'inaccuracies. Always verify health information with a qualified '
                      'healthcare provider.',
                  delay: 300.ms,
                ),

                _buildSection(
                  icon: Icons.emergency_rounded,
                  title: 'Emergency Situations',
                  color: const Color(0xFFE53935),
                  content: 'If you are experiencing a medical emergency, please call '
                      'your local emergency number (such as 911 or 112) immediately. '
                      'Do not rely on this app for emergency medical situations. If you '
                      'are in crisis or having thoughts of self-harm, please contact a '
                      'crisis helpline in your area.',
                  delay: 400.ms,
                ),

                _buildSection(
                  icon: Icons.people_rounded,
                  title: 'Parental Guidance',
                  color: const Color(0xFF4CAF50),
                  content: 'This app is designed for teenagers aged 13-19. We encourage '
                      'users to discuss health topics with their parents, guardians, or '
                      'other trusted adults. Parental involvement in health education is '
                      'important for young people\'s wellbeing.',
                  delay: 500.ms,
                ),

                _buildSection(
                  icon: Icons.privacy_tip_rounded,
                  title: 'Data & Privacy',
                  color: const Color(0xFFFF9800),
                  content: 'Health data you enter into this app (mood logs, health tracking) '
                      'is stored securely and is not shared with third parties for '
                      'medical or diagnostic purposes. This data is for your personal '
                      'tracking only and should not be used as a medical record.',
                  delay: 600.ms,
                ),

                const SizedBox(height: 20),

                // Acceptance
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFE53935).withOpacity(0.08),
                        const Color(0xFFFF6B9A).withOpacity(0.04),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE53935).withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'By using this app, you acknowledge that you have read and '
                        'understood this medical disclaimer and agree to its terms.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: Text('I Understand',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600, fontSize: 15)),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 700.ms),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required Color color,
    required String content,
    required Duration delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
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
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 350.ms, delay: delay).slideY(begin: 0.1);
  }
}
