import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

/// A consistent card used throughout the Atlas app.
/// Apple-style clean, solid, rounded elevated surface.
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
      color: AppColors.cardBg(context),
      borderRadius: AppRadii.cardRadius,
      border: Border.all(
        color: AppColors.brd(context).withValues(alpha: 0.5),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04), // Softer shadow
          blurRadius: 12,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ],
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
