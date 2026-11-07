import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// The 46px white box shared by text inputs and selects (Figma: "Input").
class AppInputShell extends StatelessWidget {
  const AppInputShell({
    super.key,
    required this.child,
    this.borderColor = AppColors.borderGrayLight,
  });

  final Widget child;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppColors.surfaceForeground,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: borderColor),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSmall,
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Field label above an input (Figma: "Input with label", 6px gap).
class AppFieldLabel extends StatelessWidget {
  const AppFieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppTextStyles.body2Medium),
    );
  }
}
