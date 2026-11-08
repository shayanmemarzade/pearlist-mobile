import 'package:flutter/widgets.dart';

import '../features/add_item/domain/new_item.dart';
import '../features/add_list/domain/new_list.dart';
import 'models.dart';
import 'smart_aisle.dart';

/// In-memory store for lists, items and activity.
///
/// Every screen reads from here (via [PearScope]) and calls these methods
/// to change things, so this is the one place to swap in the real API: keep
/// the method signatures, replace the bodies with requests, and notify when
/// the server responds.
class PearRepository extends ChangeNotifier {
  PearRepository({
    required this.me,
    this.partner,
    this.isPro = false,
    List<ShoppingList>? lists,
    List<Activity>? activities,
  })  : _lists = lists ?? [],
        _activities = activities ?? [];

  final Person me;

  /// The person the user shops with, if they have one.
  final Person? partner;

  /// Free-plan lists are private; Pro lets you share.
  bool isPro;

  final List<ShoppingList> _lists;
  final List<Activity> _activities;
  int _seq = 0;

  String _newId(String prefix) =>
      '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_seq++}';

  // ---------------------------------------------------------------- reads

  List<ShoppingList> get lists => List.unmodifiable(_lists);
  List<Activity> get activities => List.unmodifiable(_activities);

  bool get canShare => isPro && partner != null;

  ShoppingList? listById(String id) =>
      _lists.where((l) => l.id == id).firstOrNull;

  ShoppingList _list(String id) =>
      listById(id) ?? (throw ArgumentError('Unknown list $id'));

  /// The list shown in the big card on Home: the default shopping list, or
  /// the first one.
  ShoppingList? get homeList {
    final shopping = _lists.where((l) => l.kind == ListKind.shopping);
    return shopping.where((l) => l.isDefault).firstOrNull ??
        shopping.firstOrNull;
  }

  void _log(String description) {
    _activities.insert(
      0,
      Activity(
        id: _newId('activity'),
        actor: me,
        description: description,
        at: DateTime.now(),
      ),
    );
  }

  // ---------------------------------------------------------------- items

  ShoppingItem addItem(String listId, NewItem item) {
    final list = _list(listId);
    final added = ShoppingItem(
      id: _newId('item'),
      name: item.name,
      quantity: item.quantity,
      store: item.store == kAnyStore ? null : item.store,
      aisle: guessAisle(item.name, list.aisles),
      urgent: item.urgent,
      addedBy: me,
      addedAt: DateTime.now(),
    );
    list.items.insert(0, added);
    _log('You added ${item.name}');
    notifyListeners();
    return added;
  }

  void updateItem(String listId, ShoppingItem item) {
    final list = _list(listId);
    final index = list.items.indexWhere((i) => i.id == item.id);
    if (index < 0) return;
    final aisleChanged = list.items[index].name != item.name;
    list.items[index] = item.copyWith(
      editedAt: DateTime.now(),
      aisle: aisleChanged ? guessAisle(item.name, list.aisles) : null,
    );
    notifyListeners();
  }

  /// Removes an item and returns what [restoreItem] needs to undo it.
  ({int index, ShoppingItem item})? removeItem(String listId, String itemId) {
    final list = _list(listId);
    final index = list.items.indexWhere((i) => i.id == itemId);
    if (index < 0) return null;
    final removed = list.items.removeAt(index);
    _log('You removed ${removed.name}');
    notifyListeners();
    return (index: index, item: removed);
  }

  void restoreItem(String listId, int index, ShoppingItem item) {
    final list = _list(listId);
    list.items.insert(index.clamp(0, list.items.length), item);
    notifyListeners();
  }

  void setBought(String listId, String itemId, {required bool bought}) {
    final list = _list(listId);
    final index = list.items.indexWhere((i) => i.id == itemId);
    if (index < 0) return;
    final item = list.items[index];
    list.items[index] =
        item.copyWith(boughtAt: () => bought ? DateTime.now() : null);
    if (bought) _log('You checked off ${item.name}');
    notifyListeners();
  }

  /// Reorders unbought items inside one aisle. [newIndex] is the item's
  /// final position, as given by [ReorderableListView.onReorderItem].
  void moveItem(String listId, String aisle, int oldIndex, int newIndex) {
    final list = _list(listId);
    bool inGroup(ShoppingItem i) => !i.isBought && i.aisle == aisle;
    final group = list.items.where(inGroup).toList();
    group.insert(newIndex, group.removeAt(oldIndex));
    var k = 0;
    for (var i = 0; i < list.items.length; i++) {
      if (inGroup(list.items[i])) list.items[i] = group[k++];
    }
    notifyListeners();
  }

  int clearBought(String listId) {
    final list = _list(listId);
    final before = list.items.length;
    list.items.removeWhere((i) => i.isBought);
    notifyListeners();
    return before - list.items.length;
  }

  void clearAll(String listId) {
    _list(listId).items.clear();
    notifyListeners();
  }

  // ---------------------------------------------------------------- list settings

  void renameList(String listId, String name) {
    _list(listId).name = name;
    notifyListeners();
  }

  void setDefault(String listId, bool value) {
    for (final list in _lists) {
      list.isDefault = value && list.id == listId;
    }
    notifyListeners();
  }

  void setAutoClearBought(String listId, bool value) {
    // TODO: the server should clear bought items older than 7 days.
    _list(listId).autoClearBought = value;
    notifyListeners();
  }

  void setShared(String listId, bool value) {
    _list(listId).shared = value;
    notifyListeners();
  }

  void setMemberAccess(String listId, String personId, bool canEdit) {
    final list = _list(listId);
    canEdit ? list.revokedIds.remove(personId) : list.revokedIds.add(personId);
    notifyListeners();
  }

  // ---------------------------------------------------------------- aisles & stores

  List<String> _entries(ShoppingList list, bool aisles) =>
      aisles ? list.aisles : list.stores;

  /// Adds an aisle (or store); false if one with that name already exists.
  bool addEntry(String listId, String name, {required bool aisle}) {
    final entries = _entries(_list(listId), aisle);
    if (entries.any((e) => e.toLowerCase() == name.toLowerCase())) {
      return false;
    }
    entries.add(name);
    notifyListeners();
    return true;
  }

  /// Renames an aisle (or store) and moves its items along with it.
  /// False if another entry already has that name.
  bool renameEntry(String listId, int index, String name,
      {required bool aisle}) {
    final list = _list(listId);
    final entries = _entries(list, aisle);
    final old = entries[index];
    final taken = entries.indexed.any(
      (e) => e.$1 != index && e.$2.toLowerCase() == name.toLowerCase(),
    );
    if (taken) return false;
    entries[index] = name;
    for (var i = 0; i < list.items.length; i++) {
      final item = list.items[i];
      if (aisle && item.aisle == old) {
        list.items[i] = item.copyWith(aisle: name);
      } else if (!aisle && item.store == old) {
        list.items[i] = item.copyWith(store: () => name);
      }
    }
    notifyListeners();
    return true;
  }

  /// Removes an aisle (or store). Items keep their label until the user
  /// re-files them; an unknown aisle shows at the end of the list.
  String removeEntry(String listId, int index, {required bool aisle}) {
    final removed = _entries(_list(listId), aisle).removeAt(index);
    notifyListeners();
    return removed;
  }

  void restoreEntry(String listId, int index, String name,
      {required bool aisle}) {
    final entries = _entries(_list(listId), aisle);
    entries.insert(index.clamp(0, entries.length), name);
    notifyListeners();
  }

  /// [newIndex] is the entry's final position
  /// ([ReorderableListView.onReorderItem]).
  void reorderEntries(String listId, int oldIndex, int newIndex,
      {required bool aisle}) {
    final entries = _entries(_list(listId), aisle);
    entries.insert(newIndex, entries.removeAt(oldIndex));
    notifyListeners();
  }

  // ---------------------------------------------------------------- lists

  ShoppingList createList(NewList request) {
    final partner = this.partner;
    final share = request.shareWithPartner && canShare && partner != null;
    final list = ShoppingList(
      id: _newId('list'),
      name: request.name,
      kind: request.kind,
      owner: me,
      members: share ? [me, partner] : [me],
      shared: share,
      isDefault: homeList == null && request.kind == ListKind.shopping,
    );
    _lists.add(list);
    notifyListeners();
    return list;
  }
}

/// Makes the [PearRepository] available to the whole app and rebuilds
/// dependents when it changes.
class PearScope extends InheritedNotifier<PearRepository> {
  const PearScope({
    super.key,
    required PearRepository repository,
    required super.child,
  }) : super(notifier: repository);

  /// Reads the repository and rebuilds when it changes.
  static PearRepository of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PearScope>()!.notifier!;

  /// Reads the repository without listening (for callbacks).
  static PearRepository read(BuildContext context) =>
      context.getInheritedWidgetOfExactType<PearScope>()!.notifier!;
}
