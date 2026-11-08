import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/time_format.dart';
import '../../../../core/widgets/app_checkbox.dart';
import '../../../../data/models.dart';
import '../../domain/kind_copy.dart';
import 'level_widgets.dart';

/// One wish or place (Figma: "List items" with link row and level badge).
class CollectionItemRow extends StatelessWidget {
  const CollectionItemRow({
    super.key,
    required this.item,
    required this.kind,
    required this.onCheck,
    required this.onOpen,
  });

  final ShoppingItem item;
  final ListKind kind;
  final ValueChanged<bool> onCheck;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final link = item.link;
    final done = item.isBought;

    return GestureDetector(
      onTap: onOpen,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 46),
        child: Row(
          children: [
            // The checkbox carries 6px of tap padding; pull it to the edge.
            Transform.translate(
              offset: const Offset(-6, 0),
              child: AppCheckbox(
                value: done,
                onChanged: onCheck,
                semanticLabel: item.name,
              ),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.body1Medium.copyWith(
                      color: done ? AppColors.body2 : AppColors.headingBlack,
                      decoration: done ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  if (link != null) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        SvgPicture.asset(AppIcons.link, width: 18, height: 18),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            linkLabel(link),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.smallMedium,
                          ),
                        ),
                      ],
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
                if (!done) ...[
                  LevelBadge(kind: kind, level: item.level),
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

/// "Sort by: Date added · Alphabetical · Wish level".
enum CollectionSort { dateAdded, alphabetical, level }

class CollectionSortTabs extends StatelessWidget {
  const CollectionSortTabs({
    super.key,
    required this.kind,
    required this.value,
    required this.onChanged,
  });

  final ListKind kind;
  final CollectionSort value;
  final ValueChanged<CollectionSort> onChanged;

  String _label(CollectionSort sort) => switch (sort) {
        CollectionSort.dateAdded => 'Date added',
        CollectionSort.alphabetical => 'Alphabetical',
        CollectionSort.level => kind.sortByLevelLabel,
      };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            'Sort by:',
            style: AppTextStyles.body2Medium.copyWith(color: AppColors.body2),
          ),
          const SizedBox(width: 8),
          for (final sort in CollectionSort.values) ...[
            if (sort != CollectionSort.values.first) const SizedBox(width: 4),
            Semantics(
              button: true,
              selected: sort == value,
              child: GestureDetector(
                onTap: () => onChanged(sort),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        sort == value ? AppColors.surfacePrimaryLight : null,
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Text(
                    _label(sort),
                    style: AppTextStyles.body2Medium.copyWith(
                      color: sort == value
                          ? AppColors.textPrimary
                          : AppColors.body2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Sorts a copy of [items].
List<ShoppingItem> sortCollection(
  List<ShoppingItem> items,
  CollectionSort sort,
) {
  final sorted = [...items];
  switch (sort) {
    case CollectionSort.dateAdded:
      sorted.sort((a, b) => b.addedAt.compareTo(a.addedAt));
    case CollectionSort.alphabetical:
      sorted.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    case CollectionSort.level:
      sorted.sort((a, b) {
        final byLevel = a.level.index.compareTo(b.level.index);
        return byLevel != 0 ? byLevel : b.addedAt.compareTo(a.addedAt);
      });
  }
  return sorted;
}
