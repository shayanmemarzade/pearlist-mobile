import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/time_format.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../data/invites.dart';
import '../../../data/models.dart';
import '../../../data/pear_repository.dart';
import '../../invite/presentation/share_lists_screen.dart';
import '../../paywall/presentation/paywall_screen.dart';
import 'profile_widgets.dart';

/// Everyone you share with, plus pending invites (Figma "Member page",
/// 3211:75137).
class MembersScreen extends StatelessWidget {
  const MembersScreen({super.key});

  void _invite(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            const ShareListsScreen(mode: ShareListsMode.addPartner),
      ),
    );
  }

  Future<void> _remove(BuildContext context, Person person) async {
    final repo = PearScope.read(context);
    final name = person.firstName;
    final confirmed = await showConfirmSheet(
      context,
      title: 'Remove $name?',
      message: '$name will lose access to your shared lists right away. '
          'Items they added stay on the lists, and you’ll have a free '
          'spot for someone else.',
      confirmLabel: 'Remove',
      cancelLabel: 'Keep $name',
    );
    if (confirmed) repo.removeConnection(person.id);
  }

  @override
  Widget build(BuildContext context) {
    final repo = PearScope.of(context);
    final me = repo.me;
    final members = repo.connections;
    final pending = repo.pendingInvites;
    final left =
        (kProInviteLimit - members.length - pending.length).clamp(0, 99);

    return ProfilePage(
      backLabel: 'Members',
      actions: [
        AppButton(
          label: 'Invite member',
          variant: AppButtonVariant.greenOutline,
          icon: SvgPicture.asset(AppIcons.addGreen, width: 18, height: 18),
          onPressed: repo.isPro && left == 0 ? null : () => _invite(context),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PlanCard(
            pro: repo.isPro,
            members: members,
            pending: pending,
            spotsLeft: left,
            onInvite: repo.isPro
                ? () => _invite(context)
                : () => showPaywall(context),
          ),
          const SizedBox(height: 16),
          const ProfileSectionLabel('Members'),
          ProfileCard(
            children: [
              _PersonRow(
                name: '${me.name} (you)',
                detail: me.email ?? '',
                avatarName: me.name,
                imageUrl: me.avatarUrl,
                trailing: const AppBadge.owner(),
              ),
              for (final person in members)
                _PersonRow(
                  name: person.name,
                  detail: person.email ?? '',
                  avatarName: person.name,
                  imageUrl: person.avatarUrl,
                  trailing: _TextAction(
                    label: 'Remove',
                    color: AppColors.error,
                    onTap: () => _remove(context, person),
                  ),
                ),
            ],
          ),
          if (pending.isNotEmpty) ...[
            const SizedBox(height: 16),
            const ProfileSectionLabel('Pending Members'),
            ProfileCard(
              children: [
                for (final invite in pending)
                  _PersonRow(
                    name: invite.address,
                    detail: invite.status == InviteStatus.awaitingUpgrade
                        ? 'Sends when you upgrade'
                        : 'Invite sent '
                            '${formatTimeAgo(invite.sentAt).toLowerCase()}',
                    avatarName: invite.displayName,
                    background: AppColors.background,
                    trailing: _TextAction(
                      label: 'Cancel invite',
                      color: AppColors.buttonBlack,
                      onTap: () => repo.cancelInvite(invite.id),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// "Pro plan · Up to 4 partners…" with joined, pending and open slots.
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.pro,
    required this.members,
    required this.pending,
    required this.spotsLeft,
    required this.onInvite,
  });

  final bool pro;
  final List<Person> members;
  final List<Invite> pending;
  final int spotsLeft;
  final VoidCallback onInvite;

  @override
  Widget build(BuildContext context) {
    final summary = [
      '${members.length} ${members.length == 1 ? 'partner' : 'partners'} '
          'joined',
      '${pending.length} ${pending.length == 1 ? 'invite' : 'invites'} '
          'pending',
      '$spotsLeft ${spotsLeft == 1 ? 'spot' : 'spots'} left',
    ].join(' · ');

    Widget slot(Widget avatar, String label, [String? detail]) => Padding(
          padding: const EdgeInsets.only(right: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              avatar,
              const SizedBox(height: 8),
              Text(
                label,
                style: detail == null
                    ? AppTextStyles.body2Regular
                        .copyWith(color: AppColors.headingBlack)
                    : AppTextStyles.body2Bold,
              ),
              if (detail != null)
                Text(
                  detail,
                  style:
                      AppTextStyles.xsRegular.copyWith(color: AppColors.body2),
                ),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceForeground,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: AppColors.borderGrayLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(4),
                child:
                    SvgPicture.asset(AppIcons.proPlan, width: 24, height: 24),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pro ? 'Pro plan' : 'Free plan',
                      style: AppTextStyles.body1Medium,
                    ),
                    Text(
                      pro
                          ? 'Up to $kProInviteLimit partners join free on '
                              'your plan'
                          : 'Upgrade to Pro to share lists with up to '
                              '$kProInviteLimit people',
                      style: AppTextStyles.body2Regular,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SizedBox(
            height: 1,
            child: ColoredBox(color: AppColors.borderGrayLight),
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final p in members)
                  slot(
                    AppAvatar(name: p.name, imageUrl: p.avatarUrl),
                    p.firstName,
                    'Joined',
                  ),
                for (final i in pending)
                  slot(
                    AppAvatar(
                      name: i.displayName,
                      background: AppColors.background,
                    ),
                    i.name ?? i.address.split('@').first,
                    'Pending',
                  ),
                for (var k = 0; k < spotsLeft; k++)
                  slot(_InviteSlot(onTap: onInvite), 'Invite'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(summary, style: AppTextStyles.body2Regular),
        ],
      ),
    );
  }
}

/// Round outlined "+" (Figma: 34px "Button" on the plan card).
class _InviteSlot extends StatelessWidget {
  const _InviteSlot({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Invite someone',
      child: Material(
        color: AppColors.surfaceForeground,
        shape: const CircleBorder(
          side: BorderSide(color: AppColors.buttonBlack),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox.square(
            dimension: 34,
            child: Center(
              child: SvgPicture.asset(
                AppIcons.addWhite,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.buttonBlack,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonRow extends StatelessWidget {
  const _PersonRow({
    required this.name,
    required this.detail,
    required this.avatarName,
    required this.trailing,
    this.imageUrl,
    this.background = AppColors.surfacePrimaryLight,
  });

  final String name;
  final String detail;
  final String avatarName;
  final String? imageUrl;
  final Color background;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppAvatar(name: avatarName, imageUrl: imageUrl, background: background),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextStyles.body2Bold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (detail.isNotEmpty)
                Text(
                  detail,
                  style:
                      AppTextStyles.xsRegular.copyWith(color: AppColors.body2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        trailing,
      ],
    );
  }
}

class _TextAction extends StatelessWidget {
  const _TextAction({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: const BorderRadius.all(Radius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Text(
          label,
          style: AppTextStyles.body2Medium.copyWith(color: color),
        ),
      ),
    );
  }
}
