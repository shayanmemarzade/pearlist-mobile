import 'package:flutter/widgets.dart';

import '../features/add_item/domain/new_item.dart';
import '../features/add_list/domain/new_list.dart';
import '../features/collection/domain/new_collection_item.dart';
import 'invites.dart';
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
    // Callers pass `me:`; the private field is set directly.
    required this._me,
    this.partner,
    this.isPro = false,
    List<ShoppingList>? lists,
    List<Activity>? activities,
    List<Invite>? invites,
  })  : _lists = lists ?? [],
        _activities = activities ?? [],
        _invites = invites ?? [];

  Person _me;

  /// The signed-in user.
  Person get me => _me;

  /// The person the user shops with, if they have one.
  final Person? partner;

  /// Free-plan lists are private; Pro lets you share.
  bool isPro;

  final List<ShoppingList> _lists;
  final List<Activity> _activities;
  final List<Invite> _invites;
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
  ShoppingList? get homeList => homeListFor(ListKind.shopping);

  /// The default (or first) list of a tab.
  ShoppingList? homeListFor(ListKind kind) {
    final ofKind = _lists.where((l) => l.kind == kind);
    return ofKind.where((l) => l.isDefault).firstOrNull ?? ofKind.firstOrNull;
  }

  /// Lists of one tab, in creation order.
  List<ShoppingList> listsOf(ListKind kind) =>
      _lists.where((l) => l.kind == kind).toList();

  /// Activity for one tab's feed.
  List<Activity> activitiesFor(ListKind kind) =>
      _activities.where((a) => a.kind == kind).toList();

  void _log(String description, {ShoppingList? list}) {
    _activities.insert(
      0,
      Activity(
        id: _newId('activity'),
        actor: me,
        description: description,
        at: DateTime.now(),
        kind: list?.kind ?? ListKind.shopping,
        listName: list?.name,
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
    _log('You added ${item.name}', list: list);
    notifyListeners();
    return added;
  }

  void updateItem(String listId, ShoppingItem item) {
    final list = _list(listId);
    final index = list.items.indexWhere((i) => i.id == item.id);
    if (index < 0) return;
    final aisleChanged = list.kind == ListKind.shopping &&
        list.items[index].name != item.name;
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
    _log('You removed ${removed.name}', list: list);
    notifyListeners();
    return (index: index, item: removed);
  }

  void restoreItem(String listId, int index, ShoppingItem item) {
    final list = _list(listId);
    list.items.insert(index.clamp(0, list.items.length), item);
    notifyListeners();
  }

  /// Checks an item off (bought, or visited for places). [secretly] keeps a
  /// wish a surprise: no activity is logged for it.
  void setBought(
    String listId,
    String itemId, {
    required bool bought,
    bool secretly = false,
  }) {
    final list = _list(listId);
    final index = list.items.indexWhere((i) => i.id == itemId);
    if (index < 0) return;
    final item = list.items[index];
    list.items[index] = item.copyWith(
      boughtAt: () => bought ? DateTime.now() : null,
      boughtSecretly: bought && secretly,
    );
    if (bought && !secretly) {
      final verb = switch (list.kind) {
        ListKind.shopping => 'checked off',
        ListKind.wishlist => 'bought',
        ListKind.places => 'visited',
      };
      _log('You $verb ${item.name}', list: list);
    }
    notifyListeners();
  }

  /// Adds a wish or a place.
  ShoppingItem addCollectionItem(String listId, NewCollectionItem item) {
    final list = _list(listId);
    final link = item.link?.trim();
    final note = item.note?.trim();
    final added = ShoppingItem(
      id: _newId('item'),
      name: item.name,
      aisle: kOtherAisle,
      addedBy: me,
      addedAt: DateTime.now(),
      link: link == null || link.isEmpty ? null : link,
      note: note == null || note.isEmpty ? null : note,
      level: item.level,
    );
    list.items.insert(0, added);
    _log(
      list.kind == ListKind.wishlist
          ? 'You saved ${item.name}'
          : 'You added ${item.name}',
      list: list,
    );
    notifyListeners();
    return added;
  }

  /// Reminds the other members about an item.
  // TODO: send a push notification through the API.
  void nudge(String listId, String itemId) {}

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

  /// One default list per tab.
  void setDefault(String listId, bool value) {
    final kind = _list(listId).kind;
    for (final list in _lists.where((l) => l.kind == kind)) {
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
      isDefault: homeListFor(request.kind) == null,
    );
    _lists.add(list);
    notifyListeners();
    return list;
  }

  // ---------------------------------------------------------------- account

  /// Saves what the user entered while signing up. Null leaves a field as
  /// it is; an empty [email] clears it.
  void updateProfile({String? name, String? email, String? avatarUrl}) {
    final current = _me;
    _me = Person(
      id: current.id,
      name: name ?? current.name,
      email: email == null ? current.email : (email.isEmpty ? null : email),
      avatarUrl: avatarUrl ?? current.avatarUrl,
      isMe: true,
    );
    notifyListeners();
  }

  /// Favourite stores picked during sign-up become the store filters of the
  /// user's own shopping lists.
  void setFavoriteStores(List<String> stores) {
    if (stores.isEmpty) return;
    for (final list in _lists) {
      if (list.kind != ListKind.shopping || list.owner.id != _me.id) continue;
      list.stores
        ..clear()
        ..addAll(stores);
    }
    notifyListeners();
  }

  /// Starts the Pro subscription; invites waiting for it go out now.
  // TODO: replace with the store purchase / receipt check.
  void upgradeToPro() {
    isPro = true;
    for (var i = 0; i < _invites.length; i++) {
      if (_invites[i].status == InviteStatus.awaitingUpgrade) {
        _invites[i] = _invites[i].copyWith(status: InviteStatus.sent);
      }
    }
    notifyListeners();
  }

  /// The subscription ended. Sent invites stay valid.
  void cancelPro() {
    isPro = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------- invites

  List<Invite> get invites => List.unmodifiable(_invites);

  /// Invites that count towards the Pro limit (not cancelled).
  int get invitedCount => _invites.length;

  /// How many more people can be invited on Pro.
  int get invitesLeft =>
      (kProInviteLimit - invitedCount).clamp(0, kProInviteLimit);

  /// Invites [targets] to the lists of the given kinds. On the free plan the
  /// invites are saved and go out after upgrading ([upgradeToPro]).
  List<Invite> sendInvites(List<InviteTarget> targets, Set<ListKind> lists) {
    final status = isPro ? InviteStatus.sent : InviteStatus.awaitingUpgrade;
    final created = [
      for (final t in targets.take(invitesLeft))
        Invite(
          id: _newId('invite'),
          name: t.name,
          address: t.address,
          lists: lists,
          status: status,
          sentAt: DateTime.now(),
        ),
    ];
    _invites.addAll(created);
    if (created.isNotEmpty && isPro) {
      final who = created.length == 1
          ? created.first.displayName
          : '${created.length} people';
      _log('You invited $who');
    }
    notifyListeners();
    return created;
  }

  /// Joins the lists another user shared ([IncomingInvite]).
  // TODO: call the API; the server adds the user as a member.
  void acceptInvite(IncomingInvite invite) {
    for (final kind in invite.lists) {
      _lists.add(
        ShoppingList(
          id: _newId('list'),
          name: switch (kind) {
            ListKind.shopping => '${invite.from.firstName}\u2019s shopping list',
            ListKind.wishlist => '${invite.from.firstName}\u2019s wish list',
            ListKind.places => '${invite.from.firstName}\u2019s places',
          },
          kind: kind,
          owner: invite.from,
          members: [invite.from, _me],
          shared: true,
        ),
      );
    }
    notifyListeners();
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
