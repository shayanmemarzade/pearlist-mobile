import 'package:flutter/material.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_link_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../onboarding/presentation/widgets/onboarding_scaffold.dart';

/// Explains why the app wants contacts before the OS prompt (Figma "Setup
/// and invite Partner" bottom sheet). Resolves to true on "Allow access".
Future<bool> showContactsPermissionSheet(BuildContext context) async {
  final allowed = await showAppSheet<bool>(
    context,
    builder: (context) => AppSheetFrame(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      bottomBar: AppBottomBar(
        keyboardOpen: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: 'Allow access',
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 12),
            AppLinkButton(
              label: 'Not now',
              color: AppColors.headingBlack,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: SheetCloseButton(),
          ),
          const Center(child: FadedIllustration(AppImages.contacts)),
          const SizedBox(height: 16),
          Text(
            'Find your partner in contacts',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleBold,
          ),
          const SizedBox(height: 8),
          Text(
            'Pear List only uses your contacts to fill in an email or phone '
            'number. Nothing is uploaded or stored.',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1Regular
                .copyWith(color: AppColors.typographyTertiary),
          ),
        ],
      ),
    ),
  );
  return allowed ?? false;
}
