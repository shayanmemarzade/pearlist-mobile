import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_links.dart';
import '../../../core/utils/phone_format.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_back_link.dart';
import '../../../core/widgets/app_bottom_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../data/pear_repository.dart';
import '../../../data/preferences.dart';
import '../../onboarding/presentation/welcome_screen.dart';
import '../../paywall/presentation/paywall_screen.dart';
import 'account_settings_screen.dart';
import 'edit_profile_screen.dart';
import 'faq_screen.dart';
import 'members_screen.dart';
import 'notification_settings_screen.dart';
import 'profile_widgets.dart';

/// "Pro · yearly" / "Pro · monthly" / "Free".
String planLabel(PearRepository repo) {
  if (!repo.isPro) return 'Free';
  return switch (repo.billing) {
    ProBilling.monthly => 'Pro · monthly',
    _ => 'Pro · yearly',
  };
}

/// Profile (Figma "Profile and setting" → "Profile", 2269:6332).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _push(BuildContext context, Widget page) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => page));

  void _signOut(BuildContext context) {
    // TODO: clear the session token once the API exists.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = PearScope.of(context);
    final me = repo.me;
    final phone = me.phone;
    final connections = repo.connections;
    final pending = repo.pendingInvites;
    final connectionsText = [
      if (connections.isNotEmpty)
        connections.map((p) => p.firstName).join(', ')
      else
        'No one yet',
      if (pending.isNotEmpty)
        '${pending.length} ${pending.length == 1 ? 'invite' : 'invites'} '
            'pending',
    ].join(' · ');
    final plan = planLabel(repo);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              MediaQuery.viewPaddingOf(context).bottom + 24,
            ),
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: AppBackLink(label: 'Home'),
              ),
              const SizedBox(height: 8),
              Text('Profile', style: AppTextStyles.heading3Bold),
              const SizedBox(height: 20),
              _SummaryCard(
                name: me.name,
                avatarUrl: me.avatarUrl,
                phone: phone == null ? null : formatUsPhoneInternational(phone),
                plan: plan,
                onEdit: () => _push(context, const EditProfileScreen()),
              ),
              const SizedBox(height: 17),
              const ProfileSectionLabel('Shared Connections'),
              ProfileCard(
                children: [
                  ProfileRow(
                    icon: AppIcons.users20,
                    title: 'Manage connections',
                    subtitle: connectionsText,
                    extra: connections.isEmpty && pending.isEmpty
                        ? null
                        : AvatarStack(
                            size: 24,
                            people: [
                              for (final p in connections)
                                (name: p.name, imageUrl: p.avatarUrl),
                              for (final i in pending)
                                (name: i.displayName, imageUrl: null),
                            ],
                          ),
                    onTap: () => _push(context, const MembersScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              const ProfileSectionLabel('Account'),
              ProfileCard(
                children: [
                  ProfileRow(
                    icon: AppIcons.user20,
                    title: 'Name',
                    value: me.name,
                    onTap: () => _push(context, const EditProfileScreen()),
                  ),
                  ProfileRow(
                    icon: AppIcons.security,
                    title: 'Account settings',
                    subtitle: 'Phone number and email',
                    onTap: () =>
                        _push(context, const AccountSettingsScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              const ProfileSectionLabel('Notification'),
              ProfileCard(
                children: [
                  ProfileRow(
                    icon: AppIcons.bell20,
                    title: 'Notifications',
                    value: '${repo.notificationPrefs.enabledCount} on',
                    onTap: () =>
                        _push(context, const NotificationSettingsScreen()),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              const ProfileSectionLabel('Display'),
              ProfileCard(
                children: [
                  ProfileRow(
                    icon: AppIcons.moon,
                    title: 'Theme',
                    value: repo.theme.label,
                    onTap: () => showThemeSheet(context),
                  ),
                  ProfileRow(
                    icon: AppIcons.translate,
                    title: 'Language',
                    trailing: ProfileRowTrailing.none,
                    extra: _LanguageSwitch(
                      value: repo.language,
                      onChanged: repo.setLanguage,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              const ProfileSectionLabel('Support'),
              ProfileCard(
                children: [
                  ProfileRow(
                    icon: AppIcons.sms,
                    title: 'Contact support',
                    trailing: ProfileRowTrailing.external,
                    onTap: () =>
                        launchExternal(context, AppLinks.supportMail()),
                  ),
                  ProfileRow(
                    icon: AppIcons.infoCircle,
                    title: 'FAQ',
                    onTap: () => _push(context, const FaqScreen()),
                  ),
                  ProfileRow(
                    icon: AppIcons.star,
                    title: 'Write a review',
                    trailing: ProfileRowTrailing.external,
                    // TODO: use the in_app_review package for the native
                    // review prompt.
                    onTap: () =>
                        launchExternal(context, AppLinks.storeListing),
                  ),
                  ProfileRow(
                    icon: AppIcons.crown20,
                    title: 'Manage subscription',
                    value: plan,
                    trailing: repo.isPro
                        ? ProfileRowTrailing.external
                        : ProfileRowTrailing.chevron,
                    onTap: repo.isPro
                        ? () => launchExternal(
                              context,
                              AppLinks.storeSubscriptions,
                            )
                        : () => showPaywall(context),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              const ProfileSectionLabel('Legal'),
              ProfileCard(
                children: [
                  ProfileRow(
                    icon: AppIcons.note,
                    title: 'Terms & conditions',
                    trailing: ProfileRowTrailing.external,
                    onTap: () => launchExternal(context, AppLinks.terms),
                  ),
                  ProfileRow(
                    icon: AppIcons.lock20,
                    title: 'Privacy policy',
                    trailing: ProfileRowTrailing.external,
                    onTap: () => launchExternal(context, AppLinks.privacy),
                  ),
                ],
              ),
              const SizedBox(height: 17),
              AppButton(
                label: 'Sign out',
                variant: AppButtonVariant.dangerOutline,
                icon: SvgPicture.asset(AppIcons.logout, width: 18, height: 18),
                onPressed: () => _signOut(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.name,
    required this.avatarUrl,
    required this.phone,
    required this.plan,
    required this.onEdit,
  });

  final String name;
  final String? avatarUrl;
  final String? phone;
  final String plan;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final phone = this.phone;
    final pro = plan != 'Free';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceForeground,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: AppColors.borderGrayLight),
      ),
      child: Row(
        children: [
          AppAvatar(name: name, imageUrl: avatarUrl, size: 48),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.body1Bold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (phone != null)
                  Text(phone, style: AppTextStyles.body2Regular),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: pro ? const Color(0xFFFCF5EF) : AppColors.surfaceGray,
              borderRadius: const BorderRadius.all(Radius.circular(16)),
            ),
            child: Text(
              plan,
              style: AppTextStyles.body2Medium.copyWith(
                color: pro ? const Color(0xFFB4824D) : AppColors.badgeGrayText,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Tooltip(
            message: 'Edit profile',
            child: InkResponse(
              onTap: onEdit,
              radius: 20,
              child: SvgPicture.asset(AppIcons.edit20, width: 20, height: 20),
            ),
          ),
        ],
      ),
    );
  }
}

/// EN | DE (Figma "Language selection").
class _LanguageSwitch extends StatelessWidget {
  const _LanguageSwitch({required this.value, required this.onChanged});

  final AppLanguage value;
  final ValueChanged<AppLanguage> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final lang in AppLanguage.values) ...[
          if (lang != AppLanguage.values.first) const SizedBox(width: 6),
          Semantics(
            button: true,
            selected: lang == value,
            child: GestureDetector(
              onTap: () => onChanged(lang),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: lang == value ? AppColors.background : null,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  border: Border.all(
                    color: lang == value
                        ? AppColors.borderGrayLight
                        : Colors.transparent,
                  ),
                ),
                child: Text(lang.code, style: AppTextStyles.body1Medium),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// "Theme" sheet (Figma 2269:6774). Applies on "Done".
Future<void> showThemeSheet(BuildContext context) {
  final repo = PearScope.read(context);
  var choice = repo.theme;
  return showAppSheet<void>(
    context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) => AppSheetFrame(
        bottomBar: AppBottomBar(
          keyboardOpen: false,
          child: AppButton(
            label: 'Done',
            onPressed: () {
              repo.setTheme(choice);
              Navigator.of(context).pop();
            },
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Theme', style: AppTextStyles.titleBold),
                ),
                const SheetCloseButton(),
              ],
            ),
            const SizedBox(height: 20),
            ProfileCard(
              children: [
                for (final option in ThemePreference.values)
                  ProfileRow(
                    icon: switch (option) {
                      ThemePreference.system => AppIcons.setting,
                      ThemePreference.light => AppIcons.star,
                      ThemePreference.dark => AppIcons.moon,
                    },
                    title: option.label,
                    subtitle: option.description,
                    trailing: ProfileRowTrailing.none,
                    extra: RadioDot(selected: option == choice),
                    onTap: () => setState(() => choice = option),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
