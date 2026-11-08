import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/phone_format.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_link_button.dart';
import '../../../data/auth_service.dart';
import '../../../data/services.dart';
import '../../onboarding/presentation/widgets/onboarding_scaffold.dart';
import '../../onboarding/presentation/widgets/otp_input.dart';
import '../domain/sign_up_draft.dart';
import 'auth_navigation.dart';
import 'profile_photo_screen.dart';

/// 4-digit code entry (Figma "Sign up - OTP" 2184:6306 / 6345, "Sign in -
/// OTP" 2184:6792 / 6831).
class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({super.key, required this.mode, required this.draft});

  final AuthMode mode;
  final SignUpDraft draft;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _controller = TextEditingController();
  Timer? _timer;
  int _secondsLeft = kResendCodeSeconds;
  bool _verifying = false;
  bool _wrongCode = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
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

  Future<void> _resend() async {
    setState(() {
      _controller.clear();
      _wrongCode = false;
      _startTimer();
    });
    await AppServices.auth.sendCode(widget.draft.phone);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('We sent you a new code.')),
    );
  }

  Future<void> _verify() async {
    final code = _controller.text;
    if (code.length != 4 || _verifying) return;
    setState(() => _verifying = true);
    final ok = await AppServices.auth.verifyCode(widget.draft.phone, code);
    if (!mounted) return;
    setState(() {
      _verifying = false;
      _wrongCode = !ok;
    });
    if (!ok) return;
    if (widget.mode == AuthMode.signIn) {
      AuthNavigation.goHome(context);
    } else {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProfilePhotoScreen(draft: widget.draft),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final complete = _controller.text.length == 4;
    final m = _secondsLeft ~/ 60;
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    final rowStyle = AppTextStyles.body2Medium.copyWith(color: AppColors.body1);

    return OnboardingScaffold(
      actions: [
        AppButton(
          label: _verifying ? 'Checking…' : 'Next',
          onPressed: complete && !_verifying ? _verify : null,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OnboardingHeader(
            title: 'Enter the 4-digit code',
            descriptionSpan: TextSpan(
              children: [
                const TextSpan(text: 'We sent it to '),
                TextSpan(
                  text: formatUsPhoneInternational(widget.draft.phone),
                  style: AppTextStyles.body1Bold.copyWith(color: AppColors.body1),
                ),
                const TextSpan(text: '.'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          OtpInput(
            controller: _controller,
            error: _wrongCode,
            onChanged: (_) => setState(() => _wrongCode = false),
            onCompleted: (_) => _verify(),
          ),
          if (_wrongCode)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                'That code didn’t work. Check it and try again.',
                style: AppTextStyles.xsRegular.copyWith(color: AppColors.error),
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              if (_secondsLeft > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  child: Row(
                    children: [
                      SvgPicture.asset(AppIcons.timer, width: 18, height: 18),
                      const SizedBox(width: 8),
                      Text('Resend code in $m:$s', style: rowStyle),
                    ],
                  ),
                )
              else
                AppLinkButton(
                  label: 'Resend code',
                  color: AppColors.body1,
                  leadingIcon:
                      SvgPicture.asset(AppIcons.timer, width: 18, height: 18),
                  onPressed: _resend,
                ),
              const Spacer(),
              AppLinkButton(
                label: 'Edit number',
                color: AppColors.body1,
                leadingIcon:
                    SvgPicture.asset(AppIcons.edit18, width: 18, height: 18),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
