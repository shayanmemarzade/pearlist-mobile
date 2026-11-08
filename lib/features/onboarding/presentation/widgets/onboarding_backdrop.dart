import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Soft colour glow at the top of the sign-up screens (Figma: three
/// ellipses with a 174 layer blur). Positions are from the 393pt frame and
/// scale with the screen width.
class OnboardingBackdrop extends StatelessWidget {
  const OnboardingBackdrop({
    super.key,
    this.right = AppColors.sage,
    this.middle = AppColors.sand,
    this.left = AppColors.sage,
  });

  /// Paywall colours (Figma: green, umber, green on dark green).
  const OnboardingBackdrop.paywall({super.key})
      : right = AppColors.primary,
        middle = AppColors.umber,
        left = AppColors.primary;

  final Color right;
  final Color middle;
  final Color left;

  static const double _frameWidth = 393;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final k = constraints.maxWidth / _frameWidth;
            Widget ellipse(double x, double y, double w, double h, Color c) =>
                Positioned(
                  left: x * k,
                  top: y * k,
                  width: w * k,
                  height: h * k,
                  child: DecoratedBox(
                    decoration: ShapeDecoration(
                      color: c,
                      shape: const OvalBorder(),
                    ),
                  ),
                );
            return ClipRect(
              child: ImageFiltered(
                // Figma's layer blur 174 ≈ a Gaussian with σ ≈ 87.
                imageFilter: ImageFilter.blur(
                  sigmaX: 87 * k,
                  sigmaY: 87 * k,
                  tileMode: TileMode.decal,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    ellipse(274, -126, 196, 198, right),
                    ellipse(-8, -174, 410, 247, middle),
                    ellipse(-36, -146, 196, 198, left),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
