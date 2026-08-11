import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography hierarchy using Plus Jakarta Sans.
/// Styles allow default text color inheritance for automatic Light & Dark mode adaptation.
class AppTextStyles {
  AppTextStyles._();

  static String? _fontFamily;
  static String get fontFamily {
    _fontFamily ??= GoogleFonts.plusJakartaSans().fontFamily;
    return _fontFamily!;
  }

  // ── Page title ──
  static TextStyle pageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  // ── Section title ──
  static TextStyle sectionTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ── Card title ──
  static TextStyle cardTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // ── Body ──
  static TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  // ── Secondary ──
  static TextStyle secondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ── Caption ──
  static TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textMuted,
    height: 1.4,
  );

  // ── Button ──
  static TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  // ── Large numeric ──
  static TextStyle largeNumeric = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  // ── Context-Adaptive TextStyles ──
  static TextStyle pageTitleOf(BuildContext context) =>
      pageTitle.copyWith(color: AppColors.txtPrimary(context));

  static TextStyle sectionTitleOf(BuildContext context) =>
      sectionTitle.copyWith(color: AppColors.txtPrimary(context));

  static TextStyle cardTitleOf(BuildContext context) =>
      cardTitle.copyWith(color: AppColors.txtPrimary(context));

  static TextStyle bodyOf(BuildContext context) =>
      body.copyWith(color: AppColors.txtPrimary(context));

  static TextStyle secondaryOf(BuildContext context) =>
      secondary.copyWith(color: AppColors.txtSecondary(context));

  static TextStyle captionOf(BuildContext context) =>
      caption.copyWith(color: AppColors.txtMuted(context));
}
