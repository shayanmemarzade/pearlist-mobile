import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Green confirmation toast with an optional "Undo" button
/// (Figma: "Push notification").
///
/// [bottomOffset] lifts it above a page's bottom bar.
void showAppToast(
  BuildContext context, {
  required String message,
  VoidCallback? onUndo,
  double bottomOffset = 16,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        padding: EdgeInsets.zero,
        margin: EdgeInsets.fromLTRB(16, 0, 16, bottomOffset),
        duration: const Duration(seconds: 4),
        content: _Toast(
          message: message,
          onUndo: onUndo == null
              ? null
              : () {
                  messenger.hideCurrentSnackBar();
                  onUndo();
                },
        ),
      ),
    );
}

class _Toast extends StatelessWidget {
  const _Toast({required this.message, this.onUndo});

  final String message;
  final VoidCallback? onUndo;

  @override
  Widget build(BuildContext context) {
    final onUndo = this.onUndo;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.toastFill,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: AppColors.primary200),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowMedium,
            offset: Offset(0, 6),
            blurRadius: 16,
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.asset(AppIcons.infoBadge, width: 20, height: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: AppTextStyles.body2Medium)),
          if (onUndo != null) ...[
            const SizedBox(width: 10),
            Material(
              color: AppColors.background,
              shape: const StadiumBorder(
                side: BorderSide(color: AppColors.buttonBlack),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onUndo,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Text('Undo', style: AppTextStyles.body2Medium),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
