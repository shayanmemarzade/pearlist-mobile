import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_bottom_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_compact_button.dart';
import '../../../core/widgets/app_input_shell.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_toggle.dart';
import '../../../data/models.dart';
import '../../../data/pear_repository.dart';
import '../../invite/presentation/share_lists_screen.dart';
import '../../paywall/presentation/paywall_screen.dart';
import '../domain/new_list.dart';

/// Opens the "Add new list" sheet (Figma section "Add list", 2959:13102).
/// Resolves to the new list's details, or null if closed.
Future<NewList?> showAddListSheet(
  BuildContext context, {
  String? initialName,
  ListKind initialKind = ListKind.shopping,
}) {
  return showAppSheet<NewList>(
    context,
    builder: (context) =>
        _AddListSheet(initialName: initialName, initialKind: initialKind),
  );
}

class _AddListSheet extends StatefulWidget {
  const _AddListSheet({this.initialName, required this.initialKind});

  final String? initialName;

  /// Tab preselected from the page the sheet was opened on.
  final ListKind initialKind;

  @override
  State<_AddListSheet> createState() => _AddListSheetState();
}

class _AddListSheetState extends State<_AddListSheet> {
  late final _name = TextEditingController(text: widget.initialName);
  late ListKind _kind = widget.initialKind;
  bool _share = true;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _canSubmit => _name.text.trim().isNotEmpty;

  void _submit(bool canShare) {
    if (!_canSubmit) return;
    Navigator.of(context).pop(
      NewList(
        name: _name.text.trim(),
        kind: _kind,
        shareWithPartner: canShare && _share,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = PearScope.of(context);
    final partner = repo.partner;
    final canShare = repo.canShare && partner != null;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return AppSheetFrame(
      bottomBar: AppBottomBar(
        keyboardOpen: keyboardOpen,
        child: AppButton(
          label: 'Add list',
          onPressed: _canSubmit ? () => _submit(canShare) : null,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSheetHeader(title: 'Add new list'),
          const SizedBox(height: 32),
          const AppFieldLabel('Add it under'),
          const SizedBox(height: 2),
          _KindTabs(
            value: _kind,
            onChanged: (kind) => setState(() => _kind = kind),
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'List name',
            hint: 'Weekly groceries',
            controller: _name,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(canShare),
          ),
          const SizedBox(height: 20),
          const AppDivider(),
          const SizedBox(height: 20),
          Text('Who can see this list?', style: AppTextStyles.body2Medium),
          const SizedBox(height: 12),
          if (partner != null && canShare) ...[
            _ShareRow(
              partner: partner,
              value: _share,
              onChanged: (v) => setState(() => _share = v),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Select from contacts',
              variant: AppButtonVariant.greenOutline,
              icon: SvgPicture.asset(AppIcons.tagUser, width: 18, height: 18),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      const ShareListsScreen(mode: ShareListsMode.addPartner),
                ),
              ),
            ),
          ] else ...[
            const _OnlyYouRow(),
            const SizedBox(height: 12),
            _ProUpsellCard(
              onTryPro: () => showPaywall(context),
            ),
          ],
        ],
      ),
    );
  }
}

/// Shopping / Wishlist / Places (Figma: "Tabs / Tab bar").
class _KindTabs extends StatelessWidget {
  const _KindTabs({required this.value, required this.onChanged});

  final ListKind value;
  final ValueChanged<ListKind> onChanged;

  static const _icons = {
    ListKind.shopping: AppIcons.cart,
    ListKind.wishlist: AppIcons.navWishes,
    ListKind.places: AppIcons.navPlaces,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: AppColors.surfaceForeground,
        borderRadius: BorderRadius.all(Radius.circular(14)),
      ),
      child: Row(
        children: [
          for (final kind in ListKind.values) ...[
            if (kind != ListKind.values.first) const SizedBox(width: 8),
            Expanded(
              child: _KindTab(
                label: kind.label,
                icon: _icons[kind]!,
                selected: kind == value,
                onTap: () => onChanged(kind),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _KindTab extends StatelessWidget {
  const _KindTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.textPrimary : AppColors.body2;
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.surfacePrimaryLight
                : AppColors.surfacePrimaryLight.withAlpha(0),
            borderRadius: const BorderRadius.all(Radius.circular(12)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                icon,
                width: 18,
                height: 18,
                colorFilter: ColorFilter.mode(
                  selected ? AppColors.primary : AppColors.iconInactive,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.body2Medium.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareRow extends StatelessWidget {
  const _ShareRow({
    required this.partner,
    required this.value,
    required this.onChanged,
  });

  final Person partner;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          AppAvatar(name: partner.name, imageUrl: partner.avatarUrl),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share list with ${partner.firstName}',
                  style: AppTextStyles.body1Medium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Opens first when you launch Pear List',
                  style: AppTextStyles.body2Regular
                      .copyWith(color: AppColors.typographyQuaternary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppToggle(value: value, onChanged: onChanged, large: true),
        ],
      ),
    );
  }
}

class _OnlyYouRow extends StatelessWidget {
  const _OnlyYouRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(4),
          child: SvgPicture.asset(AppIcons.lock, width: 24, height: 24),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Only you', style: AppTextStyles.body1Medium),
              const SizedBox(height: 4),
              Text(
                'Lists on the free plan are private',
                style: AppTextStyles.body2Regular
                    .copyWith(color: AppColors.typographyQuaternary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// "Want to share this list?" card with a soft gradient edge.
class _ProUpsellCard extends StatelessWidget {
  const _ProUpsellCard({required this.onTryPro});

  final VoidCallback onTryPro;

  @override
  Widget build(BuildContext context) {
    // Figma blurs coloured ellipses behind the card; a gradient ring gives
    // the same edge glow without a blur layer.
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(18)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFF7D4C),
            Color(0xFF799B80),
            Color(0xFF00998E),
            Color(0xFF799B80),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(4),
                  child:
                      SvgPicture.asset(AppIcons.crown, width: 24, height: 24),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Want to share this list?',
                        style: AppTextStyles.body1Medium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Subscribe to Pro and invite your partner, one '
                        'payment for both of you.',
                        style: AppTextStyles.body2Regular
                            .copyWith(color: AppColors.body1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            AppCompactButton(
              label: 'Try pro free for 7 days',
              expand: true,
              onPressed: onTryPro,
            ),
          ],
        ),
      ),
    );
  }
}
