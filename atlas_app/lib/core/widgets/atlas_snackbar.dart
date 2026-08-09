import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Helper to show success/error snackbars with consistent styling.
class AtlasSnackbar {
  AtlasSnackbar._();

  static void success(BuildContext context, String message) {
    _show(context, message, AppColors.success, LucideIcons.check);
  }

  static void error(BuildContext context, String message) {
    _show(context, message, AppColors.danger, LucideIcons.circle_alert);
  }

  static void info(BuildContext context, String message) {
    _show(context, message, AppColors.primary, LucideIcons.info);
  }

  static void _show(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: AppSpacing.smd),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.body.copyWith(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.mediumRadius,
        ),
        margin: const EdgeInsets.all(AppSpacing.md),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
