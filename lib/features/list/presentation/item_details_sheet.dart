import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/time_format.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_bottom_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_select_field.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_toggle.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../../../core/widgets/read_only_field.dart';
import '../../../data/models.dart';

enum ItemSheetAction { remove, toggleBought }

/// Edits made in the sheet. The caller saves them after the sheet closes, so
/// closing it any way (✕, swipe, tapping outside) keeps your changes.
class ItemDraft {
  ItemDraft.from(ShoppingItem item)
      : name = item.name,
        store = item.store,
        quantity = item.quantity,
        urgent = item.urgent;

  String name;
  String? store;
  int quantity;
  bool urgent;

  String get _cleanName => name.trim();

  bool differsFrom(ShoppingItem item) =>
      (_cleanName.isNotEmpty && _cleanName != item.name) ||
      store != item.store ||
      quantity != item.quantity ||
      urgent != item.urgent;

  ShoppingItem applyTo(ShoppingItem item) => item.copyWith(
        name: _cleanName.isEmpty ? item.name : _cleanName,
        store: () => store,
        quantity: quantity,
        urgent: urgent,
      );
}

/// Item details sheet (Figma section "item view").
///
/// Items you added are editable, with a remove button; items someone else
/// added are shown read-only ("view by partner").
Future<ItemSheetAction?> showItemDetailsSheet(
  BuildContext context, {
  required ShoppingItem item,
  required ShoppingList list,
  required ItemDraft draft,
  required bool editable,
}) {
  return showAppSheet<ItemSheetAction>(
    context,
    builder: (context) => _ItemDetailsSheet(
      item: item,
      list: list,
      draft: draft,
      editable: editable,
    ),
  );
}

class _ItemDetailsSheet extends StatefulWidget {
  const _ItemDetailsSheet({
    required this.item,
    required this.list,
    required this.draft,
    required this.editable,
  });

  final ShoppingItem item;
  final ShoppingList list;
  final ItemDraft draft;
  final bool editable;

  @override
  State<_ItemDetailsSheet> createState() => _ItemDetailsSheetState();
}

class _ItemDetailsSheetState extends State<_ItemDetailsSheet> {
  late final _name = TextEditingController(text: widget.draft.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _close(ItemSheetAction action) => Navigator.of(context).pop(action);

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final draft = widget.draft;
    final editable = widget.editable;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return AppSheetFrame(
      bottomBar: AppBottomBar(
        keyboardOpen: keyboardOpen,
        child: AppButton(
          label: item.isBought ? 'Move back to list' : 'Mark as bought',
          variant: AppButtonVariant.green,
          icon: item.isBought
              ? null
              : SvgPicture.asset(
                  AppIcons.tickCircleWhite,
                  width: 18,
                  height: 18,
                ),
          onPressed: () => _close(ItemSheetAction.toggleBought),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetHeader(
            title: 'Item details',
            subtitle: widget.list.name,
            leading: editable
                ? Tooltip(
                    message: 'Remove item',
                    child: InkResponse(
                      onTap: () => _close(ItemSheetAction.remove),
                      radius: 20,
                      child: SvgPicture.asset(
                        AppIcons.trash,
                        width: 24,
                        height: 24,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 32),
          if (editable)
            AppTextField(
              label: 'Item name',
              hint: 'Enter item',
              controller: _name,
              onChanged: (v) => draft.name = v,
              textInputAction: TextInputAction.done,
            )
          else
            ReadOnlyField(
              label: 'Item name',
              value: item.name,
              trailing: item.urgent ? const AppBadge.urgent() : null,
            ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: editable
                    ? AppSelectField<String>(
                        label: 'Store',
                        hint: 'Select Store',
                        options: [...widget.list.stores, kAnyStore],
                        optionLabel: (s) => s,
                        value: draft.store,
                        onChanged: (s) => setState(
                          () => draft.store = s == kAnyStore ? null : s,
                        ),
                      )
                    : ReadOnlyField(
                        label: 'Store',
                        value: item.store ?? kAnyStore,
                      ),
              ),
              const SizedBox(width: 16),
              if (editable)
                QuantityStepper(
                  value: draft.quantity,
                  onChanged: (q) => setState(() => draft.quantity = q),
                )
              else
                SizedBox(
                  width: 109,
                  child: ReadOnlyField(
                    label: 'Quantity',
                    value: '${item.quantity}',
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (editable) ...[
            _UrgentRow(
              value: draft.urgent,
              onChanged: (v) => setState(() => draft.urgent = v),
            ),
            const SizedBox(height: 16),
          ],
          _AddedBy(item: item),
        ],
      ),
    );
  }
}

/// ⚑ Urgent ─── toggle (Figma: "List items" in item details).
class _UrgentRow extends StatelessWidget {
  const _UrgentRow({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              SvgPicture.asset(AppIcons.flag, width: 24, height: 24),
              const SizedBox(width: 8),
              Expanded(child: Text('Urgent', style: AppTextStyles.body1Medium)),
              AppToggle(value: value, onChanged: onChanged),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Added by you · 2d ago · Edited 1h ago".
class _AddedBy extends StatelessWidget {
  const _AddedBy({required this.item});

  final ShoppingItem item;

  @override
  Widget build(BuildContext context) {
    final who = item.addedBy.isMe ? 'you' : item.addedBy.firstName;
    final edited = item.editedAt;
    final text = [
      'Added by $who',
      formatTimeAgo(item.addedAt).toLowerCase(),
      if (edited != null) 'Edited ${formatTimeAgo(edited).toLowerCase()}',
    ].join(' · ');

    return Row(
      children: [
        AppAvatar(
          name: item.addedBy.name,
          imageUrl: item.addedBy.avatarUrl,
          size: 24,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.smallRegular.copyWith(color: AppColors.body1),
          ),
        ),
      ],
    );
  }
}
