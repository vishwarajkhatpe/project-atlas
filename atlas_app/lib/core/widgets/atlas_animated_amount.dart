import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A widget that smoothly animates currency/numeric value transitions
/// over a specified duration with custom easing.
class AtlasAnimatedAmount extends StatelessWidget {
  final double value;
  final Duration duration;
  final Curve curve;
  final TextStyle? style;
  final String prefix;
  final int fractionDigits;

  const AtlasAnimatedAmount({
    super.key,
    required this.value,
    this.duration = const Duration(milliseconds: 2500),
    this.curve = Curves.easeOutCubic,
    this.style,
    this.prefix = '₹',
    this.fractionDigits = 2,
  });

  String _formatValue(double val) {
    try {
      final formatter = NumberFormat.currency(
        symbol: prefix,
        decimalDigits: fractionDigits,
        locale: 'en_IN',
      );
      return formatter.format(val);
    } catch (_) {
      return '$prefix${val.toStringAsFixed(fractionDigits)}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: value),
      duration: duration,
      curve: curve,
      builder: (context, animatedVal, child) {
        return Text(
          _formatValue(animatedVal),
          style: style,
        );
      },
    );
  }
}
