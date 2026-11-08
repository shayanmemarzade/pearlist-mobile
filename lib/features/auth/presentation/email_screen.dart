import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/utils/phone_format.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_pill_field.dart';
import '../../onboarding/presentation/widgets/onboarding_scaffold.dart';
import '../domain/sign_up_draft.dart';
import 'auth_navigation.dart';

/// Sign up — email (Figma 2184:6424 / 6460). Optional.
class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key, required this.draft});

  final SignUpDraft draft;

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  late final _controller = TextEditingController(text: widget.draft.email);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _valid => looksLikeEmail(_controller.text);

  void _finish({required bool skip}) {
    if (!skip && !_valid) return;
    widget.draft.email = skip ? null : _controller.text.trim();
    AuthNavigation.finishSignUp(context, widget.draft);
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      onSkip: () => _finish(skip: true),
      actions: [
        AppButton(
          label: 'Continue',
          onPressed: _valid ? () => _finish(skip: false) : null,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OnboardingHeader(
            title: 'Add your email',
            description:
                'We’ll send important updates about your account here.',
          ),
          const SizedBox(height: 20),
          AppPillField(
            hint: 'Email',
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            prefixIcon: SvgPicture.asset(AppIcons.email, width: 18, height: 18),
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _finish(skip: false),
          ),
        ],
      ),
    );
  }
}
