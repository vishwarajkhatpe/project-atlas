import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

/// A consistent card used throughout the Atlas app.
/// Apple-style clean, solid, rounded elevated surface with tactile spring micro-interactions.
class AtlasCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? backgroundColor;
  final Border? border;

  const AtlasCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.border,
  });

  @override
  State<AtlasCard> createState() => _AtlasCardState();
}

class _AtlasCardState extends State<AtlasCard> {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      setState(() => _isPressed = true);
    }
  }

  void _onTapUp(TapUpDetails details) {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  void _onTapCancel() {
    if (_isPressed) {
      setState(() => _isPressed = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardContent = Padding(
      padding: widget.padding ?? const EdgeInsets.all(AppSpacing.md),
      child: widget.child,
    );

    final boxDecoration = BoxDecoration(
      color: widget.backgroundColor ?? AppColors.cardBg(context),
      borderRadius: AppRadii.cardRadius,
      border: widget.border ??
          Border.all(
            color: AppColors.brd(context).withValues(alpha: 0.6),
            width: 1,
          ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: AppColors.isDark(context) ? 0.2 : 0.04),
          blurRadius: _isPressed ? 6 : 14,
          offset: Offset(0, _isPressed ? 1 : 3),
          spreadRadius: 0,
        ),
      ],
    );

    if (widget.onTap != null || widget.onLongPress != null) {
      return GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        child: AnimatedScale(
          scale: _isPressed ? 0.98 : 1.0,
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          child: Container(
            decoration: boxDecoration,
            child: Material(
              color: Colors.transparent,
              borderRadius: AppRadii.cardRadius,
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                onTap: widget.onTap != null
                    ? () {
                        HapticFeedback.lightImpact();
                        widget.onTap!();
                      }
                    : null,
                onLongPress: widget.onLongPress != null
                    ? () {
                        HapticFeedback.mediumImpact();
                        widget.onLongPress!();
                      }
                    : null,
                borderRadius: AppRadii.cardRadius,
                splashColor: AppColors.primaryAccent(context).withValues(alpha: 0.08),
                highlightColor: AppColors.primaryAccent(context).withValues(alpha: 0.04),
                child: cardContent,
              ),
            ),
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

