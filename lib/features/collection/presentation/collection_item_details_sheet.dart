import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_text_area.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/read_only_field.dart';
import '../../../data/models.dart';
import '../../list/presentation/item_details_sheet.dart' show ItemAddedBy;
import '../domain/kind_copy.dart';
import 'widgets/link_widgets.dart';

enum CollectionSheetAction { remove, toggleDone, nudge }

/// Edits made in the details sheet; saved by the caller when it closes.
class CollectionItemDraft {
  CollectionItemDraft.from(ShoppingItem item)
      : name = item.name,
        link = item.link ?? '',
        note = item.note ?? '';

  String name;
  String link;
  String note;

  String? _clean(String value) =>
      value.trim().isEmpty ? null : value.trim();

  bool differsFrom(ShoppingItem item) =>
      (name.trim().isNotEmpty && name.trim() != item.name) ||
      _clean(link) != item.link ||
      _clean(note) != item.note;

  ShoppingItem applyTo(ShoppingItem item) => item.copyWith(
        name: name.trim().isEmpty ? item.name : name.trim(),
        link: () => _clean(link),
        note: () => _clean(note),
      );
}

/// "Wish details" / "Place details" (Figma 2364:18444, partner view
/// 3106:38061). Your own entries are editable and removable.
Future<CollectionSheetAction?> showCollectionItemDetailsSheet(
  BuildContext context, {
  required ShoppingItem item,
  required ShoppingList list,
  required CollectionItemDraft draft,
  required bool editable,
  required String? partnerName,
}) {
  return showAppSheet<CollectionSheetAction>(
    context,
    builder: (context) => _DetailsSheet(
      item: item,
      list: list,
      draft: draft,
      editable: editable,
      partnerName: partnerName,
    ),
  );
}

class _DetailsSheet extends StatefulWidget {
  const _DetailsSheet({
    required this.item,
    required this.list,
    required this.draft,
    required this.editable,
    required this.partnerName,
  });

  final ShoppingItem item;
  final ShoppingList list;
  final CollectionItemDraft draft;
  final bool editable;
  final String? partnerName;

  @override
  State<_DetailsSheet> createState() => _DetailsSheetState();
}

class _DetailsSheetState extends State<_DetailsSheet> {
  late final _name = TextEditingController(text: widget.draft.name);
  late final _link = TextEditingController(text: widget.draft.link);
  late final _note = TextEditingController(text: widget.draft.note);

  @override
  void dispose() {
    _name.dispose();
    _link.dispose();
    _note.dispose();
    super.dispose();
  }

  void _close(CollectionSheetAction action) =>
      Navigator.of(context).pop(action);

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final kind = widget.list.kind;
    final draft = widget.draft;
    final editable = widget.editable;
    final places = kind == ListKind.places;
    final link = item.link;
    final note = item.note;
    final partnerName = widget.partnerName;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    final doneButton = AppButton(
      label: item.isBought
          ? (places ? 'Not visited yet' : 'Move back to list')
          : kind.markDoneLabel,
      variant: AppButtonVariant.green,
      onPressed: () => _close(CollectionSheetAction.toggleDone),
    );

    return AppSheetFrame(
      bottomBar: AppBottomBar(
        keyboardOpen: keyboardOpen,
        child: partnerName == null || item.isBought
            ? doneButton
            : Row(
                children: [
                  Expanded(
                    child: AppButton(
                      label: 'Nudge $partnerName',
                      variant: AppButtonVariant.greenOutline,
                      icon: SvgPicture.asset(
                        AppIcons.bell,
                        width: 18,
                        height: 18,
                        colorFilter: const ColorFilter.mode(
                          AppColors.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      onPressed: () => _close(CollectionSheetAction.nudge),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: doneButton),
                ],
              ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetHeader(
            title: kind.detailsTitle,
            subtitle: widget.list.name,
            leading: editable
                ? Tooltip(
                    message: 'Remove ${kind.itemNoun}',
                    child: InkResponse(
                      onTap: () => _close(CollectionSheetAction.remove),
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
              label: places ? 'Place name' : 'Item name',
              hint: places ? 'Place name' : 'Item name',
              controller: _name,
              onChanged: (v) => draft.name = v,
              textInputAction: TextInputAction.done,
            )
          else
            ReadOnlyField(
              label: places ? 'Place name' : 'Item name',
              value: item.name,
            ),
          const SizedBox(height: 16),
          if (editable && link == null)
            LinkField(
              label: places ? 'Address' : 'Link',
              hint: places ? 'Address Link' : 'Wish’s Link',
              controller: _link,
              onChanged: (v) => draft.link = v,
              keyboardType:
                  places ? TextInputType.streetAddress : TextInputType.url,
            )
          else if (link != null)
            LinkBox(label: places ? 'Address' : 'Link', link: link),
          if (editable || link != null) const SizedBox(height: 16),
          if (editable)
            AppTextArea(
              label: 'More Info',
              hint: places
                  ? 'Book ahead, ask for the patio…'
                  : 'Write some details',
              controller: _note,
              minLines: 2,
              onChanged: (v) => draft.note = v,
            )
          else if (note != null)
            ReadOnlyField(label: 'More Info', value: note),
          if (editable || note != null) const SizedBox(height: 16),
          ItemAddedBy(item: item),
        ],
      ),
    );
  }
}

/// Asks how a wish was bought (Figma "Mark as bought", 3137:41843).
/// Resolves to true for "Keep it as surprise", false for "publicly" and
/// null when dismissed.
Future<bool?> showMarkBoughtSheet(BuildContext context) {
  return showAppSheet<bool>(
    context,
    builder: (context) => AppSheetFrame(
      bottomBar: AppBottomBar(
        keyboardOpen: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppButton(
              label: 'Keep it as surprise',
              icon: SvgPicture.asset(AppIcons.giftWhite, width: 18, height: 18),
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Mark as bought publicly',
              variant: AppButtonVariant.outline,
              icon: SvgPicture.asset(
                AppIcons.checkCircle,
                width: 18,
                height: 18,
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetHeader(title: 'Mark as bought'),
          SizedBox(height: 32),
          _SheetMessage(
            'Has this item been purchased? Choose whether to keep it a '
            'surprise.',
          ),
        ],
      ),
    ),
  );
}

class _SheetMessage extends StatelessWidget {
  const _SheetMessage(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.body1Regular
            .copyWith(color: AppColors.typographyTertiary),
      ),
    );
  }
}
