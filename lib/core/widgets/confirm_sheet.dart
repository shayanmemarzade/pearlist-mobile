import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_bottom_bar.dart';
import 'app_button.dart';
import 'app_sheet.dart';

/// "Are you sure?" sheet with a black confirm button and a Cancel outline
/// button (Figma: "Confirmation"). Resolves to true when confirmed.
Future<bool> showConfirmSheet(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
}) async {
  final confirmed = await showAppSheet<bool>(
    context,
    builder: (context) => AppSheetFrame(
      bottomBar: AppBottomBar(
        keyboardOpen: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: confirmLabel,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: cancelLabel,
              variant: AppButtonVariant.outline,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetHeader(title: title),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.body1Regular
                  .copyWith(color: AppColors.typographyTertiary),
            ),
          ),
        ],
      ),
    ),
  );
  return confirmed ?? false;
}
