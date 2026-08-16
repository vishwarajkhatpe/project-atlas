import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_text_styles.dart';

/// Consistent avatar with initials fallback.
class AtlasAvatar extends StatelessWidget {
  final String name;
  final double radius;
  final String? imageUrl;

  const AtlasAvatar({
    super.key,
    required this.name,
    this.radius = 20,
    this.imageUrl,
  });

  /// Small (16px radius)
  const AtlasAvatar.small({
    super.key,
    required this.name,
    this.imageUrl,
  }) : radius = 16;

  /// Medium (20px radius)
  const AtlasAvatar.medium({
    super.key,
    required this.name,
    this.imageUrl,
  }) : radius = 20;

  /// Large (24px radius)
  const AtlasAvatar.large({
    super.key,
    required this.name,
    this.imageUrl,
  }) : radius = 24;

  String get _initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Color get _backgroundColor {
    final hash = name.hashCode.abs();
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1, hue, 0.4, 0.9).toColor();
  }

  Color get _textColor {
    final hash = name.hashCode.abs();
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1, hue, 0.6, 0.35).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    final hasImage = url != null && url.trim().isNotEmpty;

    Widget placeholder = Text(
      _initials,
      style: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: radius * 0.7,
        fontWeight: FontWeight.w600,
        color: _textColor,
      ),
    );

    return CircleAvatar(
      radius: radius,
      backgroundColor: _backgroundColor,
      child: hasImage
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: url!,
                width: radius * 2,
                height: radius * 2,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => placeholder,
              ),
            )
          : placeholder,
    );
  }
}
