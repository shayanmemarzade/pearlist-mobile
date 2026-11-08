import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_link_button.dart';
import '../../../../core/widgets/dashed_border.dart';
import '../../domain/home_models.dart';
import '../time_ago.dart';
import 'home_section_header.dart';

/// "Recent activities" list, or the dashed empty state with the sleepy basket.
class RecentActivitySection extends StatelessWidget {
  const RecentActivitySection({
    super.key,
    required this.activities,
    required this.partnerName,
    required this.onViewAll,
    this.kind = ListKind.shopping,
  });

  /// Wishes show the list name under each entry and a different empty
  /// state.
  final ListKind kind;
  final List<Activity> activities;

  /// Name used in the empty-state copy ("Anything you or Sam add…").
  final String? partnerName;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    if (activities.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const HomeSectionHeader(title: 'Recent activity'),
          const SizedBox(height: 8),
          _EmptyActivity(partnerName: partnerName, kind: kind),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeSectionHeader(
          title: 'Recent activities',
          action: AppLinkButton(
            label: kind == ListKind.wishlist ? 'View List' : 'View all',
            onPressed: onViewAll,
            trailingIcon: SvgPicture.asset(
              AppIcons.arrowRight,
              width: 18,
              height: 18,
            ),
          ),
        ),
        const SizedBox(height: 8),
        AppCard(
          child: Column(
            children: [
              for (var i = 0; i < activities.length; i++) ...[
                if (i > 0) ...const [
                  SizedBox(height: 16),
                  AppDivider(),
                  SizedBox(height: 16),
                ],
                _ActivityRow(
                  activity: activities[i],
                  showList: kind == ListKind.wishlist,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.activity, required this.showList});

  final Activity activity;

  /// "2m ago · Our home".
  final bool showList;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppAvatar(
          name: activity.actor.name,
          imageUrl: activity.actor.avatarUrl,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(activity.description, style: AppTextStyles.body2SemiBold),
              Text(
                [
                  formatTimeAgo(activity.at),
                  if (showList && activity.listName != null) activity.listName,
                ].join(' · '),
                style: AppTextStyles.xsRegular,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyActivity extends StatelessWidget {
  const _EmptyActivity({required this.partnerName, required this.kind});

  final String? partnerName;
  final ListKind kind;

  @override
  Widget build(BuildContext context) {
    final who = partnerName == null ? 'you' : 'you or $partnerName';
    return DashedBorder(
      color: AppColors.borderGrayDark,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.surfaceForeground,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Column(
          children: [
            SvgPicture.asset(
              kind == ListKind.wishlist
                  ? AppImages.emptyWishes
                  : AppImages.emptyActivity,
              width: 115,
              height: 92,
            ),
            const SizedBox(height: 16),
            Text(
              kind == ListKind.wishlist
                  ? 'Anything $who save shows up here, with your recent '
                      'activity.'
                  : 'Anything $who add or check off shows up here, with your '
                      'recent activity.',
              style: AppTextStyles.xsRegular,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
