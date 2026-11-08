import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// 40px green button with an icon and label (Figma: "Button" primary,
/// e.g. "+ Add item").
class AppCompactButton extends StatelessWidget {
  const AppCompactButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  /// Stretch to the available width with the content centred.
  final bool expand;

  static const BorderRadius _radius = BorderRadius.all(Radius.circular(12));

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: onPressed != null ? 1 : 0.4,
      child: Material(
        color: AppColors.buttonPrimary,
        borderRadius: _radius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            height: 40,
            width: expand ? double.infinity : null,
            alignment: expand ? Alignment.center : null,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            // Same inner-shadow stand-in as AppButton (white 30%, y: 3,
            // blur: 6): a short highlight gradient at the top edge.
            foregroundDecoration: const BoxDecoration(
              borderRadius: _radius,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0x4DFFFFFF), Color(0x00FFFFFF)],
                stops: [0, 0.25],
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[icon!, const SizedBox(width: 8)],
                Text(
                  label,
                  style: AppTextStyles.body2Medium
                      .copyWith(color: AppColors.textOnButton),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
