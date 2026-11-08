import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Card with a 2px multi-colour edge (Figma: the blurred colour ellipses
/// behind the Pro card, the invited-person cards and the inviter's avatar).
class GradientRing extends StatelessWidget {
  const GradientRing({
    super.key,
    required this.child,
    this.radius = 18,
    this.width = 2,
    this.color = AppColors.background,
    this.padding = const EdgeInsets.all(12),
    this.shape = BoxShape.rectangle,
  });

  final Widget child;

  /// Outer corner radius (the inner one is [radius] minus [width]).
  final double radius;
  final double width;

  /// Fill inside the ring.
  final Color color;
  final EdgeInsetsGeometry padding;

  /// [BoxShape.circle] for avatars.
  final BoxShape shape;

  static const Gradient gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF7D4C),
      Color(0xFF799B80),
      Color(0xFF00998E),
      Color(0xFF799B80),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final circle = shape == BoxShape.circle;
    return Container(
      padding: EdgeInsets.all(width),
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: circle ? null : BorderRadius.circular(radius),
        gradient: gradient,
      ),
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: color,
          shape: shape,
          borderRadius: circle ? null : BorderRadius.circular(radius - width),
        ),
        child: child,
      ),
    );
  }
}
