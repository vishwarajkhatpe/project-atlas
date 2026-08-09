import 'package:flutter/material.dart';

/// Centralized color tokens for the Atlas design system.
/// Use these instead of hardcoding Color values throughout the app.
class AppColors {
  AppColors._();

  // ── Primary ──
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primaryLight = Color(0xFFEFF6FF);

  // ── Background ──
  static const Color background = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);
  static const Color inputBackground = Color(0xFFF8FAFC);

  // ── Text ──
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFFCBD5E1);

  // ── Border ──
  static const Color border = Color(0xFFE2E8F0);
  static const Color borderStrong = Color(0xFFCBD5E1);

  // ── Semantic ──
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFFF0FDF4);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);

  static const Color danger = Color(0xFFDC2626);
  static const Color dangerLight = Color(0xFFFEF2F2);

  // ── Decisions / Voting ──
  static const Color violet = Color(0xFF7C3AED);
  static const Color violetLight = Color(0xFFF5F3FF);

  // ── Proposal category colors ──
  static const Color categoryDestination = Color(0xFF8B5CF6);
  static const Color categoryDates = Color(0xFF10B981);
  static const Color categoryAccommodation = Color(0xFFF59E0B);
  static const Color categoryActivity = Color(0xFFEC4899);
  static const Color categoryDefault = Color(0xFF64748B);

  // ── Surface helpers ──
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);
}
