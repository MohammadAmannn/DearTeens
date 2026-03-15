import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand Colors ──────────────────────────────────────
  static const Color primary   = Color(0xFFFF6B9A);
  static const Color secondary = Color(0xFF7C7CF8);
  static const Color accent    = Color(0xFF4ECDC4);
  static const Color success   = Color(0xFF4CAF50);
  static const Color warning   = Color(0xFFFF9800);
  static const Color error     = Color(0xFFE53935);

  // ── Light Mode ────────────────────────────────────────
  static const Color background        = Color(0xFFF4F6FF);
  static const Color surface           = Color(0xFFFFFFFF);
  static const Color surfaceElevated   = Color(0xFFFAFBFF);
  static const Color cardBackground    = Color(0xFFFFFFFF);
  static const Color cardBorder        = Color(0xFFEAECF5);

  // ── Text ──────────────────────────────────────────────
  static const Color textMain      = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF4A4A6A);
  static const Color textLight     = Color(0xFF7E7E9A);
  static const Color textHint      = Color(0xFFAAAAAF);

  // ── Dark Mode ─────────────────────────────────────────
  static const Color darkBackground      = Color(0xFF0F0F1A);
  static const Color darkSurface         = Color(0xFF1A1A2E);
  static const Color darkCardBackground  = Color(0xFF1E1E30);
  static const Color darkCardBorder      = Color(0xFF2A2A45);

  // ── Gradients (helpers) ──────────────────────────────
  static const List<Color> primaryGradient   = [Color(0xFFFF6B9A), Color(0xFFFF8CB8)];
  static const List<Color> secondaryGradient = [Color(0xFF7C7CF8), Color(0xFF9C9CF8)];
  static const List<Color> heroGradient      = [Color(0xFFFF6B9A), Color(0xFF7C7CF8), Color(0xFF4ECDC4)];
  static const List<Color> greenGradient     = [Color(0xFF43C6AC), Color(0xFF4CAF50)];
  static const List<Color> pinkGradient      = [Color(0xFFE91E8C), Color(0xFFFF6B9A)];
}
