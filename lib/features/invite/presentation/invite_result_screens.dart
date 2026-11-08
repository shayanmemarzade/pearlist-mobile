import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_link_button.dart';
import '../../../core/widgets/gradient_ring.dart';
import '../../../data/invites.dart';
import '../../../data/pear_repository.dart';
import '../../home/presentation/home_screen.dart';
import '../../onboarding/presentation/widgets/onboarding_scaffold.dart';
import '../../paywall/presentation/paywall_screen.dart';

void _goHome(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
    (route) => false,
  );
}

/// "Invite sent! 🎉" / "2 invites sent! 🎉" (Figma 2187:11867 / 11927).
class InviteSentScreen extends StatelessWidget {
  const InviteSentScreen({super.key, required this.invites});

  /// The invites just sent.
  final List<Invite> invites;

  @override
  Widget build(BuildContext context) {
    final repo = PearScope.of(context);
    final several = invites.length > 1;
    final shown = repo.invites
        .where((i) => i.status != InviteStatus.awaitingUpgrade)
        .toList();
    final first = invites.firstOrNull;

    return OnboardingScaffold(
      centerBody: true,
      actions: [
        AppButton(label: 'Go to home', onPressed: () => _goHome(context)),
        if (repo.invitesLeft > 0)
          Center(
            child: AppLinkButton(
              label: 'Invite more',
              color: AppColors.headingBlack,
              leadingIcon: SvgPicture.asset(
                AppIcons.addWhite,
                width: 18,
                height: 18,
                colorFilter: const ColorFilter.mode(
                  AppColors.headingBlack,
                  BlendMode.srcIn,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
      ],
      body: OnboardingStatus(
        illustration: const FadedIllustration(AppImages.inviteSent),
        title: several
            ? '${invites.length} invites sent! \u{1F389}'
            : 'Invite sent! \u{1F389}',
        description: several || first == null
            ? 'When they sign up or log in with the number you invited, '
                'they’ll be added automatically. We’ll let you know '
                'as each one joins.'
            : '${first.name ?? 'They'} can join by signing up or logging in '
                'with the email or phone number you invited. We’ll let '
                'you know when they’re in.',
        footer: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Shared with', style: AppTextStyles.body2Regular),
                ),
                SvgPicture.asset(AppIcons.king, width: 18, height: 18),
                const SizedBox(width: 4),
                Text(
                  '${repo.invitedCount} of $kProInviteLimit invited',
                  style: AppTextStyles.smallRegular,
                ),
              ],
            ),
            for (final invite in shown) ...[
              const SizedBox(height: 12),
              InvitedPersonCard(invite: invite),
            ],
          ],
        ),
      ),
    );
  }
}

/// One invited person with their status (Figma: "Auto-added frame").
class InvitedPersonCard extends StatelessWidget {
  const InvitedPersonCard({super.key, required this.invite});

  final Invite invite;

  @override
  Widget build(BuildContext context) {
    final name = invite.name;
    return GradientRing(
      color: AppColors.surfaceForeground,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          AppAvatar(
            name: invite.displayName,
            size: 40,
            background: AppColors.background,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? invite.address,
                  style: AppTextStyles.body1Medium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (name != null)
                  Text(
                    invite.address,
                    style: AppTextStyles.body2Regular,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          switch (invite.status) {
            InviteStatus.joined => const AppBadge(
                text: 'JOINED',
                background: AppColors.surfacePrimaryLight,
                foreground: AppColors.textPrimary,
              ),
            _ => const AppBadge(
                text: 'PENDING',
                background: AppColors.warning50,
                foreground: AppColors.textWarning,
              ),
          },
        ],
      ),
    );
  }
}

/// "Invites Pending!" — saved on the free plan (Figma 2720:10108).
class InvitesPendingScreen extends StatelessWidget {
  const InvitesPendingScreen({super.key});

  Future<void> _upgrade(BuildContext context) async {
    final repo = PearScope.read(context);
    final waiting = repo.invites
        .where((i) => i.status == InviteStatus.awaitingUpgrade)
        .map((i) => i.id)
        .toSet();
    final upgraded = await showPaywall(context);
    if (!upgraded || !context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => InviteSentScreen(
          invites: [
            for (final i in repo.invites)
              if (waiting.contains(i.id)) i,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      centerBody: true,
      actions: [
        AppButton(
          label: 'Upgrade to send invites',
          onPressed: () => _upgrade(context),
        ),
        AppButton(
          label: 'Continue to Home',
          variant: AppButtonVariant.outline,
          onPressed: () => _goHome(context),
        ),
      ],
      body: const OnboardingStatus(
        illustration: FadedIllustration(AppImages.inviteInvalid),
        title: 'Invites Pending!',
        description: 'Your invites are currently pending. Once you upgrade '
            'your account, your invites will be automatically sent.',
      ),
    );
  }
}
