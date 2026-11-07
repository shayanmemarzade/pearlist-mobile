import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_compact_button.dart';
import '../../../../core/widgets/app_link_button.dart';
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
              const _ListIconBadge(),
              const Spacer(),
              AppCompactButton(
                label: 'Add item',
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
            list.isEmpty ? 'What do we need this week?' : list.name,
            style: AppTextStyles.body1Bold,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          if (list.isEmpty)
            Text(
              'Add your first item. Anyone you share this list with will '
              'see it too.',
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

/// Cart icon on a white disc over a blurred gradient (Figma: "List icon").
class _ListIconBadge extends StatelessWidget {
  const _ListIconBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 38,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(AppImages.listIconBackground, fit: BoxFit.cover),
            Center(
              child: Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceForeground,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.shadowSoft, blurRadius: 32),
                  ],
                ),
                child: SvgPicture.asset(AppIcons.cart, width: 18, height: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
