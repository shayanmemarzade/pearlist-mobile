import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant {
  /// Black filled button (Figma: Button / Primary / Filled / Large).
  primary,

  /// Outlined button on the background color (used for "Sign In").
  outline,
}

/// Full-width, 46px-tall pill button from the Figma design system.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  static const double _height = 46;
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(32));

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == AppButtonVariant.primary;
    final enabled = onPressed != null;

    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: Material(
        color: isPrimary ? AppColors.buttonBlack : AppColors.background,
        shape: RoundedRectangleBorder(
          borderRadius: _radius,
          side: isPrimary
              ? BorderSide.none
              : const BorderSide(color: AppColors.buttonBlack),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            width: double.infinity,
            height: _height,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // Figma uses an inner shadow (white 30%, y: 3, blur: 6) on the
            // filled button. Flutter has no inset shadow, so a short top
            // highlight gradient reproduces the same look.
            foregroundDecoration: isPrimary
                ? const BoxDecoration(
                    borderRadius: _radius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x4DFFFFFF), Color(0x00FFFFFF)],
                      stops: [0, 0.25],
                    ),
                  )
                : null,
            child: Text(
              label,
              style: AppTextStyles.body1Medium.copyWith(
                color: isPrimary
                    ? AppColors.textOnButton
                    : AppColors.headingBlack,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
