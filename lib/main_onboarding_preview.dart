import 'package:flutter/material.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/theme/app_theme.dart';
import 'data/invites.dart';
import 'data/models.dart';
import 'data/pear_repository.dart';
import 'data/sample_data.dart';
import 'features/auth/presentation/auth_navigation.dart';
import 'features/invite/presentation/choose_partners_screen.dart';
import 'features/invite/presentation/contacts_permission_sheet.dart';
import 'features/invite/presentation/invitation_screens.dart';
import 'features/invite/presentation/invite_result_screens.dart';
import 'features/invite/presentation/share_lists_screen.dart';
import 'features/onboarding/presentation/welcome_screen.dart';
import 'features/paywall/presentation/paywall_screen.dart';

/// Jump straight to any screen of the "Registration, Sign in, Paywall"
/// Figma page.
///
///   flutter run -t lib/main_onboarding_preview.dart
///
/// Uses the free-plan sample data, so invites end on "Invites Pending";
/// buy Pro on the paywall to see "Invite sent".
void main() => runApp(const _OnboardingPreviewApp());

class _OnboardingPreviewApp extends StatefulWidget {
  const _OnboardingPreviewApp();

  @override
  State<_OnboardingPreviewApp> createState() => _OnboardingPreviewAppState();
}

class _OnboardingPreviewAppState extends State<_OnboardingPreviewApp> {
  final _repo = SampleData.repository(SampleState.privateOnly);

  @override
  Widget build(BuildContext context) {
    return PearScope(
      repository: _repo,
      child: MaterialApp(
        title: 'Pear List — onboarding preview',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _Launcher(),
      ),
    );
  }
}

class _Launcher extends StatelessWidget {
  const _Launcher();

  static Invite _invite(String name, String address) => Invite(
        id: 'preview-$name',
        name: name,
        address: address,
        lists: {...ListKind.values},
        status: InviteStatus.sent,
        sentAt: DateTime.now(),
      );

  @override
  Widget build(BuildContext context) {
    final repo = PearScope.of(context);
    void open(Widget screen) => Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => screen));

    final entries = <(String, VoidCallback)>[
      ('Welcome', () => open(const WelcomeScreen())),
      ('Sign up flow', () => AuthNavigation.startSignUp(context)),
      ('Sign in flow', () => AuthNavigation.startSignIn(context)),
      (
        'Share your lists (after sign-up)',
        () => open(const ShareListsScreen(mode: ShareListsMode.setup)),
      ),
      (
        'Add your partner',
        () => open(const ShareListsScreen(mode: ShareListsMode.addPartner)),
      ),
      ('Contacts permission sheet', () => showContactsPermissionSheet(context)),
      ('Choose partners', () => open(const ChoosePartnersScreen())),
      (
        'Invite sent — one person',
        () => open(InviteSentScreen(
              invites: [_invite('Sam', 'Sam@gmail.com')],
            )),
      ),
      (
        'Invite sent — several people',
        () => open(InviteSentScreen(
              invites: [
                _invite('Sam', 'Sam@gmail.com'),
                _invite('Lena', 'Lena@gmail.com'),
              ],
            )),
      ),
      ('Invites pending', () => open(const InvitesPendingScreen())),
      (
        'Invitation — new user',
        () => openIncomingInvite(context, SampleData.samInvite),
      ),
      (
        'Invitation — signed-in user',
        () => openIncomingInvite(
              context,
              SampleData.samInviteSignedIn,
              signedIn: true,
            ),
      ),
      (
        'Invite no longer valid',
        () => openIncomingInvite(
              context,
              const IncomingInvite(
                id: 'expired',
                from: SampleData.sam,
                lists: {},
                valid: false,
              ),
            ),
      ),
      ('Paywall', () => showPaywall(context)),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text('Onboarding screens', style: AppTextStyles.titleBold),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Pro plan', style: AppTextStyles.body1Medium),
            subtitle: Text(
              '${repo.invitedCount} of $kProInviteLimit invites used',
              style: AppTextStyles.body2Regular,
            ),
            value: repo.isPro,
            onChanged: (v) {
              if (v) {
                repo.upgradeToPro();
              } else {
                repo.cancelPro();
              }
            },
          ),
          for (final (label, onTap) in entries)
            ListTile(
              title: Text(label, style: AppTextStyles.body1Regular),
              trailing: const Icon(Icons.chevron_right),
              onTap: onTap,
            ),
        ],
      ),
    );
  }
}
