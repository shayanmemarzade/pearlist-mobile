/// View models for the Home / Shopping page.
///
/// These are shaped for the screen, not the API — map backend responses into
/// them in the data layer.
library;

class Person {
  const Person({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isMe = false,
  });

  final String id;
  final String name;
  final String? avatarUrl;
  final bool isMe;
}

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

  /// Everyone with access to the list, including the current user.
  final List<Person> members;

  /// First few unchecked item names, e.g. "Bananas, Oat milk, Greek yogurt".
  final List<String> previewItems;
  final int totalItems;

  bool get isEmpty => totalItems == 0;
  int get moreCount =>
      (totalItems - previewItems.length).clamp(0, totalItems).toInt();

  /// Max names shown in the card before "+N more".
  static const int previewLimit = 3;

  ActiveList withItemAdded(String itemName) => ActiveList(
        id: id,
        name: name,
        members: members,
        previewItems: previewItems.length < previewLimit
            ? [...previewItems, itemName]
            : previewItems,
        totalItems: totalItems + 1,
      );
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

class Activity {
  const Activity({
    required this.id,
    required this.actor,
    required this.description,
    required this.at,
  });

  final String id;
  final Person actor;

  /// Full sentence, e.g. "Sam added Olive oil".
  final String description;
  final DateTime at;
}

class HomeData {
  const HomeData({
    required this.activeList,
    this.otherLists = const [],
    this.templates = const [],
    this.activities = const [],
    this.stores = const [],
  });

  final ActiveList activeList;
  final List<ListSummary> otherLists;
  final List<ListTemplate> templates;
  final List<Activity> activities;

  /// Options for the "Store" dropdown when adding an item.
  final List<String> stores;

  /// Local update after the current user adds an item to the active list.
  HomeData withItemAdded(String itemName, {DateTime? at}) {
    final me = activeList.members.firstWhere(
      (p) => p.isMe,
      orElse: () => const Person(id: 'me', name: 'You', isMe: true),
    );
    final when = at ?? DateTime.now();
    return HomeData(
      activeList: activeList.withItemAdded(itemName),
      otherLists: otherLists,
      templates: templates,
      stores: stores,
      activities: [
        Activity(
          id: 'local-${when.microsecondsSinceEpoch}',
          actor: me,
          description: 'You added $itemName',
          at: when,
        ),
        ...activities,
      ],
    );
  }
}
