import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_bottom_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/snap_away.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../data/models.dart';
import '../../../data/pear_repository.dart';
import '../../list/presentation/list_settings_sheet.dart';
import '../../list/presentation/sharing_screen.dart';
import '../../list/presentation/widgets/bought_section.dart';
import '../../list/presentation/widgets/list_empty_state.dart';
import '../../list/presentation/widgets/list_top_bar.dart';
import '../domain/kind_copy.dart';
import 'add_collection_item_sheet.dart';
import 'collection_item_details_sheet.dart';
import 'widgets/collection_item_row.dart';

/// A wish list (Figma "Wish List" → "List page", 2272:9278) or place list
/// ("Places List" → "Place List page", 2972:22360): sortable entries with a
/// level badge, and collapsible Bought / Bought secretly / Visited sections.
class CollectionListScreen extends StatefulWidget {
  const CollectionListScreen({
    super.key,
    required this.listId,
    this.justCreated = false,
  });

  final String listId;
  final bool justCreated;

  @override
  State<CollectionListScreen> createState() => _CollectionListScreenState();
}

class _CollectionListScreenState extends State<CollectionListScreen> {
  CollectionSort _sort = CollectionSort.dateAdded;
  bool _showBought = false;
  bool _showSecret = false;

  /// Entries crumbling away after being checked off, with whether the wish
  /// was bought secretly.
  final Map<String, bool> _snapping = {};

  PearRepository get _repo => PearScope.read(context);

  double get _toastOffset => AppBottomBar.heightOf(context) + 8;

  String? _partnerName(ShoppingList list) =>
      list.activeMembers.where((p) => !p.isMe).firstOrNull?.firstName;

  Future<void> _add(ShoppingList list) async {
    final entry = await showAddCollectionItemSheet(
      context,
      kind: list.kind,
      listName: list.name,
    );
    if (entry == null || !mounted) return;
    _repo.addCollectionItem(list.id, entry);
  }

  /// Checking a wish asks whether it's a surprise; places are just visited.
  Future<void> _markDone(ShoppingList list, ShoppingItem item) async {
    if (list.kind != ListKind.wishlist) {
      setState(() => _snapping[item.id] = false);
      return;
    }
    final secretly = await showMarkBoughtSheet(context);
    if (secretly == null || !mounted) return;
    setState(() => _snapping[item.id] = secretly);
  }

  /// End of the crumble: now it really moves to Bought / Visited.
  void _snapped(ShoppingList list, ShoppingItem item) {
    final secretly = _snapping[item.id] ?? false;
    setState(() => _snapping.remove(item.id));
    _repo.setBought(list.id, item.id, bought: true, secretly: secretly);
  }

  void _remove(ShoppingList list, ShoppingItem item) {
    final repo = _repo;
    final removed = repo.removeItem(list.id, item.id);
    if (removed == null) return;
    showAppToast(
      context,
      message: 'The ${item.name} ${list.kind.itemNoun} has been removed.',
      bottomOffset: _toastOffset,
      onUndo: () => repo.restoreItem(list.id, removed.index, removed.item),
    );
  }

  Future<void> _open(ShoppingList list, ShoppingItem item) async {
    final repo = _repo;
    final editable = item.addedBy.isMe;
    final partner = _partnerName(list);
    final draft = CollectionItemDraft.from(item);
    final action = await showCollectionItemDetailsSheet(
      context,
      item: item,
      list: list,
      draft: draft,
      editable: editable,
      partnerName: partner,
    );
    if (!mounted) return;

    if (action == CollectionSheetAction.remove) {
      _remove(list, item);
      return;
    }
    if (editable && draft.differsFrom(item)) {
      repo.updateItem(list.id, draft.applyTo(item));
    }
    switch (action) {
      case CollectionSheetAction.toggleDone:
        if (item.isBought) {
          repo.setBought(list.id, item.id, bought: false);
        } else {
          await _markDone(list, item);
        }
      case CollectionSheetAction.nudge:
        repo.nudge(list.id, item.id);
        showAppToast(
          context,
          message: 'We let $partner know about ${item.name}.',
          bottomOffset: _toastOffset,
        );
      case CollectionSheetAction.remove:
      case null:
        break;
    }
  }

  Future<void> _openSettings(ShoppingList list) async {
    final repo = _repo;
    final draft = ListSettingsDraft(list.name);
    final action =
        await showListSettingsSheet(context, listId: list.id, draft: draft);

    final name = draft.name.trim();
    if (name.isNotEmpty && name != list.name) repo.renameList(list.id, name);
    if (!mounted || action == null) return;

    final partner = _partnerName(list);
    final forWhom = partner == null ? 'you' : 'you and $partner';
    final places = list.kind == ListKind.places;

    switch (action) {
      case ListSettingsAction.sharing:
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => SharingScreen(listId: list.id),
          ),
        );
      case ListSettingsAction.stores:
      case ListSettingsAction.aisles:
        break; // Shopping lists only.
      case ListSettingsAction.clearBought:
        final done = list.bought;
        final count = done.length;
        final names = _joinNames(done.map((i) => i.name).toList());
        final confirmed = await showConfirmSheet(
          context,
          title: places
              ? 'Clear $count visited ${count == 1 ? 'place' : 'places'}?'
              : 'Clear bought items',
          message: places
              ? '$names will be removed from ${list.name} for $forWhom, '
                  'with their ratings.'
              : 'They’ll be removed from ${list.name} for $forWhom.',
          confirmLabel: 'Clear items',
        );
        if (confirmed) repo.clearBought(list.id);
      case ListSettingsAction.clearAll:
        final count = list.items.length;
        final noun = places
            ? (count == 1 ? 'place' : 'places')
            : (count == 1 ? 'item' : 'items');
        final clearAll = await showConfirmSheet(
          context,
          title: 'Clear entire list',
          message: places
              ? 'All $count $noun, notes and ratings will be deleted for '
                  '$forWhom. This can’t be undone.'
              : 'All $count $noun will be removed for $forWhom, including '
                  'ones not bought yet. The list itself stays.',
          confirmLabel: 'Clear List',
        );
        if (clearAll) repo.clearAll(list.id);
    }
  }

  /// "Nopa, Sightglass and Café Frieda".
  static String _joinNames(List<String> names) {
    if (names.isEmpty) return 'They';
    if (names.length == 1) return names.first;
    return '${names.sublist(0, names.length - 1).join(', ')} and '
        '${names.last}';
  }

  @override
  Widget build(BuildContext context) {
    final list = PearScope.of(context).listById(widget.listId);
    if (list == null) {
      return const Scaffold(backgroundColor: AppColors.background);
    }
    final kind = list.kind;
    final isEmpty = list.items.isEmpty;
    final places = kind == ListKind.places;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            SafeArea(
              bottom: false,
              child: ListTopBar(
                title: list.name,
                backLabel: kind.backLabel,
                onMenu: () => _openSettings(list),
              ),
            ),
            Expanded(
              child: isEmpty
                  ? ListEmptyState(
                      justCreated: widget.justCreated,
                      title: places
                          ? 'No places saved yet'
                          : 'Save things you’d love to have',
                      message: places
                          ? 'Tap + to save your first place.'
                          : 'Tap below to add your first wish.',
                      buttonLabel: 'Add your first ${kind.itemNoun}',
                      onAdd: () => _add(list),
                    )
                  : _buildEntries(list),
            ),
            if (!isEmpty)
              AppBottomBar(
                keyboardOpen: false,
                child: AppButton(
                  label: kind.addLabel,
                  variant: AppButtonVariant.greenOutline,
                  onPressed: () => _add(list),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntries(ShoppingList list) {
    final repo = _repo;
    final kind = list.kind;
    final open = sortCollection(list.toBuy, _sort);
    final done = list.bought;
    final boughtPublic = done.where((i) => !i.boughtSecretly).toList();
    final boughtSecret = done.where((i) => i.boughtSecretly).toList();

    Widget row(ShoppingItem item) => CollectionItemRow(
          item: item,
          kind: kind,
          onCheck: (checked) {
            if (checked) {
              _markDone(list, item);
            } else {
              repo.setBought(list.id, item.id, bought: false);
            }
          },
          onOpen: () => _open(list, item),
        );

    Widget section(
      String title,
      List<ShoppingItem> items, {
      required bool expanded,
      required VoidCallback onToggle,
    }) =>
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: BoughtSection(
            title: title,
            items: items,
            expanded: expanded,
            onToggleExpanded: onToggle,
            onUncheck: (item) =>
                repo.setBought(list.id, item.id, bought: false),
            onOpen: (item) => _open(list, item),
            itemBuilder: row,
          ),
        );

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        CollectionSortTabs(
          kind: kind,
          value: _sort,
          onChanged: (sort) => setState(() => _sort = sort),
        ),
        const SizedBox(height: 16),
        if (open.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(kind.itemsTitle, style: AppTextStyles.body1Bold),
                ),
                Text(
                  open.length == 1 ? '1 Item' : '${open.length} Items',
                  style: AppTextStyles.smallRegular,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AppCard(
              child: Column(
                children: [
                  for (var i = 0; i < open.length; i++)
                    SnapAway(
                      key: ValueKey(open[i].id),
                      snapping: _snapping.containsKey(open[i].id),
                      onSnapped: () => _snapped(list, open[i]),
                      above: i == 0
                          ? null
                          : RowDivider(
                              // The first row has no divider above; the
                              // next row's one closes with it instead.
                              closing: i == 1 &&
                                  _snapping.containsKey(open[0].id),
                            ),
                      child: _snapping.containsKey(open[i].id)
                          // Ticked and struck through while it crumbles.
                          ? IgnorePointer(
                              child: row(
                                open[i].copyWith(
                                  boughtAt: () => DateTime.now(),
                                ),
                              ),
                            )
                          : row(open[i]),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (boughtPublic.isNotEmpty)
          section(
            kind.doneLabel,
            boughtPublic,
            expanded: _showBought,
            onToggle: () => setState(() => _showBought = !_showBought),
          ),
        if (boughtSecret.isNotEmpty)
          section(
            'Bought secretly',
            boughtSecret,
            expanded: _showSecret,
            onToggle: () => setState(() => _showSecret = !_showSecret),
          ),
      ],
    );
  }
}
