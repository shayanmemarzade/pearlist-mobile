import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'snap_away.dart';

/// White rounded container with a light border (Figma: "Select container").
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  static const BorderRadius radius = BorderRadius.all(Radius.circular(16));

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceForeground,
      shape: const RoundedRectangleBorder(
        borderRadius: radius,
        side: BorderSide(color: AppColors.borderGrayLight),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

/// 1px divider used inside cards (Figma: "Line 11").
class AppDivider extends StatelessWidget {
  const AppDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 1,
      width: double.infinity,
      child: ColoredBox(color: AppColors.borderGrayLight),
    );
  }
}

/// 16px · hairline · 16px between rows in a card. Set [closing] to fold it
/// away in step with a [SnapAway] (when the row next to it crumbles).
class RowDivider extends StatelessWidget {
  const RowDivider({super.key, this.closing = false});

  final bool closing;

  /// 16 + 1 + 16.
  static const double height = 33;

  @override
  Widget build(BuildContext context) {
    // A row being dragged leaves its divider behind (see [RowDragProxy]).
    if (RowDragProxy.isIn(context)) return const SizedBox.shrink();
    return AnimatedSize(
      duration: SnapAway.duration,
      curve: SnapAway.collapseCurve,
      alignment: Alignment.topCenter,
      child: closing
          ? const SizedBox(width: double.infinity)
          : const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 16),
                AppDivider(),
                SizedBox(height: 16),
              ],
            ),
    );
  }
}

/// Marks the floating copy of a row while it's dragged in a
/// [ReorderableListView], so its [RowDivider] isn't carried along.
class RowDragProxy extends InheritedWidget {
  const RowDragProxy({super.key, required super.child});

  // `depend…` rather than `get…`: the list moves the row's existing
  // widgets into the drag overlay (they're under a GlobalKey) instead of
  // building new ones, and only a registered dependency makes them rebuild
  // when they land under (or leave) this widget.
  static bool isIn(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RowDragProxy>() != null;

  @override
  bool updateShouldNotify(RowDragProxy oldWidget) => false;
}
