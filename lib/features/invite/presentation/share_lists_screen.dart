import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/phone_format.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_pill_field.dart';
import '../../../data/contacts.dart';
import '../../../data/invites.dart';
import '../../../data/models.dart';
import '../../../data/pear_repository.dart';
import '../../../data/services.dart';
import '../../home/presentation/home_screen.dart';
import '../../onboarding/presentation/widgets/onboarding_scaffold.dart';
import 'choose_partners_screen.dart';
import 'contacts_permission_sheet.dart';
import 'invite_result_screens.dart';
import 'widgets/list_access_card.dart';

enum ShareListsMode {
  /// Last sign-up step: "Share your lists" with "Maybe later".
  setup,

  /// From a list or the add-list sheet: "Add your partner" with "Skip".
  addPartner,
}

/// Setup & invite partner (Figma 2184:8607 / 8823 / 8911 / 9026).
class ShareListsScreen extends StatefulWidget {
  const ShareListsScreen({super.key, required this.mode});

  final ShareListsMode mode;

  @override
  State<ShareListsScreen> createState() => _ShareListsScreenState();
}

class _ShareListsScreenState extends State<ShareListsScreen> {
  final _controller = TextEditingController();
  final Set<ListKind> _lists = {...ListKind.values};
  String? _error;

  /// The OS only asks once; after that go straight to the picker.
  static bool _contactsAllowed = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? get _address {
    final text = _controller.text.trim();
    if (looksLikeEmail(text)) return text;
    if (isValidUsPhone(text)) return formatUsPhone(text);
    return null;
  }

  void _leave() {
    if (widget.mode == ShareListsMode.addPartner) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  void _sendTo(List<InviteTarget> targets) {
    final repo = PearScope.read(context);
    if (repo.invitesLeft == 0) {
      setState(() => _error =
          'You’ve invited $kProInviteLimit people, the most Pro allows.');
      return;
    }
    final sent = repo.sendInvites(targets, {..._lists});
    _controller.clear();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => repo.isPro
            ? InviteSentScreen(invites: sent)
            : const InvitesPendingScreen(),
      ),
    );
  }

  void _send() {
    final address = _address;
    if (address == null) {
      setState(() => _error = 'Enter an email or a US phone number');
      return;
    }
    _sendTo([InviteTarget(address: address)]);
  }

  Future<void> _pickContacts() async {
    FocusScope.of(context).unfocus();
    if (!_contactsAllowed) {
      final ok = await showContactsPermissionSheet(context);
      if (!ok || !mounted) return;
      _contactsAllowed = await AppServices.contacts.requestPermission();
      if (!_contactsAllowed || !mounted) return;
    }
    final picked = await Navigator.of(context).push<List<Contact>>(
      MaterialPageRoute(builder: (_) => const ChoosePartnersScreen()),
    );
    if (picked == null || picked.isEmpty || !mounted) return;
    _sendTo([
      for (final c in picked) InviteTarget(name: c.name, address: c.phone),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final setup = widget.mode == ShareListsMode.setup;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final canSend = _controller.text.trim().isNotEmpty && _lists.isNotEmpty;

    return OnboardingScaffold(
      showBack: Navigator.of(context).canPop(),
      onSkip: setup ? null : _leave,
      actions: [
        AppButton(label: 'Send invite', onPressed: canSend ? _send : null),
        if (setup)
          AppButton(
            label: keyboardOpen ? 'Use Pearlist alone' : 'Maybe later',
            variant: AppButtonVariant.outline,
            onPressed: _leave,
          ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingHeader(
            title: setup ? 'Share your lists' : 'Add your partner',
            description: setup
                ? 'Invite your partner or anyone you plan with. They’ll '
                    'have access to the lists you turn on below.'
                : 'Enter their email or pick a contact. Once they sign up '
                    'with it, you can add them to your shared lists.',
          ),
          const SizedBox(height: 20),
          AppPillField(
            label: 'Email or phone number',
            hint: 'name@email.com',
            controller: _controller,
            error: _error,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.send,
            prefixIcon: SvgPicture.asset(AppIcons.email, width: 18, height: 18),
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _send(),
          ),
          const SizedBox(height: 20),
          const _OrDivider(),
          const SizedBox(height: 20),
          AppButton(
            label: 'Select from contacts',
            variant: AppButtonVariant.greenOutline,
            icon: SvgPicture.asset(AppIcons.tagUser, width: 18, height: 18),
            onPressed: _lists.isEmpty ? null : _pickContacts,
          ),
          const SizedBox(height: 20),
          ListAccessCard(
            selected: _lists,
            onChanged: (kind, on) => setState(() {
              on ? _lists.add(kind) : _lists.remove(kind);
            }),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    const line = Expanded(
      child: SizedBox(
        height: 1,
        child: ColoredBox(color: Color(0x4DDCDFDD)),
      ),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'or',
            style: AppTextStyles.body1Regular.copyWith(
              color: AppColors.orDivider,
              height: 24 / 16,
            ),
          ),
        ),
        line,
      ],
    );
  }
}
