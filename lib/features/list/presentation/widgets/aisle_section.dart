import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
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
  });

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
              return Column(
                key: ValueKey(item.id),
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (i > 0) ...const [
                    SizedBox(height: 16),
                    AppDivider(),
                    SizedBox(height: 16),
                  ],
                  ItemRow(
                    item: item,
                    dragIndex: reorderable ? i : null,
                    onCheck: (_) => onCheck(item),
                    onOpen: () => onOpen(item),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// Lifts the dragged row on a white card instead of the default grey.
  static Widget _proxy(Widget child, int index, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => Material(
        color: AppColors.surfaceForeground,
        elevation: 6 * Curves.easeOut.transform(animation.value),
        shadowColor: AppColors.shadowMedium,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: child,
      ),
      child: child,
    );
  }
}
