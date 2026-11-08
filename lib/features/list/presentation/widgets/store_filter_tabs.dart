import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// "All stores · Whole Foods 2 · Trader Joe's 2 …" filter
/// (Figma: "Tabs / Tab bar" on the list page). Scrolls sideways.
class StoreFilterTabs extends StatelessWidget {
  const StoreFilterTabs({
    super.key,
    required this.stores,
    required this.counts,
    required this.selected,
    required this.onSelected,
  });

  final List<String> stores;

  /// Items still to buy per store.
  final Map<String, int> counts;

  /// Null means "All stores".
  final String? selected;
  final ValueChanged<String?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.surfaceForeground,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _Tab(
              label: 'All stores',
              selected: selected == null,
              onTap: () => onSelected(null),
            ),
            for (final store in stores) ...[
              const SizedBox(width: 4),
              _Tab(
                label: store,
                count: counts[store] ?? 0,
                selected: selected == store,
                onTap: () => onSelected(store),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.selected,
    required this.onTap,
    this.count = 0,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.background
                : AppColors.background.withAlpha(0),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            border: Border.all(
              color: selected
                  ? AppColors.secondary100
                  : AppColors.secondary100.withAlpha(0),
            ),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.body2Medium.copyWith(
                  color: selected ? AppColors.textPrimary : AppColors.body2,
                ),
              ),
              if (count > 0) ...[
                const SizedBox(width: 4),
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceForeground,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.secondary100),
                  ),
                  child: Text(
                    '$count',
                    style: AppTextStyles.xsMedium
                        .copyWith(color: AppColors.body2, height: 1),
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
