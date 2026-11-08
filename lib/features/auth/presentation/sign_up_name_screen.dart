import 'package:flutter/material.dart';

import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_pill_field.dart';
import '../../onboarding/presentation/widgets/onboarding_scaffold.dart';
import '../domain/sign_up_draft.dart';
import 'sign_up_stores_screen.dart';

/// Sign up — Name (Figma 2184:6234 / 2184:6568).
class SignUpNameScreen extends StatefulWidget {
  const SignUpNameScreen({super.key, required this.draft});

  final SignUpDraft draft;

  @override
  State<SignUpNameScreen> createState() => _SignUpNameScreenState();
}

class _SignUpNameScreenState extends State<SignUpNameScreen> {
  late final _controller = TextEditingController(text: widget.draft.name);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _valid => _controller.text.trim().isNotEmpty;

  void _next() {
    if (!_valid) return;
    widget.draft.name = _controller.text.trim();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SignUpStoresScreen(draft: widget.draft),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      actions: [
        AppButton(label: 'Next', onPressed: _valid ? _next : null),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OnboardingHeader(
            title: 'What should we call you?',
            description:
                'This is how your name shows next to the items you add.',
          ),
          const SizedBox(height: 20),
          AppPillField(
            hint: 'Name',
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.name],
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _next(),
          ),
        ],
      ),
    );
  }
}
