import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_list_row.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../data/pear_repository.dart';
import 'widgets/settings_page_header.dart';

enum ManagedEntries {
  aisles(
    title: 'Manage aisles',
    description: 'Add or remove aisle categories for your shopping list. '
        'Smart Aisle files items into these.',
    hint: 'New aisle name',
    sectionLabel: 'Current aisles',
    noun: 'aisle',
  ),
  stores(
    title: 'Manage stores',
    description: 'Add or remove the stores you shop at. You can pick one '
        'for each item.',
    hint: 'Add a store',
    sectionLabel: 'Stores',
    noun: 'store',
  );

  const ManagedEntries({
    required this.title,
    required this.description,
    required this.hint,
    required this.sectionLabel,
    required this.noun,
  });

  final String title;
  final String description;
  final String hint;
  final String sectionLabel;
  final String noun;

  bool get isAisles => this == ManagedEntries.aisles;
}

/// Manage aisles / Manage stores (Figma section "List setting"): add,
/// rename in place, remove with undo and — for aisles — drag to reorder.
class ManageEntriesScreen extends StatefulWidget {
  const ManageEntriesScreen({
    super.key,
    required this.listId,
    required this.kind,
  });

  final String listId;
  final ManagedEntries kind;

  @override
  State<ManageEntriesScreen> createState() => _ManageEntriesScreenState();
}

class _ManageEntriesScreenState extends State<ManageEntriesScreen> {
  final _newEntry = TextEditingController();
  final _editEntry = TextEditingController();
  int? _editing;

  bool get _aisles => widget.kind.isAisles;

  @override
  void initState() {
    super.initState();
    _newEntry.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _newEntry.dispose();
    _editEntry.dispose();
    super.dispose();
  }

  double get _toastOffset =>
      AppBottomBar.heightOf(
        context,
        keyboardOpen: MediaQuery.viewInsetsOf(context).bottom > 0,
      ) +
      8;

  void _add() {
    final name = _newEntry.text.trim();
    if (name.isEmpty) return;
    final added = PearScope.read(context)
        .addEntry(widget.listId, name, aisle: _aisles);
    if (added) {
      _newEntry.clear();
    } else {
      showAppToast(
        context,
        message: 'There’s already a $name ${widget.kind.noun}.',
        bottomOffset: _toastOffset,
      );
    }
  }

  void _startEditing(int index, String current) {
    setState(() {
      _editing = index;
      _editEntry.text = current;
      _editEntry.selection =
          TextSelection.collapsed(offset: _editEntry.text.length);
    });
  }

  void _saveEdit() {
    final index = _editing;
    final name = _editEntry.text.trim();
    if (index != null && name.isNotEmpty) {
      PearScope.read(context)
          .renameEntry(widget.listId, index, name, aisle: _aisles);
    }
    _cancelEdit();
  }

  void _cancelEdit() {
    FocusScope.of(context).unfocus();
    setState(() => _editing = null);
  }

  void _remove(int index) {
    final repo = PearScope.read(context);
    final name = repo.removeEntry(widget.listId, index, aisle: _aisles);
    setState(() => _editing = null);
    showAppToast(
      context,
      message: 'The $name ${widget.kind.noun} has been removed.',
      bottomOffset: _toastOffset,
      onUndo: () =>
          repo.restoreEntry(widget.listId, index, name, aisle: _aisles),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = PearScope.of(context);
    final list = repo.listById(widget.listId);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    if (list == null) {
      return const Scaffold(backgroundColor: AppColors.background);
    }
    final entries = _aisles ? list.aisles : list.stores;
    final editing = _editing;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: SettingsPageHeader(
                backLabel: 'Back to list',
                title: widget.kind.title,
                description: widget.kind.description,
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  _AddRow(
                    controller: _newEntry,
                    hint: widget.kind.hint,
                    icon: _aisles ? AppIcons.addGray : AppIcons.store,
                    onAdd: _add,
                  ),
                  const SizedBox(height: 20),
                  SectionLabel(widget.kind.sectionLabel),
                  if (entries.isEmpty)
                    AppCard(
                      child: Text(
                        'No ${widget.kind.noun}s yet.',
                        style: AppTextStyles.body2Regular,
                      ),
                    )
                  else
                    AppCard(
                      child: ReorderableListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        buildDefaultDragHandles: false,
                        itemCount: entries.length,
                        onReorderItem: (from, to) => repo.reorderEntries(
                          list.id,
                          from,
                          to,
                          aisle: _aisles,
                        ),
                        proxyDecorator: (child, index, animation) => Material(
                          color: AppColors.surfaceForeground,
                          elevation: 4,
                          shadowColor: AppColors.shadowMedium,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                          child: child,
                        ),
                        itemBuilder: (context, i) => Column(
                          key: ValueKey(entries[i]),
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (i > 0) ...const [
                              SizedBox(height: 16),
                              AppDivider(),
                              SizedBox(height: 16),
                            ],
                            if (editing == i)
                              _EditField(
                                controller: _editEntry,
                                onSubmitted: _saveEdit,
                              )
                            else
                              _EntryRow(
                                name: entries[i],
                                dragIndex: _aisles && editing == null
                                    ? i
                                    : null,
                                onEdit: () => _startEditing(i, entries[i]),
                                onRemove: () => _remove(i),
                              ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            AppBottomBar(
              keyboardOpen: keyboardOpen,
              child: editing == null
                  ? AppButton(
                      label: 'Done',
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: 'Cancel',
                            variant: AppButtonVariant.outline,
                            onPressed: _cancelEdit,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: AppButton(label: 'Save', onPressed: _saveEdit),
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

class _AddRow extends StatelessWidget {
  const _AddRow({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.onAdd,
  });

  final TextEditingController controller;
  final String hint;
  final String icon;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final enabled = controller.text.trim().isNotEmpty;
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            hint: hint,
            controller: controller,
            prefixIcon: SvgPicture.asset(icon, width: 18, height: 18),
            textInputAction: TextInputAction.done,
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => onAdd(),
          ),
        ),
        const SizedBox(width: 8),
        // Figma: 88×46 "Add" button, grey until there's something to add.
        Material(
          color: enabled
              ? AppColors.buttonPrimary
              : AppColors.buttonBlackDisable,
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onAdd : null,
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    AppIcons.addWhite,
                    width: 18,
                    height: 18,
                    colorFilter: enabled
                        ? null
                        : const ColorFilter.mode(
                            AppColors.textDisable,
                            BlendMode.srcIn,
                          ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Add',
                    style: AppTextStyles.body1Medium.copyWith(
                      color: enabled
                          ? AppColors.textOnButton
                          : AppColors.textDisable,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.name,
    required this.onEdit,
    required this.onRemove,
    this.dragIndex,
  });

  final String name;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  /// Set for reorderable rows (aisles).
  final int? dragIndex;

  @override
  Widget build(BuildContext context) {
    final dragIndex = this.dragIndex;
    return SizedBox(
      height: 32,
      child: Row(
        children: [
          if (dragIndex != null) ...[
            ReorderableDragStartListener(
              index: dragIndex,
              child:
                  SvgPicture.asset(AppIcons.dragHandle, width: 24, height: 24),
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.body2Medium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          _IconAction(
            icon: AppIcons.edit,
            tooltip: 'Rename $name',
            onTap: onEdit,
          ),
          const SizedBox(width: 16),
          _IconAction(
            icon: AppIcons.removeCircle,
            tooltip: 'Remove $name',
            onTap: onRemove,
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final String icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 20,
        child: SvgPicture.asset(icon, width: 24, height: 24),
      ),
    );
  }
}

/// Inline rename field (Figma: edit state — green-bordered input).
class _EditField extends StatelessWidget {
  const _EditField({required this.controller, required this.onSubmitted});

  final TextEditingController controller;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: AppColors.surfaceForeground,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: TextField(
        controller: controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => onSubmitted(),
        cursorColor: AppColors.headingBlack,
        style: AppTextStyles.body2Medium,
        decoration: const InputDecoration.collapsed(hintText: ''),
      ),
    );
  }
}
