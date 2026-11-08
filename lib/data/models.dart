/// Domain models for Pear List. The in-memory [PearRepository] works with
/// these; the API layer should map responses into them.
library;

/// Store option meaning "no preference".
const String kAnyStore = 'Any store';

/// Group for items Smart Aisle couldn't place.
const String kOtherAisle = 'Other';

const List<String> kDefaultAisles = [
  'Produce',
  'Dairy & eggs',
  'Meat & seafood',
  'Bakery',
  'Pantry',
  'Frozen',
];

const List<String> kDefaultStores = ['Whole Foods', "Trader Joe's", 'Target'];

class Person {
  const Person({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.avatarUrl,
    this.isMe = false,
  });

  final String id;
  final String name;
  final String? email;

  /// 10 US digits.
  final String? phone;
  final String? avatarUrl;
  final bool isMe;

  String get firstName => name.trim().split(' ').first;
}

class Activity {
  const Activity({
    required this.id,
    required this.actor,
    required this.description,
    required this.at,
    this.kind = ListKind.shopping,
    this.listName,
  });

  final String id;
  final Person actor;

  /// Full sentence, e.g. "Sam added Olive oil".
  final String description;
  final DateTime at;

  /// Which tab's activity feed it belongs to.
  final ListKind kind;

  /// The list it happened in, e.g. "Our home".
  final String? listName;
}

/// Which bottom-nav tab a list lives under.
enum ListKind {
  shopping('Shopping'),
  wishlist('Wishlist'),
  places('Places');

  const ListKind(this.label);
  final String label;
}

/// How much a wish or place matters (Figma "Wish level" / "Interest
/// level"). Shopping items don't use it.
enum ItemLevel { high, medium, low }

class ShoppingItem {
  const ShoppingItem({
    required this.id,
    required this.name,
    required this.aisle,
    required this.addedBy,
    required this.addedAt,
    this.quantity = 1,
    this.store,
    this.urgent = false,
    this.editedAt,
    this.boughtAt,
    this.link,
    this.note,
    this.level = ItemLevel.medium,
    this.boughtSecretly = false,
  });

  final String id;
  final String name;
  final int quantity;

  /// Null means any store.
  final String? store;
  final String aisle;
  final bool urgent;
  final Person addedBy;
  final DateTime addedAt;
  final DateTime? editedAt;
  final DateTime? boughtAt;

  /// Wishes: product URL. Places: address or map link.
  final String? link;

  /// "More info" text.
  final String? note;
  final ItemLevel level;

  /// A wish bought as a surprise: listed under "Bought secretly" for the
  /// buyer and still open for everyone else.
  // TODO: the API must hide this from the person the wish is for.
  final bool boughtSecretly;

  bool get isBought => boughtAt != null;

  /// "2 x Apricots" when there's more than one.
  String get displayName => quantity > 1 ? '$quantity x $name' : name;

  ShoppingItem copyWith({
    String? name,
    int? quantity,
    String? Function()? store,
    String? aisle,
    bool? urgent,
    DateTime? editedAt,
    DateTime? Function()? boughtAt,
    String? Function()? link,
    String? Function()? note,
    ItemLevel? level,
    bool? boughtSecretly,
  }) {
    return ShoppingItem(
      id: id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      store: store != null ? store() : this.store,
      aisle: aisle ?? this.aisle,
      urgent: urgent ?? this.urgent,
      addedBy: addedBy,
      addedAt: addedAt,
      editedAt: editedAt ?? this.editedAt,
      boughtAt: boughtAt != null ? boughtAt() : this.boughtAt,
      link: link != null ? link() : this.link,
      note: note != null ? note() : this.note,
      level: level ?? this.level,
      boughtSecretly: boughtSecretly ?? this.boughtSecretly,
    );
  }
}

/// A list and its settings. Mutable on purpose: only [PearRepository]
/// changes it, and it notifies listeners when it does.
class ShoppingList {
  ShoppingList({
    required this.id,
    required this.name,
    required this.owner,
    this.kind = ListKind.shopping,
    List<Person>? members,
    List<ShoppingItem>? items,
    List<String>? aisles,
    List<String>? stores,
    this.isDefault = false,
    bool? shared,
    this.autoClearBought = false,
  })  : members = members ?? [owner],
        items = items ?? [],
        aisles = aisles ?? [...kDefaultAisles],
        stores = stores ?? [...kDefaultStores],
        shared = shared ?? (members != null && members.length > 1);

  final String id;
  String name;
  final ListKind kind;
  final Person owner;

  /// Everyone invited, including the owner.
  final List<Person> members;
  final List<ShoppingItem> items;
  final List<String> aisles;
  final List<String> stores;
  bool isDefault;

  /// Off makes the list private to the owner without removing anyone.
  bool shared;
  bool autoClearBought;

  /// Members whose access the owner switched off on the sharing screen.
  final Set<String> revokedIds = {};

  bool canEdit(Person person) =>
      person.id == owner.id || (shared && !revokedIds.contains(person.id));

  /// People who can currently see and edit the list.
  List<Person> get activeMembers => members.where(canEdit).toList();

  List<ShoppingItem> get toBuy => items.where((i) => !i.isBought).toList();
  List<ShoppingItem> get bought => items.where((i) => i.isBought).toList();

  /// Unbought items grouped by aisle, in the list's aisle order; aisles the
  /// list doesn't know about (e.g. "Other") come last.
  List<({String aisle, List<ShoppingItem> items})> groupedByAisle({
    String? store,
  }) {
    final visible =
        toBuy.where((i) => store == null || i.store == store).toList();
    final order = [...aisles];
    for (final item in visible) {
      if (!order.contains(item.aisle)) order.add(item.aisle);
    }
    return [
      for (final aisle in order)
        if (visible.any((i) => i.aisle == aisle))
          (aisle: aisle, items: visible.where((i) => i.aisle == aisle).toList()),
    ];
  }
}
