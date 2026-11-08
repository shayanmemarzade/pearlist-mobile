import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_checkbox.dart';
import '../../../core/widgets/app_pill_field.dart';
import '../../onboarding/presentation/widgets/onboarding_scaffold.dart';
import '../domain/sign_up_draft.dart';
import 'phone_number_screen.dart';

/// Top US grocery chains offered in sign-up (Figma "Sign up - Store").
const List<String> kSuggestedStores = [
  'Whole Foods',
  'Costco',
  'Target',
  'Walmart',
];

/// Sign up — favourite stores (Figma 2184:6604 / 6651 / 6700).
class SignUpStoresScreen extends StatefulWidget {
  const SignUpStoresScreen({super.key, required this.draft});

  final SignUpDraft draft;

  @override
  State<SignUpStoresScreen> createState() => _SignUpStoresScreenState();
}

class _SignUpStoresScreenState extends State<SignUpStoresScreen> {
  final _controller = TextEditingController();
  late final List<String> _stores = [
    ...kSuggestedStores,
    for (final s in widget.draft.stores)
      if (!kSuggestedStores.contains(s)) s,
  ];
  late final Set<String> _selected = {...widget.draft.stores};

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _typed => _controller.text.trim();

  void _add() {
    final name = _typed;
    if (name.isEmpty) return;
    setState(() {
      final existing = _stores
          .where((s) => s.toLowerCase() == name.toLowerCase())
          .firstOrNull;
      final store = existing ?? name;
      if (existing == null) _stores.add(store);
      _selected.add(store);
      _controller.clear();
    });
  }

  void _next() {
    widget.draft.stores = [
      for (final s in _stores)
        if (_selected.contains(s)) s,
    ];
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PhoneNumberScreen(mode: AuthMode.signUp, draft: widget.draft),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canAdd = _typed.isNotEmpty;
    return OnboardingScaffold(
      actions: [
        AppButton(
          label: 'Next',
          onPressed: _selected.isEmpty ? null : _next,
        ),
      ],
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const OnboardingHeader(
            title: 'Your favorite grocery stores',
            description: 'Top stores in the United States. Select or add '
                'your own, then continue.',
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.surfaceForeground,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Column(
              children: [
                for (var i = 0; i < _stores.length; i++) ...[
                  if (i > 0) const AppDivider(),
                  _StoreRow(
                    name: _stores[i],
                    selected: _selected.contains(_stores[i]),
                    onChanged: (v) => setState(() {
                      final store = _stores[i];
                      v ? _selected.add(store) : _selected.remove(store);
                    }),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
          const AppDivider(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: AppPillField(
                  hint: 'Add a store',
                  controller: _controller,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  prefixIcon:
                      SvgPicture.asset(AppIcons.shop, width: 18, height: 18),
                  onChanged: (_) => setState(() {}),
                  onSubmitted: (_) => _add(),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 88,
                child: AppButton(
                  label: 'Add',
                  onPressed: canAdd ? _add : null,
                  icon: SvgPicture.asset(
                    AppIcons.addWhite,
                    width: 18,
                    height: 18,
                    colorFilter: canAdd
                        ? null
                        : const ColorFilter.mode(
                            AppColors.textDisable,
                            BlendMode.srcIn,
                          ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StoreRow extends StatelessWidget {
  const _StoreRow({
    required this.name,
    required this.selected,
    required this.onChanged,
  });

  final String name;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!selected),
        child: Padding(
          // With the checkbox's 6px tap padding this gives Figma's 20px
          // gap between rows.
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Transform.translate(
                offset: const Offset(-6, 0),
                child: AppCheckbox(
                  value: selected,
                  onChanged: onChanged,
                  size: 16,
                  radius: 4,
                  semanticLabel: name,
                ),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.body2Medium
                      .copyWith(color: AppColors.body1),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
