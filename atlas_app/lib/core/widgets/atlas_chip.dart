import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// Status chips with semantic colors.
enum AtlasChipVariant {
  primary,
  success,
  warning,
  danger,
  violet,
  neutral,
}

class AtlasChip extends StatelessWidget {
  final String label;
  final AtlasChipVariant variant;
  final IconData? icon;

  const AtlasChip({
    super.key,
    required this.label,
    this.variant = AtlasChipVariant.neutral,
    this.icon,
  });

  /// Convenience constructors
  const AtlasChip.owner({super.key})
      : label = 'Owner',
        variant = AtlasChipVariant.primary,
        icon = null;

  const AtlasChip.member({super.key})
      : label = 'Member',
        variant = AtlasChipVariant.neutral,
        icon = null;

  const AtlasChip.open({super.key})
      : label = 'Open',
        variant = AtlasChipVariant.violet,
        icon = null;

  const AtlasChip.approved({super.key})
      : label = 'Approved',
        variant = AtlasChipVariant.success,
        icon = null;

  const AtlasChip.rejected({super.key})
      : label = 'Rejected',
        variant = AtlasChipVariant.danger,
        icon = null;

  const AtlasChip.pending({super.key})
      : label = 'Pending',
        variant = AtlasChipVariant.warning,
        icon = null;

  Color get _backgroundColor {
    switch (variant) {
      case AtlasChipVariant.primary:
        return AppColors.primaryLight;
      case AtlasChipVariant.success:
        return AppColors.successLight;
      case AtlasChipVariant.warning:
        return AppColors.warningLight;
      case AtlasChipVariant.danger:
        return AppColors.dangerLight;
      case AtlasChipVariant.violet:
        return AppColors.violetLight;
      case AtlasChipVariant.neutral:
        return AppColors.inputBackground;
    }
  }

  Color get _textColor {
    switch (variant) {
      case AtlasChipVariant.primary:
        return AppColors.primary;
      case AtlasChipVariant.success:
        return AppColors.success;
      case AtlasChipVariant.warning:
        return AppColors.warning;
      case AtlasChipVariant.danger:
        return AppColors.danger;
      case AtlasChipVariant.violet:
        return AppColors.violet;
      case AtlasChipVariant.neutral:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: AppRadii.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: _textColor),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _textColor,
            ),
          ),
        ],
      ),
    );
  }
}
