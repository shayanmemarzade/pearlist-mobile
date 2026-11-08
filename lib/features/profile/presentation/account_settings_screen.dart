import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/phone_format.dart';
import '../../../core/widgets/app_back_link.dart';
import '../../../core/widgets/app_bottom_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_link_button.dart';
import '../../../core/widgets/app_pill_field.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../data/auth_service.dart';
import '../../../data/pear_repository.dart';
import '../../../data/services.dart';
import '../../onboarding/presentation/welcome_screen.dart';
import '../../onboarding/presentation/widgets/onboarding_scaffold.dart';
import '../../onboarding/presentation/widgets/otp_input.dart';
import '../../onboarding/presentation/widgets/phone_field.dart';
import 'profile_widgets.dart';

/// Phone number, email and account deletion (Figma "Account settings",
/// 2269:6616).
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  Future<void> _delete(BuildContext context) async {
    final repo = PearScope.read(context);
    final partner = repo.connections.firstOrNull?.firstName;
    final confirmed = await showDeleteAccountSheet(
      context,
      partnerName: partner,
      subscribed: repo.isPro,
    );
    if (!confirmed || !context.mounted) return;
    // TODO: call the API to delete the account and its lists.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const WelcomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = PearScope.of(context).me;
    final phone = me.phone;
    final email = me.email;
    void push(Widget page) => Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => page));

    return ProfilePage(
      title: 'Account settings',
      description: 'You sign in with your phone number and a code we text '
          'you. Your email is for receipts and as a backup way in.',
      actions: [
        Center(
          child: AppDangerTextButton(
            label: 'Delete account',
            icon: SvgPicture.asset(AppIcons.trashSmall, width: 18, height: 18),
            onPressed: () => _delete(context),
          ),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const ProfileSectionLabel('Sign-in'),
          ProfileCard(
            children: [
              ProfileRow(
                icon: AppIcons.call,
                title: 'Phone Number',
                subtitle: phone == null
                    ? 'Add a phone number'
                    : formatUsPhoneInternational(phone),
                extra: phone == null ? null : const VerifiedBadge(),
                onTap: () => push(const UpdatePhoneScreen()),
              ),
              ProfileRow(
                icon: AppIcons.sms,
                title: 'Email',
                subtitle: email ?? 'Add an email',
                extra: email == null ? null : const VerifiedBadge(),
                onTap: () => push(const UpdateEmailScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// "Update your email" (Figma 2269:6664).
class UpdateEmailScreen extends StatefulWidget {
  const UpdateEmailScreen({super.key});

  @override
  State<UpdateEmailScreen> createState() => _UpdateEmailScreenState();
}

class _UpdateEmailScreenState extends State<UpdateEmailScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final email = _controller.text.trim();
    if (!looksLikeEmail(email)) {
      setState(() => _error = 'That doesn’t look like an email address');
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ConfirmContactScreen(kind: ContactKind.email, value: email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = PearScope.of(context).me.email;
    return ProfilePage(
      title: 'Update your email',
      description: 'We’ll email a code to the new address to make sure '
          'it’s yours.',
      actions: [
        AppButton(
          label: 'Send code',
          onPressed: _controller.text.trim().isEmpty ? null : _send,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppPillField(
            label: 'New email',
            hint: 'name@email.com',
            controller: _controller,
            error: _error,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            prefixIcon: SvgPicture.asset(AppIcons.email, width: 18, height: 18),
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _send(),
          ),
          if (current != null && _error == null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 16),
              child: Text('Current: $current', style: AppTextStyles.xsRegular),
            ),
        ],
      ),
    );
  }
}

/// "Update your phone number" (Figma 2269:6695).
class UpdatePhoneScreen extends StatefulWidget {
  const UpdatePhoneScreen({super.key});

  @override
  State<UpdatePhoneScreen> createState() => _UpdatePhoneScreenState();
}

class _UpdatePhoneScreenState extends State<UpdatePhoneScreen> {
  final _controller = TextEditingController();
  String? _error;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final digits = phoneDigits(_controller.text);
    if (!isValidUsPhone(digits)) {
      setState(() => _error = 'That doesn’t look like a valid US number');
      return;
    }
    setState(() => _sending = true);
    try {
      await AppServices.auth.sendCode(digits);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            ConfirmContactScreen(kind: ContactKind.phone, value: digits),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final current = PearScope.of(context).me.phone;
    return ProfilePage(
      title: 'Update your phone number',
      description: 'We’ll text a code to the new number to make sure '
          'it’s yours.',
      actions: [
        AppButton(
          label: _sending ? 'Sending…' : 'Send code',
          onPressed: phoneDigits(_controller.text).isEmpty || _sending
              ? null
              : _send,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text('New phone number', style: AppTextStyles.body2Medium),
          ),
          PhoneField(
            controller: _controller,
            error: _error,
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _send(),
          ),
          if (_error == null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 16),
              child: Text(
                [
                  if (current != null)
                    'Current: ${formatUsPhoneInternational(current)}.',
                  'You’ll sign in with the new number from now on.',
                ].join(' '),
                style: AppTextStyles.xsRegular,
              ),
            ),
        ],
      ),
    );
  }
}

enum ContactKind { email, phone }

/// 4-digit code for a new email or phone (Figma "Confirm email (OTP)"
/// 2269:7155 and "Confirm Phone (OTP)" 2269:7190).
class ConfirmContactScreen extends StatefulWidget {
  const ConfirmContactScreen({
    super.key,
    required this.kind,
    required this.value,
  });

  final ContactKind kind;

  /// The new email, or the new phone's 10 digits.
  final String value;

  @override
  State<ConfirmContactScreen> createState() => _ConfirmContactScreenState();
}

class _ConfirmContactScreenState extends State<ConfirmContactScreen> {
  final _code = TextEditingController();
  Timer? _timer;
  int _secondsLeft = kResendCodeSeconds;
  bool _wrong = false;
  bool _checking = false;

  bool get _email => widget.kind == ContactKind.email;

  String get _shown =>
      _email ? widget.value : formatUsPhoneInternational(widget.value);

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _code.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = kResendCodeSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) timer.cancel();
      setState(() => _secondsLeft--);
    });
  }

  // TODO: the API sends email codes; texts reuse the sign-in service.
  Future<void> _resend() async {
    setState(() {
      _code.clear();
      _wrong = false;
      _startTimer();
    });
    if (!_email) await AppServices.auth.sendCode(widget.value);
  }

  Future<void> _verify() async {
    if (_code.text.length != 4 || _checking) return;
    setState(() => _checking = true);
    final ok = await AppServices.auth.verifyCode(widget.value, _code.text);
    if (!mounted) return;
    setState(() {
      _checking = false;
      _wrong = !ok;
    });
    if (!ok) return;
    final repo = PearScope.read(context);
    if (_email) {
      repo.updateProfile(email: widget.value);
    } else {
      repo.updateProfile(phone: widget.value);
    }
    final messenger = ScaffoldMessenger.of(context);
    // Back to Account settings (this screen and the "Update" screen).
    Navigator.of(context)
      ..pop()
      ..pop();
    messenger.showSnackBar(
      SnackBar(
        content: Text(_email ? 'Email updated.' : 'Phone number updated.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final rowStyle = AppTextStyles.body2Medium.copyWith(color: AppColors.body1);
    final m = _secondsLeft ~/ 60;
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 12, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AppBackLink(label: _email ? 'Email' : 'Phone'),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OnboardingHeader(
                      title: 'Enter the 4-digit code',
                      descriptionSpan: TextSpan(
                        children: [
                          const TextSpan(text: 'We sent it to '),
                          TextSpan(
                            text: _shown,
                            style: AppTextStyles.body1Medium
                                .copyWith(color: AppColors.body1),
                          ),
                          TextSpan(
                            text: _email
                                ? '. Your email changes once you confirm.'
                                : '. Your number changes once you confirm.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    OtpInput(
                      controller: _code,
                      error: _wrong,
                      onChanged: (_) => setState(() => _wrong = false),
                      onCompleted: (_) => _verify(),
                    ),
                    if (_wrong)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'That code didn’t work. Check it and try again.',
                          style: AppTextStyles.xsRegular
                              .copyWith(color: AppColors.error),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        if (_secondsLeft > 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  AppIcons.timer,
                                  width: 18,
                                  height: 18,
                                ),
                                const SizedBox(width: 8),
                                Text('Resend code in $m:$s', style: rowStyle),
                              ],
                            ),
                          )
                        else
                          AppLinkButton(
                            label: 'Resend code',
                            color: AppColors.body1,
                            leadingIcon: SvgPicture.asset(
                              AppIcons.timer,
                              width: 18,
                              height: 18,
                            ),
                            onPressed: _resend,
                          ),
                        const Spacer(),
                        AppLinkButton(
                          label: _email ? 'Edit email' : 'Edit number',
                          color: AppColors.body1,
                          leadingIcon: SvgPicture.asset(
                            AppIcons.edit18,
                            width: 18,
                            height: 18,
                          ),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            OnboardingActionBar(
              keyboardOpen: keyboardOpen,
              children: [
                AppButton(
                  label: _checking ? 'Checking…' : 'Next',
                  onPressed:
                      _code.text.length == 4 && !_checking ? _verify : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// "Delete your account?" (Figma 2269:6929). Resolves to true to delete.
Future<bool> showDeleteAccountSheet(
  BuildContext context, {
  required String? partnerName,
  required bool subscribed,
}) async {
  final who = partnerName == null
      ? 'Anyone you share with will lose access to them.'
      : '$partnerName will lose access to them.';
  final delete = await showAppSheet<bool>(
    context,
    builder: (context) => AppSheetFrame(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      bottomBar: AppBottomBar(
        keyboardOpen: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppDangerTextButton(
              label: 'Delete account',
              icon: SvgPicture.asset(AppIcons.trash, width: 18, height: 18),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Keep my account',
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: Alignment.centerRight,
            child: SheetCloseButton(),
          ),
          const Center(child: FadedIllustration(AppImages.deleteWarning)),
          const SizedBox(height: 16),
          Text(
            'Delete your account?',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleBold,
          ),
          const SizedBox(height: 8),
          Text(
            'This permanently deletes your profile and the lists you own. '
            '$who',
            textAlign: TextAlign.center,
            style: AppTextStyles.body1Regular
                .copyWith(color: AppColors.typographyTertiary),
          ),
          if (subscribed) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: AppColors.secondary100,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SvgPicture.asset(AppIcons.infoWarning, width: 18, height: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your subscription is billed by the App Store or Google '
                      'Play. Cancel it there to stop payments.',
                      style: AppTextStyles.body2Regular
                          .copyWith(color: AppColors.textWarning),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    ),
  );
  return delete ?? false;
}
