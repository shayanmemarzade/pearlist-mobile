import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_compact_button.dart';
import '../../../../core/widgets/app_link_button.dart';
import '../../../../core/widgets/list_icon_badge.dart';
import '../../../collection/domain/kind_copy.dart';
import '../../domain/home_models.dart';

/// The main list card at the top of Home (Figma: "Select container").
class ActiveListCard extends StatelessWidget {
  const ActiveListCard({
    super.key,
    required this.list,
    required this.onAddItem,
    required this.onOpenList,
  });

  final ActiveList list;
  final VoidCallback onAddItem;
  final VoidCallback onOpenList;

  @override
  Widget build(BuildContext context) {
    // Current user first, as in the design.
    final members = [
      ...list.members.where((p) => p.isMe),
      ...list.members.where((p) => !p.isMe),
    ];

    return AppCard(
      onTap: onOpenList,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ListIconBadge(icon: list.kind.cardIcon),
              const Spacer(),
              AppCompactButton(
                label: list.kind.addLabel,
                onPressed: onAddItem,
                icon: SvgPicture.asset(
                  AppIcons.addWhite,
                  width: 18,
                  height: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            list.isEmpty ? _emptyTitle(list.kind) : list.name,
            style: AppTextStyles.body1Bold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          if (list.isEmpty)
            Text(
              _emptyMessage(list.kind, members),
              style: AppTextStyles.body2Regular,
            )
          else if (list.kind == ListKind.wishlist)
            Text(
              '${list.totalItems} ${list.totalItems == 1 ? 'wish' : 'wishes'}'
              ' · ${list.boughtCount} bought.',
              style: AppTextStyles.body2Regular,
            )
          else
            _ItemsPreview(list: list),
          const SizedBox(height: 20),
          const AppDivider(),
          const SizedBox(height: 20),
          Row(
            children: [
              AvatarStack(
                people: [
                  for (final p in members) (name: p.name, imageUrl: p.avatarUrl),
                ],
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _membersLabel(members),
                  style: AppTextStyles.body2Medium
                      .copyWith(color: AppColors.body1),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              AppLinkButton(
                label: 'Open List',
                onPressed: onOpenList,
                trailingIcon: SvgPicture.asset(
                  AppIcons.arrowRight,
                  width: 18,
                  height: 18,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _emptyTitle(ListKind kind) => switch (kind) {
        ListKind.shopping => 'What do we need this week?',
        ListKind.wishlist => 'What are you wishing for?',
        ListKind.places => 'Where should we go next?',
      };

  static String _emptyMessage(ListKind kind, List<Person> members) {
    final partner = members.where((p) => !p.isMe).firstOrNull;
    return switch (kind) {
      ListKind.shopping => 'Add your first item. Anyone you share this list '
          'with will see it too.',
      ListKind.wishlist => 'Save gift ideas and someday buys. Paste a link '
          'and we\u2019ll fill in the name and price.',
      ListKind.places => partner == null
          ? 'Save the restaurants, caf\u00e9s and trips you want to try, and '
              'remember the ones you loved.'
          : 'Save the restaurants, caf\u00e9s and trips you want to try with '
              '${partner.firstName}, and remember the ones you loved.',
    };
  }

  static String _membersLabel(List<Person> members) {
    final others = members.where((p) => !p.isMe).toList();
    if (others.isEmpty) return 'Only you';
    if (others.length == 1) return 'You & ${others.first.name}';
    return 'You & ${others.length} others';
  }
}

/// "Bananas, Oat milk, Greek yogurt +5 more".
class _ItemsPreview extends StatelessWidget {
  const _ItemsPreview({required this.list});

  final ActiveList list;

  @override
  Widget build(BuildContext context) {
    final more = list.moreCount;
    return Text.rich(
      TextSpan(
        style: AppTextStyles.body2Regular,
        children: [
          TextSpan(text: list.previewItems.join(', ')),
          if (more > 0)
            TextSpan(
              text: ' +$more more',
              style: AppTextStyles.body2SemiBold.copyWith(
                color: AppColors.body1,
                height: 20 / 14,
              ),
            ),
        ],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
