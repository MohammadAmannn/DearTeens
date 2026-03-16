import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/notification_service.dart';
import '../../emergency/screens/emergency_support_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'medical_disclaimer_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _challengeReminders = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.textMain,
            foregroundColor: Colors.white,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF2D3436), Color(0xFF636E72), Color(0xFF2D3436)],
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
                          color: Colors.white.withOpacity(0.04),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -20, left: -20,
                      child: Container(
                        width: 100, height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.03),
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
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.settings_rounded,
                                  color: Colors.white, size: 24),
                            ),
                            const SizedBox(width: 14),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Settings ⚙️',
                                    style: GoogleFonts.poppins(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                Text('Customize your experience',
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

          // ── Content ────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Preferences Section ────────────────────────────────────
                _buildSectionTitle('PREFERENCES', Icons.tune_rounded, delay: 0.ms),
                const SizedBox(height: 10),

                _buildToggleTile(
                  icon: Icons.notifications_active_rounded,
                  iconColor: const Color(0xFFFF9800),
                  title: 'Daily Tips & Reminders',
                  subtitle: 'Receive uplifting messages and health tips',
                  value: _notificationsEnabled,
                  onChanged: (v) {
                    setState(() => _notificationsEnabled = v);
                    NotificationService.instance.setDailyTipsEnabled(v);
                  },
                  delay: 80.ms,
                ),

                _buildToggleTile(
                  icon: Icons.emoji_events_rounded,
                  iconColor: const Color(0xFFFF6B9A),
                  title: 'Challenge Reminders',
                  subtitle: 'Daily nudge to complete your wellness challenges',
                  value: _challengeReminders,
                  onChanged: (v) {
                    setState(() => _challengeReminders = v);
                    NotificationService.instance.setChallengeRemindersEnabled(v);
                  },
                  delay: 130.ms,
                ),

                _buildToggleTile(
                  icon: Icons.dark_mode_rounded,
                  iconColor: const Color(0xFF7C7CF8),
                  title: 'Dark Mode',
                  subtitle: 'Switch to dark theme for comfortable viewing',
                  value: _darkMode,
                  onChanged: (v) => setState(() => _darkMode = v),
                  delay: 180.ms,
                ),

                const SizedBox(height: 24),

                // ── Account Section ──────────────────────────────────────
                _buildSectionTitle('ACCOUNT', Icons.person_rounded, delay: 240.ms),
                const SizedBox(height: 10),

                _buildNavTile(
                  icon: Icons.lock_outline_rounded,
                  iconColor: const Color(0xFF4CAF50),
                  title: 'Change Password',
                  subtitle: 'Update your account password',
                  onTap: () => _showChangePasswordDialog(context),
                  delay: 320.ms,
                ),

                _buildNavTile(
                  icon: Icons.delete_outline_rounded,
                  iconColor: const Color(0xFFE53935),
                  title: 'Delete Account',
                  subtitle: 'Permanently delete your data',
                  showDanger: true,
                  onTap: () => _showDeleteAccountDialog(context),
                  delay: 400.ms,
                ),

                _buildNavTile(
                  icon: Icons.emergency_rounded,
                  iconColor: const Color(0xFFE53935),
                  title: 'Emergency Support',
                  subtitle: 'Crisis helplines and coping resources',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const EmergencySupportScreen())),
                  delay: 500.ms,
                  showDanger: true,
                ),

                const SizedBox(height: 24),

                // ── Legal Section ────────────────────────────────────────
                _buildSectionTitle('LEGAL & ABOUT', Icons.gavel_rounded, delay: 560.ms),
                const SizedBox(height: 10),

                _buildNavTile(
                  icon: Icons.privacy_tip_rounded,
                  iconColor: const Color(0xFF2196F3),
                  title: 'Privacy Policy',
                  subtitle: 'How we handle your data',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen())),
                  delay: 640.ms,
                ),

                _buildNavTile(
                  icon: Icons.description_rounded,
                  iconColor: const Color(0xFF9C27B0),
                  title: 'Terms of Service',
                  subtitle: 'App usage terms and conditions',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const TermsOfServiceScreen())),
                  delay: 640.ms,
                ),

                _buildNavTile(
                  icon: Icons.medical_information_rounded,
                  iconColor: const Color(0xFFE53935),
                  title: 'Medical Disclaimer',
                  subtitle: 'Important health information notice',
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const MedicalDisclaimerScreen())),
                  delay: 720.ms,
                ),

                const SizedBox(height: 24),

                // ── App Info ────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withOpacity(0.08),
                        AppColors.secondary.withOpacity(0.04),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                  ),
                  child: Column(
                    children: [
                      Text('💕', style: const TextStyle(fontSize: 32)),
                      const SizedBox(height: 8),
                      Text(
                        'DearTeens',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version 1.0.0',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Made with ❤️ for teens everywhere',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 800.ms),

                const SizedBox(height: 20),

                // ── Logout Button ─────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showLogoutDialog(context),
                    icon: const Icon(Icons.logout_rounded, size: 18),
                    label: Text('Sign Out',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE53935),
                      side: const BorderSide(color: Color(0xFFE53935), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms, delay: 880.ms),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // ── Reusable Widgets ──────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title, IconData icon, {required Duration delay}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textLight),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.textLight,
            letterSpacing: 1.5,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: delay);
  }

  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Duration delay,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Text(title,
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textMain)),
        subtitle: Text(subtitle,
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
        secondary: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: delay).slideX(begin: 0.05);
  }

  Widget _buildNavTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required Duration delay,
    bool showDanger = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: showDanger ? const Color(0xFFFFF5F5) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: showDanger
              ? const Color(0xFFE53935).withOpacity(0.15)
              : AppColors.cardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        title: Text(title,
            style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: showDanger ? const Color(0xFFE53935) : AppColors.textMain)),
        subtitle: Text(subtitle,
            style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
        trailing: Icon(Icons.arrow_forward_ios_rounded,
            size: 14,
            color: showDanger ? const Color(0xFFE53935) : AppColors.textHint),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    ).animate().fadeIn(duration: 300.ms, delay: delay).slideX(begin: 0.05);
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────
  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.lock_outline_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Text('Change Password',
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'A password reset email will be sent to your registered email address.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppColors.textLight)),
          ),
          ElevatedButton(
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user?.email != null) {
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: user!.email!);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Password reset email sent! 📧',
                          style: GoogleFonts.poppins(color: Colors.white)),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('Send Email',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.warning_rounded, color: Color(0xFFE53935), size: 22),
            const SizedBox(width: 10),
            Text('Delete Account',
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.bold, color: const Color(0xFFE53935))),
          ],
        ),
        content: Text(
          'This action is permanent and cannot be undone. All your data including '
          'mood logs, challenges, and profile information will be permanently deleted.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppColors.textLight)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('Delete',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.logout_rounded, color: AppColors.primary, size: 22),
            const SizedBox(width: 10),
            Text('Sign Out',
                style: GoogleFonts.poppins(
                    fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to sign out? You can sign back in anytime.',
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.poppins(color: AppColors.textLight)),
          ),
          ElevatedButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).popUntil((route) => route.isFirst);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text('Sign Out',
                style: GoogleFonts.poppins(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
