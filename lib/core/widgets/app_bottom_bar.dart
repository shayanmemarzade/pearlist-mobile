import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Pinned bar for a page's main action (Figma: "Container" / "Action bar").
///
/// With the keyboard closed it has a top hairline and clears the home
/// indicator; with the keyboard open it floats on top of it with a shadow and
/// rounded top corners.
class AppBottomBar extends StatelessWidget {
  const AppBottomBar({
    super.key,
    required this.child,
    required this.keyboardOpen,
  });

  final Widget child;

  /// Pass `MediaQuery.viewInsetsOf(context).bottom > 0` read *above* any
  /// Scaffold, which hides the keyboard inset from its body.
  final bool keyboardOpen;

  static double _bottomPadding(BuildContext context, bool keyboardOpen) =>
      keyboardOpen
          ? 20
          : math.max(MediaQuery.viewPaddingOf(context).bottom, 16.0);

  /// Height of a bar holding one 46px button — used to lift toasts above it.
  static double heightOf(BuildContext context, {bool keyboardOpen = false}) =>
      (keyboardOpen ? 12 : 16) + 46 + _bottomPadding(context, keyboardOpen);

  @override
  Widget build(BuildContext context) {
    final padding = EdgeInsets.fromLTRB(
      16,
      keyboardOpen ? 12 : 16,
      16,
      _bottomPadding(context, keyboardOpen),
    );
    return Container(
      padding: padding,
      decoration: keyboardOpen
          ? const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              boxShadow: [
                BoxShadow(color: AppColors.shadowActionBar, blurRadius: 10),
              ],
            )
          : const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.borderGrayLight)),
            ),
      child: child,
    );
  }
}
