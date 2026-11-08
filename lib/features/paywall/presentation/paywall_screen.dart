import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_link_button.dart';
import '../../../core/widgets/glass_surface.dart';
import '../../../data/invites.dart';
import '../../../data/pear_repository.dart';
import '../../onboarding/presentation/widgets/onboarding_backdrop.dart';
import '../../onboarding/presentation/widgets/onboarding_scaffold.dart';

/// Opens the paywall; true when the user subscribed.
Future<bool> showPaywall(BuildContext context) async {
  final result = await Navigator.of(context).push<bool>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => const PaywallScreen(),
    ),
  );
  return result ?? false;
}

enum PaywallPlan { yearly, monthly }

/// "Better together" Pro paywall (Figma "Subscribe" 2805:22928 / 23040).
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  PaywallPlan _plan = PaywallPlan.yearly;
  bool _busy = false;

  // TODO: replace with the in-app purchase flow (e.g. `in_app_purchase` or
  // RevenueCat) and read prices from the store.
  Future<void> _subscribe() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    PearScope.read(context).upgradeToPro();
    Navigator.of(context).pop(true);
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No previous purchases found.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final yearly = _plan == PaywallPlan.yearly;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.paywallBackground,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  const Positioned.fill(child: OnboardingBackdrop.paywall()),
                  const Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    height: 300,
                    child: _PerspectiveGrid(),
                  ),
                  SafeArea(
                    bottom: false,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              OnboardingBackButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              ),
                              const Spacer(),
                              GlassTextButton(
                                label: 'Skip',
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          const _Title(),
                          const SizedBox(height: 8),
                          Text(
                            'One payment covers everyone. Share every list '
                            'and shop in sync.',
                            style: GoogleFonts.interTight(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              height: 24 / 18,
                              color: AppColors.textOnButton,
                            ),
                          ),
                          const SizedBox(height: 20),
                          for (final f in const [
                            'Invite up to $kProInviteLimit people',
                            'AI Smart Aisle matching',
                            'Shared lists for the whole household',
                          ]) ...[
                            _Feature(f),
                            const SizedBox(height: 12),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _PlansPanel(
              plan: _plan,
              busy: _busy,
              onPlanChanged: (p) => setState(() => _plan = p),
              ctaLabel: yearly ? 'Continue for \$0.00' : 'Continue with Monthly',
              onContinue: _subscribe,
              onRestore: _restore,
            ),
          ],
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title();

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.lora(
      fontSize: 32,
      fontWeight: FontWeight.w700,
      color: AppColors.textOnButton,
    );
    return Semantics(
      header: true,
      label: 'Better together',
      excludeSemantics: true,
      child: Row(
        children: [
          Text('Better ', style: style),
          ShaderMask(
            blendMode: BlendMode.srcIn,
            shaderCallback: (rect) => const LinearGradient(
              colors: [AppColors.textOnButton, AppColors.gold],
            ).createShader(rect),
            child: Text('together', style: style),
          ),
        ],
      ),
    );
  }
}

class _Feature extends StatelessWidget {
  const _Feature(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(2),
          child: SvgPicture.asset(AppIcons.tickCircleGold, width: 18, height: 18),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body1Regular
                .copyWith(color: AppColors.textOnButton),
          ),
        ),
      ],
    );
  }
}

/// Faint perspective grid at the top (Figma: "Pattern", 50% opacity).
class _PerspectiveGrid extends StatelessWidget {
  const _PerspectiveGrid();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (rect) => const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x80000000), Color(0x00000000)],
        ).createShader(rect),
        child: const CustomPaint(painter: _GridPainter(), size: Size.infinite),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.gold.withValues(alpha: 0.6)
      ..strokeWidth = 0.6;
    final w = size.width;
    final h = size.height;
    // Horizontal lines get closer towards the horizon (bottom).
    for (var i = 0; i <= 14; i++) {
      final t = i / 14;
      final y = h * (1 - (1 - t) * (1 - t));
      canvas.drawLine(Offset(0, y), Offset(w, y), paint);
    }
    // Lines converging on a vanishing point below the grid.
    final vanish = Offset(w / 2, h * 1.6);
    for (var i = -12; i <= 12; i++) {
      final top = Offset(w / 2 + i * w / 8, 0);
      canvas.drawLine(top, Offset.lerp(top, vanish, h / vanish.dy)!, paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}

class _PlansPanel extends StatelessWidget {
  const _PlansPanel({
    required this.plan,
    required this.busy,
    required this.onPlanChanged,
    required this.ctaLabel,
    required this.onContinue,
    required this.onRestore,
  });

  final PaywallPlan plan;
  final bool busy;
  final ValueChanged<PaywallPlan> onPlanChanged;
  final String ctaLabel;
  final VoidCallback onContinue;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final linkStyle =
        AppTextStyles.body2Regular.copyWith(color: AppColors.body1);
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottom > 0 ? bottom + 8 : 24),
      decoration: const BoxDecoration(
        color: AppColors.surfaceForeground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowSmall,
            offset: Offset(0, -2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PlanOption(
            selected: plan == PaywallPlan.yearly,
            ribbon: 'Best value : save 50%',
            title: '12 Months',
            subtitle: '\$29.99 per year after trial',
            price: '\$2.50',
            unit: 'mo',
            onTap: () => onPlanChanged(PaywallPlan.yearly),
          ),
          const SizedBox(height: 16),
          _PlanOption(
            selected: plan == PaywallPlan.monthly,
            title: '1 Month',
            subtitle: 'Cancel anytime',
            price: '\$4.99',
            unit: plan == PaywallPlan.monthly ? 'month' : 'mo',
            onTap: () => onPlanChanged(PaywallPlan.monthly),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: busy ? 'Please wait…' : ctaLabel,
            variant: AppButtonVariant.green,
            onPressed: busy ? null : onContinue,
          ),
          const SizedBox(height: 16),
          Center(
            child: AppLinkButton(
              label: 'Restore',
              onPressed: busy ? null : onRestore,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // TODO: open the legal pages once their URLs exist.
              for (final label in const ['Terms and conditions', 'Privacy', 'EULA'])
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.body1,
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                  ),
                  child: Text(label, style: linkStyle),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One plan. The selected one gets the gold ring (and its ribbon); the
/// yearly ribbon stays visible in grey when not selected.
class _PlanOption extends StatelessWidget {
  const _PlanOption({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.unit,
    required this.onTap,
    this.ribbon,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final String price;
  final String unit;
  final String? ribbon;
  final VoidCallback onTap;

  static const _gold = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC99A62), Color(0xFFFFA940), Color(0xFFFA8C16)],
  );

  @override
  Widget build(BuildContext context) {
    final ribbon = this.ribbon;
    final card = Container(
      height: 82,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceForeground,
        borderRadius: BorderRadius.circular(16),
        border: selected || ribbon != null
            ? null
            : Border.all(color: AppColors.borderGrayLight),
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x1A000000),
                  offset: Offset(0, 12),
                  blurRadius: 32,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body1Medium),
                const SizedBox(height: 2),
                Text(subtitle, style: AppTextStyles.body2Regular),
              ],
            ),
          ),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: price,
                  style: AppTextStyles.titleBold
                      .copyWith(color: AppColors.headingBlack),
                ),
                TextSpan(
                  text: ' / ',
                  style: AppTextStyles.body2Regular
                      .copyWith(color: AppColors.headingBlack),
                ),
                TextSpan(text: unit, style: AppTextStyles.body2Regular),
              ],
            ),
          ),
        ],
      ),
    );

    final framed = ribbon == null && !selected
        ? card
        : Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: selected ? null : AppColors.borderGrayLight,
              gradient: selected ? _gold : null,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                if (ribbon != null)
                  SizedBox(
                    height: 30,
                    child: Center(
                      child: Text(
                        ribbon,
                        style: AppTextStyles.body2SemiBold.copyWith(
                          color: selected
                              ? AppColors.textOnButton
                              : AppColors.body1,
                        ),
                      ),
                    ),
                  ),
                card,
              ],
            ),
          );

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: framed,
      ),
    );
  }
}
