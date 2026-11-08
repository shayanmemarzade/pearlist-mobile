import 'package:flutter/material.dart';

import '../../../core/widgets/app_bottom_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/app_text_area.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../data/models.dart';
import '../domain/kind_copy.dart';
import '../domain/new_collection_item.dart';
import 'widgets/level_widgets.dart';
import 'widgets/link_widgets.dart';

/// "Add wish" (Figma 2290:18623) / "Add place" (2362:17947) sheet.
/// Resolves to the new entry, or null when closed.
Future<NewCollectionItem?> showAddCollectionItemSheet(
  BuildContext context, {
  required ListKind kind,
  required String listName,
}) {
  return showAppSheet<NewCollectionItem>(
    context,
    builder: (context) => _AddSheet(kind: kind, listName: listName),
  );
}

class _AddSheet extends StatefulWidget {
  const _AddSheet({required this.kind, required this.listName});

  final ListKind kind;
  final String listName;

  @override
  State<_AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends State<_AddSheet> {
  final _name = TextEditingController();
  final _link = TextEditingController();
  final _note = TextEditingController();
  ItemLevel _level = ItemLevel.high;

  bool get _places => widget.kind == ListKind.places;
  bool get _canSubmit => _name.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    _link.dispose();
    _note.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_canSubmit) return;
    Navigator.of(context).pop(
      NewCollectionItem(
        name: _name.text.trim(),
        link: _link.text,
        note: _note.text,
        level: _level,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final kind = widget.kind;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return AppSheetFrame(
      bottomBar: AppBottomBar(
        keyboardOpen: keyboardOpen,
        child: AppButton(
          label: kind.addLabel,
          onPressed: _canSubmit ? _submit : null,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSheetHeader(
            title: kind.addLabel,
            subtitle: 'To ${widget.listName}',
          ),
          const SizedBox(height: 32),
          AppTextField(
            label: _places ? 'Place name' : 'Item name',
            hint: _places ? 'Osteria Lucia' : 'Linen duvet cover',
            controller: _name,
            autofocus: true,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          LinkField(
            label: _places ? 'Address' : 'Link',
            labelHint: _places ? null : '(recommended)',
            hint: _places ? 'Address Link' : 'Wish’s Link',
            controller: _link,
            keyboardType:
                _places ? TextInputType.streetAddress : TextInputType.url,
          ),
          const SizedBox(height: 16),
          AppTextArea(
            label: 'More info',
            hint: _places
                ? 'Book ahead, ask for the patio…'
                : 'Write some details',
            controller: _note,
          ),
          const SizedBox(height: 16),
          LevelSelector(
            kind: kind,
            value: _level,
            onChanged: (level) => setState(() => _level = level),
          ),
        ],
      ),
    );
  }
}
