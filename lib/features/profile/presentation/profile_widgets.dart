import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_back_link.dart';
import '../../onboarding/presentation/widgets/onboarding_scaffold.dart';

/// Small grey heading over a card (Figma: "Section heading", 10/18).
class ProfileSectionLabel extends StatelessWidget {
  const ProfileSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: AppTextStyles.xsMedium.copyWith(color: AppColors.body2),
      ),
    );
  }
}

/// White bordered card with hairlines between rows (Figma: "… list",
/// padding 16, gap 12).
class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.all(16),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceForeground,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        border: Border.all(color: AppColors.borderGrayLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) ...const [
              SizedBox(height: 12),
              SizedBox(
                height: 1,
                child: ColoredBox(color: AppColors.borderGrayLight),
              ),
              SizedBox(height: 12),
            ],
            children[i],
          ],
        ],
      ),
    );
  }
}

/// What sits at the end of a [ProfileRow].
enum ProfileRowTrailing { none, chevron, external }

/// Icon, title (and subtitle), an optional value and › or ↗
/// (Figma: rows on the Profile page).
class ProfileRow extends StatelessWidget {
  const ProfileRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.value,
    this.extra,
    this.trailing = ProfileRowTrailing.chevron,
    this.onTap,
  });

  /// 20px SVG asset.
  final String icon;
  final String title;
  final String? subtitle;

  /// Grey text before the chevron, e.g. "Match system".
  final String? value;

  /// Widget before the chevron (avatars, a badge, a toggle…).
  final Widget? extra;
  final ProfileRowTrailing trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final subtitle = this.subtitle;
    final value = this.value;
    final extra = this.extra;
    final grey =
        AppTextStyles.body2Regular.copyWith(color: AppColors.typographyQuaternary);

    return Semantics(
      button: onTap != null,
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Row(
          children: [
            SvgPicture.asset(icon, width: 20, height: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title, style: AppTextStyles.body1Medium),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: grey,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (value != null) ...[
              const SizedBox(width: 8),
              Text(value, style: grey),
            ],
            if (extra != null) ...[const SizedBox(width: 8), extra],
            switch (trailing) {
              ProfileRowTrailing.none => const SizedBox.shrink(),
              ProfileRowTrailing.chevron => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: SvgPicture.asset(
                    AppIcons.chevronRight,
                    width: 20,
                    height: 20,
                  ),
                ),
              ProfileRowTrailing.external => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Text(
                    '↗',
                    style: AppTextStyles.body1Medium.copyWith(fontSize: 21),
                    semanticsLabel: 'Opens outside the app',
                  ),
                ),
            },
          ],
        ),
      ),
    );
  }
}

/// Green "Verified" pill (Figma: "Badgs", success).
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: const BoxDecoration(
        color: Color(0xFFE4F6ED),
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SvgPicture.asset(AppIcons.verified, width: 12, height: 12),
          const SizedBox(width: 4),
          Text(
            'Verified',
            style: AppTextStyles.badge.copyWith(color: const Color(0xFF128E55)),
          ),
        ],
      ),
    );
  }
}

/// Page frame for the profile sub-pages: "← Profile setting" back link,
/// optional title and description, scrolling body and a bottom action bar.
class ProfilePage extends StatelessWidget {
  const ProfilePage({
    super.key,
    required this.body,
    this.title,
    this.description,
    this.backLabel = 'Profile setting',
    this.actions = const [],
    this.bodyPadding = const EdgeInsets.fromLTRB(16, 4, 16, 24),
  });

  final Widget body;
  final String? title;
  final String? description;
  final String backLabel;
  final List<Widget> actions;
  final EdgeInsetsGeometry bodyPadding;

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final title = this.title;
    final description = this.description;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
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
                  child: AppBackLink(label: backLabel),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: bodyPadding,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (title != null)
                        Text(
                          title,
                          style: AppTextStyles.titleBold
                              .copyWith(color: AppColors.headingBlack),
                        ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: AppTextStyles.body2Regular
                              .copyWith(color: AppColors.body1),
                        ),
                      ],
                      if (title != null || description != null)
                        const SizedBox(height: 20),
                      body,
                    ],
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
      ),
    );
  }
}

/// 20px radio indicator (Figma: round "_Checkbox base" with a dot).
class RadioDot extends StatelessWidget {
  const RadioDot({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      checked: selected,
      inMutuallyExclusiveGroup: true,
      child: Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.surfaceForeground,
          border: Border.all(color: AppColors.primary),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: selected ? 10 : 0,
          height: selected ? 10 : 0,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
