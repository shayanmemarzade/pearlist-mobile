import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_avatar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_list_row.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/app_toggle.dart';
import '../../../data/pear_repository.dart';

/// Where to go after the settings sheet closes.
enum ListSettingsAction { sharing, stores, aisles, clearBought, clearAll }

/// The list name as edited in the sheet; the caller saves it on close.
class ListSettingsDraft {
  ListSettingsDraft(this.name);
  String name;
}

/// "List setting" sheet (Figma: "List page - Setting"). Toggles apply right
/// away; navigation and destructive actions are returned to the caller.
Future<ListSettingsAction?> showListSettingsSheet(
  BuildContext context, {
  required String listId,
  required ListSettingsDraft draft,
}) {
  return showAppSheet<ListSettingsAction>(
    context,
    builder: (context) => _ListSettingsSheet(listId: listId, draft: draft),
  );
}

class _ListSettingsSheet extends StatefulWidget {
  const _ListSettingsSheet({required this.listId, required this.draft});

  final String listId;
  final ListSettingsDraft draft;

  @override
  State<_ListSettingsSheet> createState() => _ListSettingsSheetState();
}

class _ListSettingsSheetState extends State<_ListSettingsSheet> {
  late final _name = TextEditingController(text: widget.draft.name);

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _go(ListSettingsAction action) => Navigator.of(context).pop(action);

  static Widget _icon(String asset) =>
      SvgPicture.asset(asset, width: 24, height: 24);

  static final Widget _chevron = _icon(AppIcons.chevronRight);

  @override
  Widget build(BuildContext context) {
    final repo = PearScope.of(context);
    final list = repo.listById(widget.listId);
    if (list == null) return const SizedBox.shrink();

    final others = list.activeMembers.where((p) => !p.isMe).toList();
    final sharing = switch (others.length) {
      0 => 'Only you can edit',
      1 => 'You and ${others.first.firstName} can edit',
      _ => 'You and ${others.length} others can edit',
    };
    final stores = list.stores.isEmpty
        ? 'No stores yet'
        : [
            ...list.stores.take(2),
            if (list.stores.length > 2) '+${list.stores.length - 2}',
          ].join(', ');

    return AppSheetFrame(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Figma: "Settings header" — left-aligned title over a hairline.
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: AppColors.borderGrayLight),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text('List setting', style: AppTextStyles.titleBold),
                ),
                const SizedBox(width: 10),
                const SheetCloseButton(),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AppTextField(
            label: 'List name',
            labelColor: AppColors.body2,
            hint: list.name,
            controller: _name,
            onChanged: (v) => widget.draft.name = v,
            textInputAction: TextInputAction.done,
          ),
          const SizedBox(height: 16),
          const SectionLabel('General'),
          GroupedCard(
            children: [
              AppListRow(
                leading: _icon(AppIcons.flag),
                title: 'Default list',
                subtitle: 'List appears at the top',
                trailing: AppToggle(
                  value: list.isDefault,
                  onChanged: (v) => repo.setDefault(list.id, v),
                ),
              ),
              AppListRow(
                leading: _icon(AppIcons.users),
                title: 'Sharing',
                subtitle: sharing,
                onTap: () => _go(ListSettingsAction.sharing),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (others.isNotEmpty) ...[
                      AvatarStack(
                        people: [
                          for (final p in others)
                            (name: p.name, imageUrl: p.avatarUrl),
                        ],
                      ),
                      const SizedBox(width: 8),
                    ],
                    _chevron,
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SectionLabel('Stores & aisles'),
          GroupedCard(
            children: [
              AppListRow(
                leading: SvgPicture.asset(
                  AppIcons.store,
                  width: 24,
                  height: 24,
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                ),
                title: 'Manage stores',
                subtitle: stores,
                trailing: _chevron,
                onTap: () => _go(ListSettingsAction.stores),
              ),
              AppListRow(
                leading: _icon(AppIcons.category),
                title: 'Manage aisles',
                subtitle: 'Add, remove or reorder aisles',
                trailing: _chevron,
                onTap: () => _go(ListSettingsAction.aisles),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SectionLabel('Items'),
          GroupedCard(
            children: [
              AppListRow(
                leading: _icon(AppIcons.repeat),
                title: 'Clear bought items after 7 days',
                trailing: AppToggle(
                  value: list.autoClearBought,
                  onChanged: (v) => repo.setAutoClearBought(list.id, v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppButton(
            label: 'Clear bought items',
            variant: AppButtonVariant.greenOutline,
            onPressed: list.bought.isEmpty
                ? null
                : () => _go(ListSettingsAction.clearBought),
          ),
          const SizedBox(height: 16),
          Center(
            child: AppDangerTextButton(
              label: 'Clear entire list',
              icon: SvgPicture.asset(
                AppIcons.trashSmall,
                width: 18,
                height: 18,
              ),
              onPressed: list.items.isEmpty
                  ? null
                  : () => _go(ListSettingsAction.clearAll),
            ),
          ),
        ],
      ),
    );
  }
}
