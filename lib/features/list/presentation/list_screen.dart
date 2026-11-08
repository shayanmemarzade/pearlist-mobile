import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_bottom_bar.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_toast.dart';
import '../../../core/widgets/confirm_sheet.dart';
import '../../../data/models.dart';
import '../../../data/pear_repository.dart';
import '../../add_item/presentation/add_item_sheet.dart';
import '../../collection/presentation/collection_list_screen.dart';
import 'item_details_sheet.dart';
import 'list_settings_sheet.dart';
import 'manage_entries_screen.dart';
import 'sharing_screen.dart';
import 'widgets/aisle_section.dart';
import 'widgets/bought_section.dart';
import 'widgets/list_empty_state.dart';
import 'widgets/list_top_bar.dart';
import 'widgets/store_filter_tabs.dart';

/// A shopping list (Figma section "Shopping List page", 2200:6545): items
/// grouped by aisle, filterable by store, with a collapsible Bought section.
class ListScreen extends StatefulWidget {
  const ListScreen({
    super.key,
    required this.listId,
    this.justCreated = false,
  });

  final String listId;

  /// Shows "Your list is ready" instead of "Nothing on the list yet".
  final bool justCreated;

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  String? _store;
  bool _showBought = false;

  PearRepository get _repo => PearScope.read(context);

  double get _toastOffset => AppBottomBar.heightOf(context) + 8;

  Future<void> _addItem(ShoppingList list) async {
    final item = await showAddItemSheet(
      context,
      listName: list.name,
      stores: [...list.stores, kAnyStore],
    );
    if (item == null || !mounted) return;
    _repo.addItem(list.id, item);
  }

  Future<void> _openItem(ShoppingList list, ShoppingItem item) async {
    final repo = _repo;
    final editable = item.addedBy.isMe;
    final draft = ItemDraft.from(item);
    final action = await showItemDetailsSheet(
      context,
      item: item,
      list: list,
      draft: draft,
      editable: editable,
    );
    if (!mounted) return;

    if (action == ItemSheetAction.remove) {
      final removed = repo.removeItem(list.id, item.id);
      if (removed == null) return;
      showAppToast(
        context,
        message: 'The ${item.name} item has been removed.',
        bottomOffset: _toastOffset,
        onUndo: () => repo.restoreItem(list.id, removed.index, removed.item),
      );
      return;
    }
    if (editable && draft.differsFrom(item)) {
      repo.updateItem(list.id, draft.applyTo(item));
    }
    if (action == ItemSheetAction.toggleBought) {
      repo.setBought(list.id, item.id, bought: !item.isBought);
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

    final navigator = Navigator.of(context);
    final partner = list.activeMembers.where((p) => !p.isMe).firstOrNull;
    final forWhom = partner == null ? 'you' : 'you and ${partner.firstName}';

    switch (action) {
      case ListSettingsAction.sharing:
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => SharingScreen(listId: list.id),
          ),
        );
      case ListSettingsAction.stores:
      case ListSettingsAction.aisles:
        navigator.push(
          MaterialPageRoute<void>(
            builder: (_) => ManageEntriesScreen(
              listId: list.id,
              kind: action == ListSettingsAction.aisles
                  ? ManagedEntries.aisles
                  : ManagedEntries.stores,
            ),
          ),
        );
      case ListSettingsAction.clearBought:
        final confirmed = await showConfirmSheet(
          context,
          title: 'Clear bought items',
          message: 'They’ll be removed from ${list.name} for $forWhom. '
              'Items you buy often stay in your Usuals.',
          confirmLabel: 'Clear items',
        );
        if (confirmed) repo.clearBought(list.id);
      case ListSettingsAction.clearAll:
        final count = list.items.length;
        final clearAll = await showConfirmSheet(
          context,
          title: 'Clear entire list',
          message: 'All $count ${count == 1 ? 'item' : 'items'} will be '
              'removed for $forWhom, including ones not bought yet. The '
              'list itself stays.',
          confirmLabel: 'Clear List',
        );
        if (clearAll) repo.clearAll(list.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = PearScope.of(context);
    final list = repo.listById(widget.listId);
    if (list == null) {
      return const Scaffold(backgroundColor: AppColors.background);
    }
    // Wish and place lists have their own page.
    if (list.kind != ListKind.shopping) {
      return CollectionListScreen(
        listId: list.id,
        justCreated: widget.justCreated,
      );
    }

    final isEmpty = list.items.isEmpty;

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
                onMenu: () => _openSettings(list),
              ),
            ),
            Expanded(
              child: isEmpty
                  ? ListEmptyState(
                      justCreated: widget.justCreated,
                      onAdd: () => _addItem(list),
                    )
                  : _buildItems(list),
            ),
            if (!isEmpty)
              AppBottomBar(
                keyboardOpen: false,
                child: AppButton(
                  label: 'Add item',
                  variant: AppButtonVariant.greenOutline,
                  onPressed: () => _addItem(list),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildItems(ShoppingList list) {
    final repo = _repo;
    // A store filter that was renamed or removed falls back to "All".
    final store = list.stores.contains(_store) ? _store : null;
    final groups = list.groupedByAisle(store: store);
    final bought = list.bought;
    final toBuy = list.toBuy;

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        if (list.stores.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: StoreFilterTabs(
              stores: list.stores,
              counts: {
                for (final s in list.stores)
                  s: toBuy.where((i) => i.store == s).length,
              },
              selected: store,
              onSelected: (s) => setState(() => _store = s),
            ),
          ),
        const SizedBox(height: 16),
        for (final group in groups) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AisleSection(
              aisle: group.aisle,
              items: group.items,
              // Dragging only makes sense when the whole aisle is visible.
              reorderable: store == null,
              onReorderItem: (from, to) =>
                  repo.moveItem(list.id, group.aisle, from, to),
              onCheck: (item) => repo.setBought(list.id, item.id, bought: true),
              onOpen: (item) => _openItem(list, item),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (bought.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: BoughtSection(
              items: bought,
              expanded: _showBought,
              onToggleExpanded: () =>
                  setState(() => _showBought = !_showBought),
              onUncheck: (item) =>
                  repo.setBought(list.id, item.id, bought: false),
              onOpen: (item) => _openItem(list, item),
            ),
          ),
      ],
    );
  }
}
