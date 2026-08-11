import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  // ── Legacy accessors ──
  static const Color primaryAccent = AppColors.primary;
  static const Color background = AppColors.background;
  static const Color surface = AppColors.card;
  static const Color secondarySurface = AppColors.inputBackground;
  static const Color primaryText = AppColors.textPrimary;
  static const Color secondaryText = AppColors.textSecondary;
  static const Color border = AppColors.border;
  static const Color success = AppColors.success;
  static const Color warning = AppColors.warning;
  static const Color danger = AppColors.danger;

  // ── Light Theme ──
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.light().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.primaryDark,
        secondary: AppColors.primary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.primaryLight,
        onSecondaryContainer: AppColors.primaryDark,
        error: AppColors.danger,
        onError: Colors.white,
        errorContainer: AppColors.dangerLight,
        surface: AppColors.card,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.border,
        outlineVariant: AppColors.borderStrong,
      ),
      textTheme: baseTextTheme.copyWith(
        displaySmall: baseTextTheme.displaySmall?.copyWith(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3),
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4),
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.4),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textPrimary, height: 1.5),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.textSecondary, height: 1.5),
        bodySmall: baseTextTheme.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted, height: 1.4),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 20),
        titleTextStyle: AppTextStyles.sectionTitle.copyWith(color: AppColors.textPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppRadii.buttonHeight),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd, horizontal: AppSpacing.xl),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.buttonRadius),
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.border, width: 1),
          minimumSize: const Size(double.infinity, AppRadii.buttonHeight),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd, horizontal: AppSpacing.xl),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.buttonRadius),
          textStyle: AppTextStyles.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.inputBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        border: OutlineInputBorder(borderRadius: AppRadii.buttonRadius, borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: AppRadii.buttonRadius, borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: AppRadii.buttonRadius, borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
        hintStyle: AppTextStyles.secondary,
        labelStyle: AppTextStyles.secondary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardRadius,
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.card,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.largeRadius),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.card,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.large))),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.card,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 0),
    );
  }

  // ── Dark Theme ──
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.darkPrimary,
        onPrimary: Colors.white,
        primaryContainer: AppColors.darkPrimaryLight,
        onPrimaryContainer: Colors.white,
        secondary: AppColors.darkPrimary,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.darkPrimaryLight,
        onSecondaryContainer: Colors.white,
        error: AppColors.danger,
        onError: Colors.white,
        errorContainer: Color(0xFF7F1D1D),
        surface: AppColors.darkCard,
        onSurface: AppColors.darkTextPrimary,
        onSurfaceVariant: AppColors.darkTextSecondary,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkBorderStrong,
      ),
      textTheme: baseTextTheme.copyWith(
        displaySmall: baseTextTheme.displaySmall?.copyWith(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary, height: 1.3),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary, height: 1.3),
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary, height: 1.4),
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary, height: 1.4),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.darkTextPrimary, height: 1.5),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(fontSize: 13, fontWeight: FontWeight.w400, color: AppColors.darkTextSecondary, height: 1.5),
        bodySmall: baseTextTheme.bodySmall?.copyWith(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.darkTextMuted, height: 1.4),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.darkTextPrimary, size: 20),
        titleTextStyle: AppTextStyles.sectionTitle.copyWith(color: AppColors.darkTextPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, AppRadii.buttonHeight),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd, horizontal: AppSpacing.xl),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.buttonRadius),
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary,
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
          minimumSize: const Size(double.infinity, AppRadii.buttonHeight),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.smd, horizontal: AppSpacing.xl),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.buttonRadius),
          textStyle: AppTextStyles.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkInputBackground,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
        border: OutlineInputBorder(borderRadius: AppRadii.buttonRadius, borderSide: const BorderSide(color: AppColors.darkBorder)),
        enabledBorder: OutlineInputBorder(borderRadius: AppRadii.buttonRadius, borderSide: const BorderSide(color: AppColors.darkBorder)),
        focusedBorder: OutlineInputBorder(borderRadius: AppRadii.buttonRadius, borderSide: const BorderSide(color: AppColors.darkPrimary, width: 1.5)),
        hintStyle: AppTextStyles.secondary.copyWith(color: AppColors.darkTextSecondary),
        labelStyle: AppTextStyles.secondary.copyWith(color: AppColors.darkTextSecondary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.cardRadius,
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkCard,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.largeRadius),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.large))),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.darkCard,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.cardRadius),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.darkBorder, thickness: 1, space: 0),
    );
  }
}
