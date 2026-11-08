import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_back_link.dart';
import '../../../../core/widgets/glass_surface.dart';

/// "← Home", the list name and the ••• settings button
/// (Figma: "Top Bar" on the list page).
class ListTopBar extends StatelessWidget {
  const ListTopBar({
    super.key,
    required this.title,
    required this.onMenu,
    this.backLabel = 'Home',
  });

  final String title;
  final VoidCallback onMenu;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBackLink(label: backLabel),
          const SizedBox(height: 8),
          SizedBox(
            height: 38,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.titleBold
                        .copyWith(color: AppColors.headingBlack),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                GlassIconButton(
                  tooltip: 'List settings',
                  onPressed: onMenu,
                  icon: SvgPicture.asset(AppIcons.more, width: 18, height: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
