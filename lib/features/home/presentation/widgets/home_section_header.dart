import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';

/// Section title with an optional link button on the right
/// (Figma: "Text and supporting text").
class HomeSectionHeader extends StatelessWidget {
  const HomeSectionHeader({super.key, required this.title, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.body1Bold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        ?action,
      ],
    );
  }
}
