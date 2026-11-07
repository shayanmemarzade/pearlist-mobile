import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// White rounded container with a light border (Figma: "Select container").
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  static const BorderRadius radius = BorderRadius.all(Radius.circular(16));

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceForeground,
      shape: const RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: AppColors.borderGrayLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// 1px divider used inside cards (Figma: "Line 11").
class AppDivider extends StatelessWidget {
  const AppDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 1,
      width: double.infinity,
      child: ColoredBox(color: AppColors.borderGrayLight),
    );
  }
}
