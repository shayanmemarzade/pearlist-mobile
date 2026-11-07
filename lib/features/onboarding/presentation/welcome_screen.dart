import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';

/// Welcome screen (Figma: "Welcome Screen" 2492:11097) — the end state of
/// the splash animation.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          // Scrollable only as a fallback for very short screens; on normal
          // phones everything fits and the buttons sit at the bottom.
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 48),
                        Text('Pear List', style: AppTextStyles.displayTitle),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 317,
                          child: Text(
                            'One list, shared by two. Shop together, from anywhere.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body1Medium
                                .copyWith(color: AppColors.body2),
                          ),
                        ),
                        const SizedBox(height: 54),
                        SvgPicture.asset(
                          'assets/images/pear_logo.svg',
                          width: 107,
                          height: 181,
                        ),
                        const Spacer(),
                        AppButton(
                          label: 'Get Started',
                          onPressed: () {
                            // TODO: navigate to Sign up — Phone number.
                          },
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          label: 'Sign In',
                          variant: AppButtonVariant.outline,
                          onPressed: () {
                            // TODO: navigate to Sign in — Phone number.
                          },
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: 325,
                          child: Text(
                            'By continuing you agree to our Terms of Service and Privacy Policy.',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.xsRegular,
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
