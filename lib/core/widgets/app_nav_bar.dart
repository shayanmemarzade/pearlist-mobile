import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_assets.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'glass_surface.dart';

enum AppNavTab {
  shopping('Shopping', AppIcons.navShopping, iconIsSelectedStyle: true),
  wishes('Wishes', AppIcons.navWishes),
  places('Places', AppIcons.navPlaces);

  const AppNavTab(this.label, this.icon, {this.iconIsSelectedStyle = false});

  final String label;
  final String icon;

  /// Whether the exported icon is the dark "selected" artwork (Shopping) or
  /// the grey "unselected" one (Wishes, Places). The other state is tinted.
  final bool iconIsSelectedStyle;
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
                child: Row(
                  children: [
                    for (final tab in AppNavTab.values) ...[
                      if (tab != AppNavTab.values.first)
                        const SizedBox(width: 8),
                      Expanded(
                        // Figma: selected item 95px wide, others 86px.
                        flex: tab == selected ? 95 : 86,
                        child: _NavItem(
                          tab: tab,
                          selected: tab == selected,
                          onTap: () => onSelected(tab),
                        ),
                      ),
                    ],
                  ],
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
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final AppNavTab tab;
  final bool selected;
  final VoidCallback onTap;

  static const BorderRadius _radius = BorderRadius.all(Radius.circular(999));

  @override
  Widget build(BuildContext context) {
    final needsTint = selected != tab.iconIsSelectedStyle;
    final icon = SvgPicture.asset(
      tab.icon,
      width: 24,
      height: 24,
      colorFilter: needsTint
          ? ColorFilter.mode(
              selected ? AppColors.headingBlack : AppColors.iconInactive,
              BlendMode.srcIn,
            )
          : null,
    );

    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: 48, // 12px padding + 24px icon + 12px padding
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.surfaceForeground
                : AppColors.surfaceForeground.withAlpha(0),
            borderRadius: _radius,
            boxShadow: [
              BoxShadow(
                color: selected
                    ? AppColors.shadowSmall
                    : AppColors.shadowSmall.withAlpha(0),
                offset: const Offset(0, 2),
                blurRadius: 6,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              if (selected) ...[
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    tab.label,
                    style: AppTextStyles.xsMedium,
                    maxLines: 1,
                    softWrap: false,
                    overflow: TextOverflow.fade,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
