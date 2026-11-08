import 'package:flutter/material.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../core/widgets/gradient_ring.dart';
import '../../../data/invites.dart';
import '../../../data/models.dart';
import '../../../data/pear_repository.dart';
import '../../auth/presentation/auth_navigation.dart';
import '../../onboarding/presentation/welcome_screen.dart';
import '../../onboarding/presentation/widgets/onboarding_scaffold.dart';
import 'widgets/list_access_card.dart';

/// Opens the right screen for an invite link.
///
/// [signedIn]: the invite was opened inside the app (e.g. from
/// Notifications), so accepting just joins the lists ("Invitation - old
/// user"); otherwise the person signs up first.
void openIncomingInvite(
  BuildContext context,
  IncomingInvite invite, {
  bool signedIn = false,
}) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => invite.valid
          ? IncomingInvitationScreen(invite: invite, signedIn: signedIn)
          : InvalidInviteScreen(inviterName: invite.from.firstName),
    ),
  );
}

/// "Join Sam’s shared lists?" for someone without an account (Figma
/// "Invitation - new user" 2184:8421).
class IncomingInvitationScreen extends StatefulWidget {
  const IncomingInvitationScreen({
    super.key,
    required this.invite,
    this.signedIn = false,
  });

  final IncomingInvite invite;
  final bool signedIn;

  @override
  State<IncomingInvitationScreen> createState() =>
      _IncomingInvitationScreenState();
}

class _IncomingInvitationScreenState extends State<IncomingInvitationScreen> {
  late final Set<ListKind> _lists = {...widget.invite.lists};

  String get _inviter => widget.invite.from.firstName;

  void _accept() {
    PearScope.read(context).acceptInvite(
      IncomingInvite(
        id: widget.invite.id,
        from: widget.invite.from,
        lists: _lists,
      ),
    );
    if (widget.signedIn) {
      final messenger = ScaffoldMessenger.of(context);
      Navigator.of(context).pop();
      messenger.showSnackBar(
        SnackBar(content: Text('You joined $_inviter\u2019s lists.')),
      );
      return;
    }
    // New users create their account next; the lists are waiting at Home.
    AuthNavigation.startSignUp(context, joinedInvite: true);
  }

  Future<void> _reject() async {
    final decline = await showConfirmSheet(
      context,
      title: 'Decline $_inviter’s invite?',
      message: 'You won’t see these shared lists. If you change your '
          'mind, $_inviter can send you a new invite.',
      confirmLabel: 'Decline',
      cancelLabel: 'Go back',
    );
    if (!decline || !mounted) return;
    if (widget.signedIn) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final from = widget.invite.from;
    final kinds = [
      for (final k in ListKind.values)
        if (widget.invite.lists.contains(k)) k,
    ];
    return OnboardingScaffold(
      showBack: Navigator.of(context).canPop(),
      actions: [
        AppButton(label: 'Accept', onPressed: _lists.isEmpty ? null : _accept),
        AppButton(
          label: 'Reject',
          variant: AppButtonVariant.outline,
          onPressed: _reject,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: GradientRing(
              shape: BoxShape.circle,
              width: 3,
              padding: EdgeInsets.zero,
              child: AppAvatar(
                name: from.name,
                imageUrl: from.avatarUrl,
                size: 79,
              ),
            ),
          ),
          const SizedBox(height: 16),
          OnboardingHeader(
            title: 'Join $_inviter’s shared lists?\u{1F389}',
            description: 'Your shared item will be visible to members.',
            center: true,
          ),
          const SizedBox(height: 32),
          _InvitationTab(
            child: ListAccessCard(
              kinds: kinds,
              subtitles: {
                for (final MapEntry(:key, :value)
                    in widget.invite.summaries.entries)
                  key: '${value.lists} ${value.lists == 1 ? 'list' : 'lists'} '
                      'included \u00b7 ${value.items} items',
              },
              selected: _lists,
              onChanged: (kind, on) => setState(() {
                on ? _lists.add(kind) : _lists.remove(kind);
              }),
            ),
          ),
        ],
      ),
    );
  }
}

/// Dark green folder tab around the lists card (Figma "Rectangle 99").
class _InvitationTab extends StatelessWidget {
  const _InvitationTab({required this.child});

  final Widget child;

  static const double _tabHeight = 25;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _TabPainter(),
      child: Stack(
        children: [
          Positioned(
            left: 16,
            top: 3,
            child: Text(
              'Lists name',
              style: AppTextStyles.xsRegular
                  .copyWith(color: AppColors.surfacePrimaryLight),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, _tabHeight + 2, 2, 2),
            child: child,
          ),
        ],
      ),
    );
  }
}

class _TabPainter extends CustomPainter {
  const _TabPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Traced from the Figma vector (365×275), stretched to any size.
    final path = Path()
      ..moveTo(0, 18)
      ..cubicTo(0, 8.06, 8.06, 0, 18, 0)
      ..lineTo(88.75, 0)
      ..cubicTo(95.65, 0, 101.25, 5.6, 101.25, 12.5)
      ..cubicTo(101.25, 19.4, 106.85, 25, 113.75, 25)
      ..lineTo(w - 18, 25)
      ..cubicTo(w - 8.06, 25, w, 33.06, w, 43)
      ..lineTo(w, h - 18)
      ..cubicTo(w, h - 8.06, w - 8.06, h, w - 18, h)
      ..lineTo(18, h)
      ..cubicTo(8.06, h, 0, h - 8.06, 0, h - 18)
      ..close();
    canvas.drawPath(path, Paint()..color = AppColors.invitationGreen);
  }

  @override
  bool shouldRepaint(_TabPainter oldDelegate) => false;
}

/// "This invite is no longer valid" (Figma 2184:8509).
class InvalidInviteScreen extends StatelessWidget {
  const InvalidInviteScreen({super.key, required this.inviterName});

  final String inviterName;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      centerBody: true,
      showBack: Navigator.of(context).canPop(),
      actions: [
        AppButton(
          label: 'Start my own space',
          onPressed: () => AuthNavigation.startSignUp(context),
        ),
        AppButton(
          label: 'I already have an account',
          variant: AppButtonVariant.outline,
          onPressed: () => AuthNavigation.startSignIn(context),
        ),
      ],
      body: OnboardingStatus(
        illustration: const FadedIllustration(AppImages.inviteInvalid),
        title: 'This invite is no longer valid',
        description: 'It may have expired or been cancelled. Ask '
            '$inviterName to send a new one, or start your own space now and '
            'connect later.',
      ),
    );
  }
}
