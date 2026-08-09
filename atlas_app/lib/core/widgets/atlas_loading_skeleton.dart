import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

/// Shimmer-animated skeleton loader shapes.
class AtlasLoadingSkeleton extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const AtlasLoadingSkeleton({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.borderRadius = AppRadii.medium,
  });

  /// Card-shaped skeleton
  const AtlasLoadingSkeleton.card({super.key})
      : width = double.infinity,
        height = 120,
        borderRadius = AppRadii.card;

  /// Text line skeleton
  const AtlasLoadingSkeleton.text({super.key, this.width = 200})
      : height = 14,
        borderRadius = AppRadii.small;

  /// Circle skeleton (avatar)
  const AtlasLoadingSkeleton.circle({super.key, double size = 40})
      : width = size,
        height = size,
        borderRadius = 999;

  @override
  State<AtlasLoadingSkeleton> createState() => _AtlasLoadingSkeletonState();
}

class _AtlasLoadingSkeletonState extends State<AtlasLoadingSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                AppColors.shimmerBase,
                AppColors.shimmerHighlight,
                AppColors.shimmerBase,
              ],
            ),
          ),
        );
      },
    );
  }
}

/// A pre-built skeleton list for loading screens.
class AtlasSkeletonList extends StatelessWidget {
  final int itemCount;

  const AtlasSkeletonList({super.key, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppSpacing.xl),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppRadii.cardRadius,
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const AtlasLoadingSkeleton.circle(size: 40),
                    const SizedBox(width: AppSpacing.smd),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          AtlasLoadingSkeleton(height: 14, width: 140),
                          SizedBox(height: AppSpacing.sm),
                          AtlasLoadingSkeleton(height: 12, width: 100),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                const AtlasLoadingSkeleton(height: 12),
                const SizedBox(height: AppSpacing.sm),
                const AtlasLoadingSkeleton(height: 12, width: 200),
              ],
            ),
          ),
        );
      },
    );
  }
}
