import 'package:flutter/material.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_toggle.dart';
import '../../../../core/widgets/list_icon_badge.dart';
import '../../../../data/models.dart';

/// White card with a toggle per list kind (Figma: "Shopping list / Wish
/// List / Places list" in "Share your lists" and "Invitation").
class ListAccessCard extends StatelessWidget {
  const ListAccessCard({
    super.key,
    required this.selected,
    required this.onChanged,
    this.kinds = ListKind.values,
    this.subtitles = const {},
  });

  /// Replaces the default subtitle per row, e.g. "2 lists included".
  final Map<ListKind, String> subtitles;

  final Set<ListKind> selected;
  final void Function(ListKind kind, bool on) onChanged;

  /// Which rows to show (an invitation only lists what was shared).
  final List<ListKind> kinds;

  static String title(ListKind kind) => switch (kind) {
        ListKind.shopping => 'Shopping list',
        ListKind.wishlist => 'Wish List',
        ListKind.places => 'Places list',
      };

  static String subtitle(ListKind kind) => switch (kind) {
        ListKind.shopping => 'Groceries and everyday buys',
        ListKind.wishlist => 'Gift ideas and someday buys',
        ListKind.places => 'Restaurants, trips and spots to try',
      };

  static String icon(ListKind kind) => switch (kind) {
        ListKind.shopping => AppIcons.cartGreen,
        ListKind.wishlist => AppIcons.giftGreen,
        ListKind.places => AppIcons.pinGreen,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: AppColors.surfaceForeground,
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        children: [
          for (var i = 0; i < kinds.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(height: 20),
              const AppDivider(),
              const SizedBox(height: 20),
            ],
            _Row(
              kind: kinds[i],
              subtitle: subtitles[kinds[i]] ?? subtitle(kinds[i]),
              value: selected.contains(kinds[i]),
              onChanged: (v) => onChanged(kinds[i], v),
            ),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.kind,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final ListKind kind;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: Row(
          children: [
            ListIconBadge(icon: ListAccessCard.icon(kind)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ListAccessCard.title(kind), style: AppTextStyles.body1Medium),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.body2Regular),
                ],
              ),
            ),
            const SizedBox(width: 12),
            AppToggle(value: value, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}
