import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Opens a Pear List bottom sheet: dimmed overlay, sized to its content,
/// lifted by the keyboard.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    elevation: 0,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.overlay,
    builder: builder,
  );
}

/// The sheet surface (Figma: "Bottom sheet"): background colour, 24px top
/// corners, scrolling content and an optional pinned bottom bar.
class AppSheetFrame extends StatelessWidget {
  const AppSheetFrame({
    super.key,
    required this.child,
    this.bottomBar,
    this.padding = const EdgeInsets.fromLTRB(16, 24, 16, 32),
  });

  final Widget child;
  final Widget? bottomBar;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final bottomBar = this.bottomBar;
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(padding: padding, child: child),
            ),
            ?bottomBar,
          ],
        ),
      ),
    );
  }
}

/// Centred title (and optional subtitle) with a close button on the right
/// and an optional 32px action on the left (Figma: "Item Details Header").
class AppSheetHeader extends StatelessWidget {
  const AppSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.onClose,
  });

  final String title;
  final String? subtitle;
  final Widget? leading;

  /// Defaults to closing the sheet.
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 32,
          height: 32,
          child: Align(alignment: Alignment.topLeft, child: leading),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            children: [
              Text(
                title,
                style: AppTextStyles.titleBold,
                textAlign: TextAlign.center,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.body2Regular,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 20),
        SheetCloseButton(onPressed: onClose),
      ],
    );
  }
}

/// The ⓧ icon button used in sheet headers.
class SheetCloseButton extends StatelessWidget {
  const SheetCloseButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Close',
      child: InkResponse(
        onTap: onPressed ?? () => Navigator.of(context).pop(),
        radius: 20,
        child: SvgPicture.asset(AppIcons.closeCircle, width: 24, height: 24),
      ),
    );
  }
}
