/// View models for the Home / Shopping page, built from [PearRepository].
library;

import '../../../data/models.dart';
import '../../../data/pear_repository.dart';

export '../../../data/models.dart' show Activity, Person;

/// The list shown in the big card at the top of Home.
class ActiveList {
  const ActiveList({
    required this.id,
    required this.name,
    required this.members,
    this.previewItems = const [],
    this.totalItems = 0,
  });

  final String id;
  final String name;

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

enum ListIcon { list, lock }

/// A card in the "Other lists" row.
class ListSummary {
  const ListSummary({
    required this.id,
    required this.name,
    required this.itemCount,
    required this.members,
    this.icon = ListIcon.list,
  });

  final String id;
  final String name;
  final int itemCount;
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

class HomeData {
  const HomeData({
    required this.activeList,
    this.otherLists = const [],
    this.templates = const [],
    this.activities = const [],
    this.stores = const [],
  });

  /// Builds the Home view from the repository. Returns null when the user
  /// has no shopping list yet.
  static HomeData? fromRepository(PearRepository repo) {
    final home = repo.homeList;
    if (home == null) return null;

    final toBuy = home.toBuy;
    final others = repo.lists
        .where((l) => l.kind == ListKind.shopping && l.id != home.id)
        .map(
          (l) => ListSummary(
            id: l.id,
            name: l.name,
            itemCount: l.toBuy.length,
            members: l.activeMembers,
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
        members: home.activeMembers,
        previewItems: [
          for (final item in toBuy.take(ActiveList.previewLimit)) item.name,
        ],
        totalItems: toBuy.length,
      ),
      otherLists: others,
      templates: others.isEmpty ? kListTemplates : const [],
      activities: repo.activities,
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
