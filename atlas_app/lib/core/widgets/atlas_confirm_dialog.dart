import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reusable confirmation dialog with contextual information.
class AtlasConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;
  final VoidCallback? onConfirm;

  const AtlasConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
    this.onConfirm,
  });

  /// Show the dialog and return true if confirmed.
  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    HapticFeedback.lightImpact();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AtlasConfirmDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
        onConfirm: () {
          if (isDestructive) {
            HapticFeedback.mediumImpact();
          }
          Navigator.of(context).pop(true);
        },
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final confirmColor = isDestructive ? AppColors.danger : AppColors.primary;

    return AlertDialog(
      title: Text(
        title,
        style: AppTextStyles.sectionTitle,
      ),
      content: Text(
        content,
        style: AppTextStyles.body.copyWith(color: AppColors.textSecondary),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(
            cancelText,
            style: AppTextStyles.button.copyWith(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: onConfirm ?? () => Navigator.of(context).pop(true),
          child: Text(
            confirmText,
            style: AppTextStyles.button.copyWith(color: confirmColor),
          ),
        ),
      ],
    );
  }
}
