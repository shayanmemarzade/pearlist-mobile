import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_links.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_input_shell.dart';
import '../../../data/invites.dart';
import 'profile_widgets.dart';

/// Questions and answers (Figma "FAQ", 2269:7088).
// TODO: load these from the CMS / API so they can change without a release.
const List<({String question, String answer})> kFaqs = [
  (
    question: 'How does sharing work?',
    answer: 'Everyone on a shared list sees changes instantly. Add, check '
        'off or edit items from any phone, and items marked Only me stay '
        'private.',
  ),
  (
    question: 'How many partners can I add?',
    answer: 'Pro lets up to $kProInviteLimit people join your lists on one '
        'subscription. On the free plan your lists stay private to you.',
  ),
  (
    question: 'What does Smart Aisle do?',
    answer: 'When you add an item, Smart Aisle files it under the right '
        'aisle, so your list follows the way you walk through the store.',
  ),
  (
    question: 'Can I use Pear List without a subscription?',
    answer: 'Yes. The free plan has unlimited private lists. Sharing lists '
        'with a partner needs Pro.',
  ),
  (
    question: 'How do I change my phone number?',
    answer: 'Go to Profile → Account settings → Phone Number. '
        'We’ll text a code to the new number to confirm it.',
  ),
  (
    question: 'How do I cancel my subscription?',
    answer: 'Your subscription is billed by the App Store or Google Play. '
        'Cancel it from your store account’s subscriptions page; Pro '
        'stays on until the end of the period you paid for.',
  ),
];

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  final _search = TextEditingController();
  int? _open = 0;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim().toLowerCase();
    final faqs = [
      for (final (i, faq) in kFaqs.indexed)
        if (query.isEmpty ||
            faq.question.toLowerCase().contains(query) ||
            faq.answer.toLowerCase().contains(query))
          (index: i, faq: faq),
    ];

    return ProfilePage(
      actions: [
        AppButton(
          label: 'Email support',
          variant: AppButtonVariant.outline,
          icon: SvgPicture.asset(AppIcons.sms, width: 18, height: 18),
          onPressed: () => launchExternal(context, AppLinks.supportMail()),
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppInputShell(
            radius: 12,
            child: Row(
              children: [
                SvgPicture.asset(AppIcons.search, width: 20, height: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    cursorColor: AppColors.headingBlack,
                    style: AppTextStyles.body1Regular,
                    decoration: InputDecoration.collapsed(
                      hintText: 'Search questions',
                      hintStyle: AppTextStyles.body1Regular
                          .copyWith(color: AppColors.textDisable),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          if (faqs.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'No questions match “${_search.text.trim()}”. '
                'Email us and we’ll help.',
                textAlign: TextAlign.center,
                style: AppTextStyles.body2Regular,
              ),
            ),
          for (final (index: i, :faq) in faqs)
            _FaqItem(
              question: faq.question,
              answer: faq.answer,
              expanded: _open == i || query.isNotEmpty,
              last: faq == faqs.last.faq,
              onTap: () => setState(() => _open = _open == i ? null : i),
            ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  const _FaqItem({
    required this.question,
    required this.answer,
    required this.expanded,
    required this.last,
    required this.onTap,
  });

  final String question;
  final String answer;
  final bool expanded;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: last
          ? null
          : const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderGrayLight),
              ),
            ),
      child: Semantics(
        button: true,
        expanded: expanded,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(question, style: AppTextStyles.body1Bold),
                    ),
                    const SizedBox(width: 12),
                    SvgPicture.asset(
                      expanded ? AppIcons.minusCircle : AppIcons.plusCircle,
                      width: 24,
                      height: 24,
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: expanded
                      ? Padding(
                          padding: const EdgeInsets.only(top: 8, right: 36),
                          child: Text(
                            answer,
                            style: AppTextStyles.body2Regular,
                          ),
                        )
                      : const SizedBox(width: double.infinity),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
