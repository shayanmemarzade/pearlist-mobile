import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'glass_surface.dart';

enum AppNavTab {
  shopping('Shopping', AppIcons.navShopping),
  wishes('Wishes', AppIcons.navWishes),
  places('Places', AppIcons.navPlaces);

  const AppNavTab(this.label, this.icon);

  final String label;

  /// Tinted grey → black as the tab becomes selected.
  final String icon;
}

/// Floating bottom navigation (Figma: "Navbar Horizontal") — a glass pill
/// with the three tabs, plus a round glass "+" button beside it.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.selected,
    required this.onSelected,
    required this.onAddPressed,
  });

  final AppNavTab selected;
  final ValueChanged<AppNavTab> onSelected;
  final VoidCallback onAddPressed;

  static const double height = 62;

  /// Slide time of the white pill between tabs.
  static const Duration _slide = Duration(milliseconds: 350);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(
            child: GlassSurface(
              child: Padding(
                padding: const EdgeInsets.all(4),
                // Animates a "position" from the old tab index to the new
                // one; tab widths, the pill and the labels all follow it, so
                // the pill slides across instead of jumping.
                child: SizedBox(
                  height: 48, // 12px padding + 24px icon + 12px padding
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(end: selected.index.toDouble()),
                    duration: _slide,
                    curve: Curves.easeOutCubic,
                    builder: (context, position, _) => LayoutBuilder(
                      builder: (context, constraints) => _buildTabs(
                        position,
                        constraints.maxWidth,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GlassIconButton(
            size: height,
            tooltip: 'Add',
            onPressed: onAddPressed,
            icon: SvgPicture.asset(AppIcons.navPlus, width: 24, height: 24),
          ),
        ],
      ),
    );
  }

  static const double _gap = 8;

  /// How "selected" tab [index] is at [position]: 1 when the pill sits on
  /// it, 0 when it's a whole tab away.
  static double _closeness(int index, double position) =>
      (1 - (position - index).abs()).clamp(0.0, 1.0);

  Widget _buildTabs(double position, double maxWidth) {
    const tabs = AppNavTab.values;
    // Figma: selected item 95px wide, others 86px; widths blend while
    // the pill moves.
    final weights = [
      for (var i = 0; i < tabs.length; i++) 86 + 9 * _closeness(i, position),
    ];
    final total = weights.fold<double>(0, (a, b) => a + b);
    final available = maxWidth - _gap * (tabs.length - 1);
    final widths = [for (final w in weights) available * w / total];
    final lefts = <double>[];
    var x = 0.0;
    for (final w in widths) {
      lefts.add(x);
      x += w + _gap;
    }

    // Pill: between the two tabs either side of [position].
    final from = position.floor().clamp(0, tabs.length - 1);
    final to = position.ceil().clamp(0, tabs.length - 1);
    final t = position - from;
    final pillLeft = lefts[from] + (lefts[to] - lefts[from]) * t;
    final pillWidth = widths[from] + (widths[to] - widths[from]) * t;

    return Stack(
      children: [
        Positioned(
          left: pillLeft,
          width: pillWidth,
          top: 0,
          bottom: 0,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.surfaceForeground,
              borderRadius: BorderRadius.all(Radius.circular(999)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadowSmall,
                  offset: Offset(0, 2),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ),
        for (var i = 0; i < tabs.length; i++)
          Positioned(
            left: lefts[i],
            width: widths[i],
            top: 0,
            bottom: 0,
            child: _NavItem(
              tab: tabs[i],
              selected: tabs[i] == selected,
              highlight: _closeness(i, position),
              onTap: () => onSelected(tabs[i]),
            ),
          ),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.highlight,
    required this.onTap,
  });

  final AppNavTab tab;
  final bool selected;

  /// 0–1 while the pill moves: tints the icon and fades the label in.
  final double highlight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final icon = SvgPicture.asset(
      tab.icon,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        Color.lerp(AppColors.iconInactive, AppColors.headingBlack, highlight)!,
        BlendMode.srcIn,
      ),
    );

    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              if (highlight > 0.01)
                Flexible(
                  child: Opacity(
                    opacity: highlight,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Text(
                        tab.label,
                        style: AppTextStyles.xsMedium,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
