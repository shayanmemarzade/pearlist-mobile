import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_card.dart';

/// Grey label above a group card (Figma: "Text and supporting text").
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style:
                  AppTextStyles.body2Medium.copyWith(color: AppColors.body2),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// White card whose rows are separated by 16px + hairline + 16px
/// (Figma: "Select container").
class GroupedCard extends StatelessWidget {
  const GroupedCard({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(16),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) ...const [
              SizedBox(height: 16),
              AppDivider(),
              SizedBox(height: 16),
            ],
            children[i],
          ],
        ],
      ),
    );
  }
}

/// Icon, title, optional subtitle and trailing control (Figma: "List items"
/// in settings and sharing).
class AppListRow extends StatelessWidget {
  const AppListRow({
    super.key,
    required this.title,
    this.leading,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final String title;
  final Widget? leading;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final leading = this.leading;
    final subtitle = this.subtitle;
    final trailing = this.trailing;

    return MergeSemantics(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            if (leading != null) ...[leading, const SizedBox(width: 8)],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppTextStyles.body1Medium),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: AppTextStyles.body2Regular
                          .copyWith(color: AppColors.typographyQuaternary),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[const SizedBox(width: 8), trailing],
          ],
        ),
      ),
    );
  }
}
