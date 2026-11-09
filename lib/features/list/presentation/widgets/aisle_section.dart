import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/snap_away.dart';
import '../../../../data/models.dart';
import 'item_row.dart';

/// Aisle title, item count and a card of items you can drag to reorder
/// (Figma: "List" on the list page).
class AisleSection extends StatelessWidget {
  const AisleSection({
    super.key,
    required this.aisle,
    required this.items,
    required this.reorderable,
    required this.onReorderItem,
    required this.onCheck,
    required this.onOpen,
    this.snapping = const {},
    this.onSnapped,
  });

  /// Ids of items being checked off; they crumble away ([SnapAway]) and
  /// then [onSnapped] moves them to Bought.
  final Set<String> snapping;
  final ValueChanged<ShoppingItem>? onSnapped;

  final String aisle;
  final List<ShoppingItem> items;

  /// Off while a store filter hides part of the aisle.
  final bool reorderable;
  final ReorderCallback onReorderItem;
  final ValueChanged<ShoppingItem> onCheck;
  final ValueChanged<ShoppingItem> onOpen;

  @override
  Widget build(BuildContext context) {
    final count = items.length == 1 ? '1 Item' : '${items.length} Items';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Row(
            children: [
              Expanded(child: Text(aisle, style: AppTextStyles.body1Bold)),
              Text(count, style: AppTextStyles.smallMedium),
            ],
          ),
        ),
        const SizedBox(height: 8),
        AppCard(
          child: ReorderableListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            buildDefaultDragHandles: false,
            itemCount: items.length,
            onReorderItem: onReorderItem,
            proxyDecorator: _proxy,
            itemBuilder: (context, i) {
              final item = items[i];
              final going = snapping.contains(item.id);
              // The first row has no divider above it, so when it goes the
              // next row's divider closes with it instead.
              final dividerGoes = i == 1 && snapping.contains(items[0].id);
              return KeyedSubtree(
                key: ValueKey(item.id),
                child: SnapAway(
                  snapping: going,
                  onSnapped: () => onSnapped?.call(item),
                  above: i == 0 ? null : RowDivider(closing: dividerGoes),
                  child: ItemRow(
                    // Shown ticked and struck through while it crumbles.
                    item: going
                        ? item.copyWith(boughtAt: () => DateTime.now())
                        : item,
                    dragIndex: reorderable && !going ? i : null,
                    onCheck: (_) {
                      if (!going) onCheck(item);
                    },
                    onOpen: () => onOpen(item),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Lifts the dragged row on a white card instead of the default grey.
  /// The divider above the row stays in the list: it's hidden in the
  /// floating copy, and the copy is pushed down by its height so the row
  /// stays under the finger.
  static Widget _proxy(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Padding(
        padding: EdgeInsets.only(top: index == 0 ? 0 : RowDivider.height),
        child: Material(
          color: AppColors.surfaceForeground,
          elevation: 6 * Curves.easeOut.transform(animation.value),
          shadowColor: AppColors.shadowMedium,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
          child: child,
        ),
      ),
      child: RowDragProxy(child: child),
    );
  }
}

