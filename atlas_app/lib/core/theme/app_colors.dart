import 'package:flutter/material.dart';

/// Centralized color tokens for the Atlas design system.
/// Contains both Light and Dark mode values and adaptive getters.
class AppColors {
  AppColors._();

  // ── Light Theme Colors ──
  static const Color primary = Color(0xFF4F46E5); // Modern Indigo
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color primaryLight = Color(0xFFEEF2FF);

  static const Color background = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF8FAFC);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);

  static const Color border = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFFCBD5E1);

  // ── Dark Theme Colors ──
  static const Color darkPrimary = Color(0xFF818CF8); // Vibrant Slate Indigo
  static const Color darkPrimaryLight = Color(0xFF1E1B4B);

  static const Color darkBackground = Color(0xFF0F172A); // Deep Slate
  static const Color darkCard = Color(0xFF1E293B);       // Elevated Slate Card
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkInputBackground = Color(0xFF1E293B);

  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
  static const Color darkTextMuted = Color(0xFF64748B);

  static const Color darkBorder = Color(0xFF334155);
  static const Color darkBorderStrong = Color(0xFF475569);

  // ── Semantic Colors (Universal) ──
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFF0FDF4);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);

  static const Color danger = Color(0xFFDC2626);
  static const Color dangerLight = Color(0xFFFEF2F2);

  // ── Decisions / Voting ──
  static const Color violet = Color(0xFF7C3AED);
  static const Color violetLight = Color(0xFFF5F3FF);

  // ── Category colors ──
  static const Color categoryDestination = Color(0xFF8B5CF6);
  static const Color categoryDates = Color(0xFF10B981);
  static const Color categoryAccommodation = Color(0xFFF59E0B);
  static const Color categoryActivity = Color(0xFFEC4899);
  static const Color categoryDefault = Color(0xFF64748B);

  // ── Shimmer Colors ──
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);

  // ── Context-Adaptive Getters ──
  static bool isDark(BuildContext context) => Theme.of(context).brightness == Brightness.dark;

  static Color bg(BuildContext context) => isDark(context) ? darkBackground : background;
  static Color cardBg(BuildContext context) => isDark(context) ? darkCard : card;
  static Color surfaceColor(BuildContext context) => isDark(context) ? darkSurface : surface;
  static Color inputBg(BuildContext context) => isDark(context) ? darkInputBackground : inputBackground;

  static Color txtPrimary(BuildContext context) => isDark(context) ? darkTextPrimary : textPrimary;
  static Color txtSecondary(BuildContext context) => isDark(context) ? darkTextSecondary : textSecondary;
  static Color txtMuted(BuildContext context) => isDark(context) ? darkTextMuted : textMuted;

  static Color brd(BuildContext context) => isDark(context) ? darkBorder : border;
  static Color brdStrong(BuildContext context) => isDark(context) ? darkBorderStrong : borderStrong;

  static Color primaryAccent(BuildContext context) => isDark(context) ? darkPrimary : primary;
  static Color primaryBgLight(BuildContext context) => isDark(context) ? darkPrimaryLight : primaryLight;
}
