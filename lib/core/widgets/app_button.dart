import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum AppButtonVariant {
  /// Black filled button (Figma: Button / Primary / Filled / Large).
  primary,

  /// Green filled button (Figma: Button/Primary/Default, e.g. "Mark as bought").
  green,

  /// Black outline on the background color ("Sign In", "Cancel").
  outline,

  /// Green outline ("Add item", "Clear bought items", "Invite a partner").
  greenOutline,
}

/// Full-width, 46px-tall pill button from the Figma design system.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;

  /// Optional 18px icon before the label.
  final Widget? icon;

  static const double _height = 46;
  static const BorderRadius _radius = BorderRadius.all(Radius.circular(32));

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final filled = variant == AppButtonVariant.primary ||
        variant == AppButtonVariant.green;

    // Figma "State=Disabled" for filled buttons: light grey fill and grey
    // label. Outline buttons just fade.
    final disabledFilled = filled && !enabled;

    final Color background;
    final Color foreground;
    BorderSide side = BorderSide.none;
    switch (variant) {
      case AppButtonVariant.primary:
        background = AppColors.buttonBlack;
        foreground = AppColors.textOnButton;
      case AppButtonVariant.green:
        background = AppColors.buttonPrimary;
        foreground = AppColors.textOnButton;
      case AppButtonVariant.outline:
        background = AppColors.background;
        foreground = AppColors.headingBlack;
        side = const BorderSide(color: AppColors.buttonBlack);
      case AppButtonVariant.greenOutline:
        background = AppColors.background;
        foreground = AppColors.buttonPrimary;
        side = const BorderSide(color: AppColors.buttonPrimary);
    }

    return Opacity(
      opacity: enabled || filled ? 1 : 0.4,
      child: Material(
        color: disabledFilled ? AppColors.buttonBlackDisable : background,
        shape: RoundedRectangleBorder(borderRadius: _radius, side: side),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            width: double.infinity,
            height: _height,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            // Figma uses an inner shadow (white 30%, y: 3, blur: 6) on the
            // filled buttons. Flutter has no inset shadow, so a short top
            // highlight gradient reproduces the same look.
            foregroundDecoration: filled && enabled
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body1Medium.copyWith(
                      color: disabledFilled
                          ? AppColors.textDisable
                          : foreground,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Red text button with a trash icon (Figma: "Clear entire list").
class AppDangerTextButton extends StatelessWidget {
  const AppDangerTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[icon!, const SizedBox(width: 8)],
            Text(
              label,
              style: AppTextStyles.body1Medium.copyWith(color: AppColors.error),
            ),
          ],
        ),
      ),
    );
  }
}
