import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_select_field.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_toggle.dart';
import '../../../core/widgets/quantity_stepper.dart';
import '../domain/new_item.dart';

/// Opens the "Add item" bottom sheet (Figma section "Add item", 2290:16708).
/// Resolves to the new item, or null if the user closed the sheet.
Future<NewItem?> showAddItemSheet(
  BuildContext context, {
  required String listName,
  required List<String> stores,
}) {
  return showModalBottomSheet<NewItem>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    elevation: 0,
    backgroundColor: Colors.transparent,
    barrierColor: AppColors.overlay,
    builder: (context) => AddItemSheet(listName: listName, stores: stores),
  );
}

class AddItemSheet extends StatefulWidget {
  const AddItemSheet({
    super.key,
    required this.listName,
    required this.stores,
  });

  final String listName;
  final List<String> stores;

  @override
  State<AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<AddItemSheet> {
  final _name = TextEditingController();
  String? _store;
  int _quantity = 1;
  bool _urgent = false;

  bool get _canSubmit => _name.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    // Rebuild so the "Add item" button enables as soon as there's a name.
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canSubmit) return;
    Navigator.of(context).pop(
      NewItem(
        name: _name.text.trim(),
        store: _store,
        quantity: _quantity,
        urgent: _urgent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.viewPaddingOf(context).bottom;

    return Padding(
      // Keep the action bar sitting right on top of the keyboard.
      padding: EdgeInsets.only(bottom: keyboard),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _Header(
                      listName: widget.listName,
                      onClose: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 32),
                    AppTextField(
                      label: 'Item name',
                      hint: 'Enter item',
                      controller: _name,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => _submit(),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppSelectField<String>(
                            label: 'Store',
                            hint: 'Select Store',
                            options: widget.stores,
                            optionLabel: (store) => store,
                            value: _store,
                            onChanged: (store) =>
                                setState(() => _store = store),
                          ),
                        ),
                        const SizedBox(width: 16),
                        QuantityStepper(
                          value: _quantity,
                          onChanged: (q) => setState(() => _quantity = q),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            _ActionBar(
              urgent: _urgent,
              onUrgentChanged: (v) => setState(() => _urgent = v),
              onSubmit: _canSubmit ? _submit : null,
              // Figma: 20px between the button row and the keyboard.
              bottomPadding: keyboard > 0 ? 20 : 20 + safeBottom,
            ),
          ],
        ),
      ),
    );
  }
}

/// Title, subtitle and close button (Figma: "Item Details Header").
class _Header extends StatelessWidget {
  const _Header({required this.listName, required this.onClose});

  final String listName;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Figma keeps an invisible 32px icon on the left to balance the
        // close button; the title is centred between the two.
        const SizedBox(width: 32 + 20),
        Expanded(
          child: Column(
            children: [
              Text(
                'Add item',
                style: AppTextStyles.titleBold,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                'To $listName',
                style: AppTextStyles.body2Regular,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Tooltip(
          message: 'Close',
          child: InkResponse(
            onTap: onClose,
            radius: 20,
            child: SvgPicture.asset(
              AppIcons.closeCircle,
              width: 24,
              height: 24,
            ),
          ),
        ),
      ],
    );
  }
}

/// "Urgent" toggle and the submit button, pinned above the keyboard
/// (Figma: "Action bar").
class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.urgent,
    required this.onUrgentChanged,
    required this.onSubmit,
    required this.bottomPadding,
  });

  final bool urgent;
  final ValueChanged<bool> onUrgentChanged;
  final VoidCallback? onSubmit;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPadding),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
        boxShadow: [
          BoxShadow(color: AppColors.shadowActionBar, blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          MergeSemantics(
            child: GestureDetector(
              onTap: () => onUrgentChanged(!urgent),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Text('Urgent', style: AppTextStyles.body1Medium),
                    const SizedBox(width: 8),
                    AppToggle(value: urgent, onChanged: onUrgentChanged),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: AppButton(label: 'Add item', onPressed: onSubmit),
          ),
        ],
      ),
    );
  }
}
