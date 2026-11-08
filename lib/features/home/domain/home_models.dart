/// View models for the Home / Shopping page, built from [PearRepository].
library;

import '../../../data/models.dart';
import '../../../data/pear_repository.dart';

export '../../../data/models.dart' show Activity, ListKind, Person;

/// The list shown in the big card at the top of Home.
class ActiveList {
  const ActiveList({
    required this.id,
    required this.name,
    required this.members,
    this.kind = ListKind.shopping,
    this.previewItems = const [],
    this.totalItems = 0,
    this.boughtCount = 0,
  });

  final String id;
  final String name;
  final ListKind kind;

  /// Wishes bought / places visited ("5 wishes · 2 bought").
  final int boughtCount;

  /// Everyone who can see the list, including the current user.
  final List<Person> members;

  /// First few item names still to buy, e.g. "Bananas, Oat milk, …".
  final List<String> previewItems;

  /// Items still to buy.
  final int totalItems;

  /// Max names shown in the card before "+N more".
  static const int previewLimit = 3;

  bool get isEmpty => totalItems == 0;
  int get moreCount =>
      (totalItems - previewItems.length).clamp(0, totalItems).toInt();
}

enum ListIcon { list, lock, place }

/// A card in the "Other lists" row.
class ListSummary {
  const ListSummary({
    required this.id,
    required this.name,
    required this.itemCount,
    required this.members,
    this.icon = ListIcon.list,
    this.kind = ListKind.shopping,
  });

  final String id;
  final String name;
  final int itemCount;
  final ListKind kind;
  final List<Person> members;
  final ListIcon icon;

  bool get isShared => members.length > 1;
}

/// A chip under "Start a list" (shown when the user has no other lists).
class ListTemplate {
  const ListTemplate({required this.name, this.icon = ListIcon.list});

  final String name;
  final ListIcon icon;
}

const List<ListTemplate> kListTemplates = [
  ListTemplate(name: 'Grocery list'),
  ListTemplate(name: 'Party list'),
  ListTemplate(name: 'Personal list', icon: ListIcon.lock),
];

const List<ListTemplate> kWishlistTemplates = [
  ListTemplate(name: 'Birthday ideas'),
  ListTemplate(name: 'For the home'),
  ListTemplate(name: 'Travel', icon: ListIcon.lock),
];

const List<ListTemplate> kPlacesTemplates = [
  ListTemplate(name: 'Date nights', icon: ListIcon.place),
  ListTemplate(name: 'Weekend trips', icon: ListIcon.place),
  ListTemplate(name: 'Coffee spots', icon: ListIcon.lock),
];

List<ListTemplate> templatesFor(ListKind kind) => switch (kind) {
      ListKind.shopping => kListTemplates,
      ListKind.wishlist => kWishlistTemplates,
      ListKind.places => kPlacesTemplates,
    };

class HomeData {
  const HomeData({
    required this.activeList,
    this.otherLists = const [],
    this.templates = const [],
    this.activities = const [],
    this.stores = const [],
  });

  /// Builds a tab's page (Shopping, Wishes or Places) from the repository.
  /// Returns null when the user has no list of that kind yet.
  static HomeData? fromRepository(
    PearRepository repo, {
    ListKind kind = ListKind.shopping,
  }) {
    final home = repo.homeListFor(kind);
    if (home == null) return null;

    final toBuy = home.toBuy;
    final others = repo
        .listsOf(kind)
        .where((l) => l.id != home.id)
        .map(
          (l) => ListSummary(
            id: l.id,
            name: l.name,
            itemCount: l.toBuy.length,
            members: l.activeMembers,
            kind: kind,
            // A lock only means something when sharing is possible.
            icon: l.activeMembers.length == 1 && repo.partner != null
                ? ListIcon.lock
                : ListIcon.list,
          ),
        )
        .toList();

    return HomeData(
      activeList: ActiveList(
        id: home.id,
        name: home.name,
        kind: kind,
        members: home.activeMembers,
        previewItems: [
          for (final item in toBuy.take(ActiveList.previewLimit)) item.name,
        ],
        totalItems: toBuy.length,
        boughtCount: home.bought.length,
      ),
      otherLists: others,
      templates: others.isEmpty ? templatesFor(kind) : const [],
      activities: repo.activitiesFor(kind),
      stores: [...home.stores, kAnyStore],
    );
  }

  final ActiveList activeList;
  final List<ListSummary> otherLists;
  final List<ListTemplate> templates;
  final List<Activity> activities;

  /// Options for the "Store" dropdown when adding an item.
  final List<String> stores;
}
