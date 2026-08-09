import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

/// A consistent card used throughout the Atlas app.
/// White surface, subtle border, rounded corners.
class AtlasCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AtlasCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      child: child,
    );

    final boxDecoration = BoxDecoration(
      color: AppColors.card,
      borderRadius: AppRadii.cardRadius,
      border: Border.all(color: AppColors.border, width: 1),
    );

    if (onTap != null) {
      return Container(
        decoration: boxDecoration,
        child: Material(
          color: Colors.transparent,
          borderRadius: AppRadii.cardRadius,
          clipBehavior: Clip.hardEdge,
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTap!();
            },
            borderRadius: AppRadii.cardRadius,
            child: cardContent,
          ),
        ),
      );
    }

    return Container(
      decoration: boxDecoration,
      child: cardContent,
    );
  }
}
