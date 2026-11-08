import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_input_shell.dart';
import '../../../../data/models.dart';
import 'item_row.dart';

/// Collapsible "✓ Bought · 4" section at the bottom of the list.
class BoughtSection extends StatelessWidget {
  const BoughtSection({
    super.key,
    required this.items,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onUncheck,
    required this.onOpen,
  });

  final List<ShoppingItem> items;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final ValueChanged<ShoppingItem> onUncheck;
  final ValueChanged<ShoppingItem> onOpen;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AppDivider(),
        const SizedBox(height: 12),
        Semantics(
          button: true,
          expanded: expanded,
          child: GestureDetector(
            onTap: onToggleExpanded,
            behavior: HitTestBehavior.opaque,
            child: AppInputShell(
              child: Row(
                children: [
                  SvgPicture.asset(
                    AppIcons.tickCircleFilled,
                    width: 18,
                    height: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Bought',
                        style: AppTextStyles.body1Medium,
                        children: [
                          TextSpan(
                            text: ' · ${items.length}',
                            style: AppTextStyles.body1Regular
                                .copyWith(color: AppColors.textDisable),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SvgPicture.asset(
                    expanded ? AppIcons.arrowUp : AppIcons.arrowDown,
                    width: 18,
                    height: 18,
                  ),
                ],
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: expanded
              ? Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: AppCard(
                    child: Column(
                      children: [
                        for (var i = 0; i < items.length; i++) ...[
                          if (i > 0) ...const [
                            SizedBox(height: 16),
                            AppDivider(),
                            SizedBox(height: 16),
                          ],
                          ItemRow(
                            item: items[i],
                            showHandle: false,
                            onCheck: (_) => onUncheck(items[i]),
                            onOpen: () => onOpen(items[i]),
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}
