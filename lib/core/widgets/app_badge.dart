import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Small pill label (Figma: "Badgs").
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.text,
    required this.background,
    required this.foreground,
  });

  /// Orange "URGENT" badge.
  const AppBadge.urgent({super.key})
      : text = 'URGENT',
        background = AppColors.warning50,
        foreground = AppColors.textWarning;

  /// Grey "Owner" badge.
  const AppBadge.owner({super.key})
      : text = 'Owner',
        background = AppColors.surfaceGray,
        foreground = AppColors.badgeGrayText;

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
      ),
      child: Text(text, style: AppTextStyles.badge.copyWith(color: foreground)),
    );
  }
}
