import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AnimatedChatBackground extends StatefulWidget {
  const AnimatedChatBackground({super.key});

  @override
  State<AnimatedChatBackground> createState() => _AnimatedChatBackgroundState();
}

class _AnimatedChatBackgroundState extends State<AnimatedChatBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.bg(context),
                AppColors.primaryAccent(context).withValues(alpha: 0.05),
                AppColors.bg(context),
                AppColors.primaryAccent(context).withValues(alpha: 0.08),
              ],
              stops: [
                0.0,
                0.3 + (_controller.value * 0.2),
                0.7 - (_controller.value * 0.2),
                1.0,
              ],
            ),
          ),
          child: Opacity(
            opacity: 0.03, // extremely subtle map-like texture overlay
            child: CustomPaint(
              painter: _TopographyPainter(),
              size: Size.infinite,
            ),
          ),
        );
      },
    );
  }
}

class _TopographyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
      
    // Draw some bezier curves for a faint topography vibe
    for (int i = 0; i < 10; i++) {
      final path = Path();
      path.moveTo(0, size.height * (i / 10));
      path.quadraticBezierTo(
        size.width * 0.5, size.height * ((i + 2) / 10),
        size.width, size.height * ((i - 1) / 10),
      );
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
