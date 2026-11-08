import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_assets.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_surface.dart';
import 'onboarding_backdrop.dart';

/// Page frame shared by the sign-up, sign-in and invite screens:
/// colour glow at the top, a glass back button (and optional "Skip"),
/// scrolling content and an action bar that rides on the keyboard.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    super.key,
    required this.body,
    this.actions = const [],
    this.showBack = true,
    this.onBack,
    this.onSkip,
    this.backdrop = const OnboardingBackdrop(),
    this.bodyPadding = const EdgeInsets.fromLTRB(16, 24, 16, 24),
    this.centerBody = false,
  });

  final Widget body;

  /// Buttons in the bottom action bar, top to bottom.
  final List<Widget> actions;
  final bool showBack;

  /// Defaults to popping the route.
  final VoidCallback? onBack;

  /// Shows a "Skip" pill on the right when set.
  final VoidCallback? onSkip;
  final Widget? backdrop;
  final EdgeInsetsGeometry bodyPadding;

  /// Vertically centres [body] when it is shorter than the screen
  /// (status pages such as "Invite sent").
  final bool centerBody;

  @override
  Widget build(BuildContext context) {
    // Read above the Scaffold, which removes the inset from its body.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final onSkip = this.onSkip;
    final backdrop = this.backdrop;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (backdrop != null)
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                height: 320,
                child: backdrop,
              ),
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: SizedBox(
                      height: 46,
                      child: Row(
                        children: [
                          if (showBack)
                            OnboardingBackButton(onPressed: onBack),
                          const Spacer(),
                          if (onSkip != null)
                            GlassTextButton(label: 'Skip', onPressed: onSkip),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        padding: bodyPadding,
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: centerBody
                            ? ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: math.max(
                                    0.0,
                                    constraints.maxHeight -
                                        bodyPadding.vertical,
                                  ),
                                ),
                                child: Center(child: body),
                              )
                            : body,
                      ),
                    ),
                  ),
                  if (actions.isNotEmpty)
                    OnboardingActionBar(
                      keyboardOpen: keyboardOpen,
                      children: actions,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 46px glass circle with a 24px back arrow.
class OnboardingBackButton extends StatelessWidget {
  const OnboardingBackButton({super.key, this.onPressed, this.color});

  final VoidCallback? onPressed;

  /// Arrow colour; white on the paywall.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final color = this.color;
    return GlassIconButton(
      tooltip: 'Back',
      size: 46,
      onPressed: onPressed ?? () => Navigator.of(context).maybePop(),
      icon: SvgPicture.asset(
        AppIcons.back24,
        width: 24,
        height: 24,
        colorFilter:
            color == null ? null : ColorFilter.mode(color, BlendMode.srcIn),
      ),
    );
  }
}

/// Bottom buttons on a translucent background (Figma: "Action bar",
/// background 70%).
class OnboardingActionBar extends StatelessWidget {
  const OnboardingActionBar({
    super.key,
    required this.children,
    required this.keyboardOpen,
  });

  final List<Widget> children;
  final bool keyboardOpen;

  @override
  Widget build(BuildContext context) {
    final bottom = keyboardOpen
        ? 16.0
        : math.max(MediaQuery.viewPaddingOf(context).bottom + 8, 24.0);
    return ColoredBox(
      color: AppColors.background.withValues(alpha: 0.7),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 16, 16, bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Lora title with a grey description underneath (Figma: "Header",
/// 8px gap).
class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({
    super.key,
    required this.title,
    this.description,
    this.descriptionSpan,
    this.center = false,
  });

  final String title;
  final String? description;

  /// Rich description, e.g. with the phone number in bold.
  final InlineSpan? descriptionSpan;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final align = center ? TextAlign.center : TextAlign.start;
    final style = AppTextStyles.body1Regular.copyWith(color: AppColors.body2);
    final description = this.description;
    final span = descriptionSpan;
    return Column(
      crossAxisAlignment:
          center ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: AppTextStyles.heading3Bold, textAlign: align),
        ),
        if (description != null || span != null) ...[
          const SizedBox(height: 8),
          if (span != null)
            Text.rich(TextSpan(style: style, children: [span]), textAlign: align)
          else
            Text(description!, style: style, textAlign: align),
        ],
      ],
    );
  }
}

/// Illustration + centred title and description (Figma: "Invite sent",
/// "Invites Pending", "Invite no longer valid").
class OnboardingStatus extends StatelessWidget {
  const OnboardingStatus({
    super.key,
    required this.illustration,
    required this.title,
    required this.description,
    this.footer,
  });

  final Widget illustration;
  final String title;
  final String description;

  /// Extra content under the text (e.g. the invited people).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final footer = this.footer;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: illustration),
        const SizedBox(height: 24),
        OnboardingHeader(title: title, description: description, center: true),
        if (footer != null) ...[const SizedBox(height: 32), footer],
      ],
    );
  }
}

/// The stacked-card illustrations fade out at the top and bottom
/// (Figma draws background-coloured gradients; a mask works on any
/// background).
class FadedIllustration extends StatelessWidget {
  const FadedIllustration(this.asset, {super.key});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0x00000000),
          Color(0xFF000000),
          Color(0xFF000000),
          Color(0x00000000),
        ],
        stops: [0, 0.25, 0.75, 1],
      ).createShader(rect),
      child: SvgPicture.asset(asset, width: 59, height: 82),
    );
  }
}
