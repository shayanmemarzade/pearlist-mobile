import 'dart:math' as math;
import 'dart:ui' show ImageFilter, Shadow;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Frosted "glass" surface used by the top bar actions and the bottom nav
/// (Figma: white 30% fill, glass effect, drop shadow 0/0/32 black 10%).
///
/// Figma draws the shadow only outside the shape, so it is painted with the
/// shape clipped out; a plain BoxShadow would grey out the translucent fill.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.radius = 999,
  });

  final Widget child;

  /// Corner radius; values larger than half the height give a pill/circle.
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _OuterShadowPainter(radius: radius),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: ColoredBox(color: AppColors.glassFill, child: child),
        ),
      ),
    );
  }
}

class _OuterShadowPainter extends CustomPainter {
  const _OuterShadowPainter({required this.radius});

  final double radius;

  static const double _blur = 32;

  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(radius, size.shortestSide / 2);
    final shape = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(r),
    );
    final outside = Path.combine(
      PathOperation.difference,
      Path()..addRect((Offset.zero & size).inflate(_blur * 2)),
      Path()..addRRect(shape),
    );
    canvas
      ..save()
      ..clipPath(outside)
      ..drawRRect(
        shape,
        Paint()
          ..color = AppColors.shadowSoft
          ..maskFilter = MaskFilter.blur(
            BlurStyle.normal,
            Shadow.convertRadiusToSigma(_blur),
          ),
      )
      ..restore();
  }

  @override
  bool shouldRepaint(_OuterShadowPainter oldDelegate) =>
      oldDelegate.radius != radius;
}

/// Round glass icon button (Figma: "Button", 10px padding around an 18px
/// icon in the top bar; 62px with a 24px icon next to the nav bar).
class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.size = 38,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: SizedBox.square(
        dimension: size,
        child: GlassSurface(
          radius: size / 2,
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Center(child: icon),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glass pill with a text label (Figma: "Skip" in the sign-up top bar).
class GlassTextButton extends StatelessWidget {
  const GlassTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.headingBlack,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: GlassSurface(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            customBorder: const StadiumBorder(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: AppTextStyles.body1Medium.copyWith(color: color),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
