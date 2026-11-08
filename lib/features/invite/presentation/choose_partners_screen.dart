import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_back_link.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_checkbox.dart';
import '../../../core/widgets/app_input_shell.dart';
import '../../../data/contacts.dart';
import '../../../data/pear_repository.dart';
import '../../../data/services.dart';
import '../../onboarding/presentation/widgets/onboarding_scaffold.dart';

/// Pick people from contacts (Figma "Choose partners · 2 / 4 selected",
/// 2184:9160 / 9112). Pops with the chosen contacts.
class ChoosePartnersScreen extends StatefulWidget {
  const ChoosePartnersScreen({super.key});

  @override
  State<ChoosePartnersScreen> createState() => _ChoosePartnersScreenState();
}

class _ChoosePartnersScreenState extends State<ChoosePartnersScreen> {
  final _search = TextEditingController();
  final List<Contact> _selected = [];
  List<Contact>? _contacts;

  /// Initial-avatar colours, cycled by position (Figma).
  static const _palettes = [
    (Color(0xFFF8EBDD), Color(0xFF956237)),
    (Color(0xFFEFF2FF), Color(0xFF4359AF)),
    (Color(0xFFDBEBDE), Color(0xFF386641)),
  ];

  @override
  void initState() {
    super.initState();
    AppServices.contacts.load().then((value) {
      if (mounted) setState(() => _contacts = value);
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _toggle(Contact c, int limit) {
    setState(() {
      if (_selected.contains(c)) {
        _selected.remove(c);
      } else if (_selected.length < limit) {
        _selected.add(c);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final limit = PearScope.of(context).invitesLeft;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final all = _contacts;
    final query = _search.text.trim().toLowerCase();
    final shown = all == null
        ? const <Contact>[]
        : [
            for (final c in all)
              if (query.isEmpty ||
                  c.name.toLowerCase().contains(query) ||
                  c.phone.replaceAll(RegExp(r'\D'), '').contains(query))
                c,
          ];
    final full = _selected.length >= limit;

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
                padding: const EdgeInsets.fromLTRB(6, 12, 16, 0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: AppBackLink(
                    label: 'Choose partners',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  children: [
                    Text(
                      'Pick up to $limit ${limit == 1 ? 'person' : 'people'}. '
                      'Each gets a text with a link to join your Pear List.',
                      style: AppTextStyles.body2Medium,
                    ),
                    const SizedBox(height: 16),
                    _SearchField(
                      controller: _search,
                      onChanged: (_) => setState(() {}),
                    ),
                    if (_selected.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final c in _selected)
                            _SelectedChip(
                              name: c.name,
                              onRemove: () => setState(() => _selected.remove(c)),
                            ),
                        ],
                      ),
                    ],
                    if (full && limit > 0) ...[
                      const SizedBox(height: 12),
                      const _LimitNotice(),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Contacts',
                            style: AppTextStyles.body2Medium,
                          ),
                        ),
                        Text(
                          '${_selected.length} of $limit selected',
                          style: AppTextStyles.smallRegular,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (all == null)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    else if (shown.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No contacts match “${_search.text.trim()}”',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body2Regular,
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceForeground,
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        child: Column(
                          children: [
                            for (var i = 0; i < shown.length; i++)
                              _ContactRow(
                                contact: shown[i],
                                palette:
                                    _palettes[all.indexOf(shown[i]) % _palettes.length],
                                selected: _selected.contains(shown[i]),
                                enabled: !full || _selected.contains(shown[i]),
                                last: i == shown.length - 1,
                                onTap: () => _toggle(shown[i], limit),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              OnboardingActionBar(
                keyboardOpen: keyboardOpen,
                children: [
                  AppButton(
                    label: 'Continue',
                    onPressed: _selected.isEmpty
                        ? null
                        : () => Navigator.of(context).pop([..._selected]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppInputShell(
      radius: 12,
      child: Row(
        children: [
          SvgPicture.asset(AppIcons.search, width: 20, height: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.headingBlack,
              style: AppTextStyles.body1Regular,
              decoration: InputDecoration.collapsed(
                hintText: 'Search contacts',
                hintStyle: AppTextStyles.body1Regular
                    .copyWith(color: AppColors.textDisable),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedChip extends StatelessWidget {
  const _SelectedChip({required this.name, required this.onRemove});

  final String name;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Remove $name',
      excludeSemantics: true,
      child: InkWell(
        onTap: onRemove,
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Container(
          height: 32,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.surfacePrimaryLight,
            borderRadius: const BorderRadius.all(Radius.circular(16)),
            border: Border.all(color: AppColors.borderPrimary),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: AppTextStyles.body2Medium
                    .copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(width: 4),
              SvgPicture.asset(AppIcons.closeSmall, width: 12, height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _LimitNotice extends StatelessWidget {
  const _LimitNotice();

  @override
  Widget build(BuildContext context) {
    final style =
        AppTextStyles.body2Regular.copyWith(color: AppColors.textWarning);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.secondary100,
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(AppIcons.infoWarning, width: 18, height: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: style,
                children: [
                  TextSpan(
                    text: 'That’s everyone Pro allows. ',
                    style: AppTextStyles.body2Bold
                        .copyWith(color: AppColors.textWarning),
                  ),
                  const TextSpan(
                    text: 'Remove someone to pick a different person.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.contact,
    required this.palette,
    required this.selected,
    required this.enabled,
    required this.last,
    required this.onTap,
  });

  final Contact contact;
  final (Color, Color) palette;
  final bool selected;
  final bool enabled;
  final bool last;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: MergeSemantics(
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: Container(
            height: 56,
            decoration: last
                ? null
                : const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: AppColors.borderGrayLight),
                    ),
                  ),
            child: Row(
              children: [
                AppAvatar(
                  name: contact.name,
                  size: 32,
                  background: palette.$1,
                  foreground: palette.$2,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(contact.name, style: AppTextStyles.body2Bold),
                      Text(
                        contact.phone,
                        style: AppTextStyles.xsRegular
                            .copyWith(color: AppColors.body2),
                      ),
                    ],
                  ),
                ),
                AppCheckbox(
                  value: selected,
                  size: 20,
                  radius: 10,
                  semanticLabel: contact.name,
                  onChanged: enabled ? (_) => onTap() : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
