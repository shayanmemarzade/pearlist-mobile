import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';

/// "Nothing on the list yet" / "Your list is ready" (Figma: "List page -
/// Empty state" and "List page is ready - Empty state").
class ListEmptyState extends StatelessWidget {
  const ListEmptyState({
    super.key,
    required this.justCreated,
    required this.onAdd,
    this.title,
    this.message,
    this.buttonLabel,
  });

  /// Shows the welcome copy for a list that was just created.
  final bool justCreated;
  final VoidCallback onAdd;

  /// Overrides for wish and place lists.
  final String? title;
  final String? message;
  final String? buttonLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(AppImages.emptyList, width: 59, height: 82),
            const SizedBox(height: 24),
            Text(
              title ??
                  (justCreated
                      ? 'Your list is ready'
                      : 'Nothing on the list yet'),
              style: AppTextStyles.heading3Bold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message ??
                  (justCreated
                      ? 'Add your first item below. Anything you add shows up '
                          'for everyone you share with, sorted by aisle.'
                      : 'Tap below to add your first item. We’ll sort '
                          'everything by aisle for you.'),
              style:
                  AppTextStyles.body1Regular.copyWith(color: AppColors.body2),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              label: buttonLabel ?? 'Add your first item',
              variant: AppButtonVariant.greenOutline,
              icon: SvgPicture.asset(AppIcons.plusGreen, width: 18, height: 18),
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}
