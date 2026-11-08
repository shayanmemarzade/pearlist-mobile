import 'package:flutter/material.dart';

import '../../../core/utils/phone_format.dart';
import '../../../core/widgets/app_button.dart';
import '../../../data/services.dart';
import '../../onboarding/presentation/widgets/onboarding_scaffold.dart';
import '../../onboarding/presentation/widgets/phone_field.dart';
import '../domain/sign_up_draft.dart';
import 'verify_code_screen.dart';

/// Phone number entry for sign up (Figma 2184:6270 / 6496 / 6532) and
/// sign in (2184:6756 / 6870 / 6906).
class PhoneNumberScreen extends StatefulWidget {
  const PhoneNumberScreen({super.key, required this.mode, required this.draft});

  final AuthMode mode;
  final SignUpDraft draft;

  @override
  State<PhoneNumberScreen> createState() => _PhoneNumberScreenState();
}

class _PhoneNumberScreenState extends State<PhoneNumberScreen> {
  late final _controller =
      TextEditingController(text: formatUsPhone(widget.draft.phone));
  String? _error;
  bool _sending = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
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
    widget.draft.phone = digits;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            VerifyCodeScreen(mode: widget.mode, draft: widget.draft),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final signIn = widget.mode == AuthMode.signIn;
    final hasInput = phoneDigits(_controller.text).isNotEmpty;
    return OnboardingScaffold(
      actions: [
        AppButton(
          label: _sending ? 'Sending…' : 'Send code',
          onPressed: hasInput && !_sending ? _sendCode : null,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingHeader(
            title: signIn
                ? 'Welcome back'
                : 'Enter your phone number to create your account',
            description: signIn
                ? 'Enter the phone number you signed up with. We’ll text '
                    'you a 4-digit code.'
                : 'We’ll text you a 4-digit code. No password needed.',
          ),
          const SizedBox(height: 20),
          PhoneField(
            controller: _controller,
            error: _error,
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _sendCode(),
          ),
        ],
      ),
    );
  }
}
