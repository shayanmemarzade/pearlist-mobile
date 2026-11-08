import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_bottom_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_list_row.dart';
import '../../../core/widgets/app_toggle.dart';
import '../../../data/models.dart';
import '../../../data/pear_repository.dart';
import '../../invite/presentation/share_lists_screen.dart';
import 'widgets/settings_page_header.dart';

/// "Who can use Weekly groceries?" (Figma: "Sharing - owner view").
class SharingScreen extends StatelessWidget {
  const SharingScreen({super.key, required this.listId});

  final String listId;

  @override
  Widget build(BuildContext context) {
    final repo = PearScope.of(context);
    final list = repo.listById(listId);
    if (list == null) {
      return const Scaffold(backgroundColor: AppColors.background);
    }
    final isOwner = list.owner.isMe;
    // Owner first, as in the design.
    final people = [
      list.owner,
      ...list.members.where((p) => p.id != list.owner.id),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: SettingsPageHeader(
                title: 'Who can use ${list.name}?',
                description: 'People you share with can add, check off and '
                    'edit items. Only this list changes here.',
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  if (isOwner && people.length > 1) ...[
                    AppCard(
                      child: AppListRow(
                        leading: SvgPicture.asset(
                          AppIcons.users,
                          width: 24,
                          height: 24,
                        ),
                        title: 'Shared list',
                        subtitle: 'Turn off to make it private to you',
                        trailing: AppToggle(
                          value: list.shared,
                          onChanged: (v) => repo.setShared(list.id, v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  const SectionLabel('People on this list'),
                  GroupedCard(
                    children: [
                      for (final person in people)
                        _MemberRow(
                          person: person,
                          isOwner: person.id == list.owner.id,
                          canEdit: list.canEdit(person),
                          onChanged: isOwner && list.shared
                              ? (v) =>
                                  repo.setMemberAccess(list.id, person.id, v)
                              : null,
                        ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  AppButton(
                    label: 'Invite a partner',
                    variant: AppButtonVariant.greenOutline,
                    icon: SvgPicture.asset(
                      AppIcons.addGreen,
                      width: 18,
                      height: 18,
                    ),
                    // On the free plan the invite is saved and the user is
                    // offered Pro ("Invites Pending").
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ShareListsScreen(
                          mode: ShareListsMode.addPartner,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AppBottomBar(
              keyboardOpen: false,
              child: AppButton(
                label: 'Done',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.person,
    required this.isOwner,
    required this.canEdit,
    required this.onChanged,
  });

  final Person person;
  final bool isOwner;
  final bool canEdit;

  /// Null when access can't be changed (not the owner, or list is private).
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final email = person.email;
    return Row(
      children: [
        AppAvatar(name: person.name, imageUrl: person.avatarUrl),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                person.isMe ? '${person.name} (you)' : person.name,
                style: AppTextStyles.body2Bold,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (email != null)
                Text(
                  email,
                  style: AppTextStyles.xsRegular,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        if (isOwner)
          const AppBadge.owner()
        else
          AppToggle(value: canEdit, onChanged: onChanged),
      ],
    );
  }
}
