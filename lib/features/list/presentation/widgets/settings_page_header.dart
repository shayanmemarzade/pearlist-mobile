import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_back_link.dart';

/// Back link, title and description at the top of the list settings pages
/// (Figma: "Top Bar" on Manage aisles / stores and Sharing).
class SettingsPageHeader extends StatelessWidget {
  const SettingsPageHeader({
    super.key,
    required this.title,
    required this.description,
    this.backLabel = 'Back to list',
  });

  final String title;
  final String description;
  final String backLabel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppBackLink(label: backLabel),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.titleBold
                .copyWith(color: AppColors.headingBlack),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: AppTextStyles.body2Regular.copyWith(color: AppColors.body1),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
