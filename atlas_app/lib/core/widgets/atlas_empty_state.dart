import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Reusable empty state with icon, title, subtitle, and CTA buttons.
class AtlasEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const AtlasEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final pLabel = primaryLabel;
    final sLabel = secondaryLabel;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 56,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.sectionTitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: AppTextStyles.secondary,
              textAlign: TextAlign.center,
            ),
            if (pLabel != null) ...[
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: 200,
                height: 48,
                child: ElevatedButton(
                  onPressed: onPrimary,
                  child: Text(pLabel),
                ),
              ),
            ],
            if (sLabel != null) ...[
              const SizedBox(height: AppSpacing.smd),
              TextButton(
                onPressed: onSecondary,
                child: Text(sLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
