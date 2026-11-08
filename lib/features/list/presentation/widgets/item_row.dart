import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_checkbox.dart';
import '../../../../data/models.dart';

/// One item in an aisle card (Figma: "List items" on the list page).
class ItemRow extends StatelessWidget {
  const ItemRow({
    super.key,
    required this.item,
    required this.onCheck,
    required this.onOpen,
    this.dragIndex,
    this.showHandle = true,
  });

  final ShoppingItem item;
  final ValueChanged<bool> onCheck;
  final VoidCallback onOpen;

  /// Index for [ReorderableDragStartListener]; null disables dragging.
  final int? dragIndex;
  final bool showHandle;

  @override
  Widget build(BuildContext context) {
    final dragIndex = this.dragIndex;
    final store = item.store;
    final bought = item.isBought;

    Widget handle =
        SvgPicture.asset(AppIcons.dragHandle, width: 24, height: 24);
    handle = dragIndex == null
        ? Opacity(opacity: 0.4, child: handle)
        : ReorderableDragStartListener(index: dragIndex, child: handle);

    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 46),
        child: Row(
          children: [
            if (showHandle) ...[handle, const SizedBox(width: 2)],
            // The checkbox carries 6px of tap padding on each side.
            AppCheckbox(
              value: bought,
              onChanged: onCheck,
              semanticLabel: item.name,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body1Medium.copyWith(
                      color: bought ? AppColors.body2 : AppColors.headingBlack,
                      decoration: bought ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (store != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      store,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.body2Regular,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.urgent && !bought) ...[
                  const AppBadge.urgent(),
                  const SizedBox(height: 4),
                ],
                Text(
                  formatItemTime(item.addedAt),
                  style: AppTextStyles.smallMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
