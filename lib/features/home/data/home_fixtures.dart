import '../domain/home_models.dart';

/// Sample data for the four Home states in Figma ("Home / Shopping page").
/// Use until the Home API is wired up, and for previews.
abstract final class HomeFixtures {
  static const Person me = Person(id: 'me', name: 'Taylor', isMe: true);
  static const Person sam = Person(id: 'sam', name: 'Sam');

  static const List<String> _stores = ['Whole Foods', 'Target', 'Any store'];

  static const List<ListTemplate> _templates = [
    ListTemplate(name: 'Grocery list'),
    ListTemplate(name: 'Party list'),
    ListTemplate(name: 'Personal list', icon: ListIcon.lock),
  ];

  static const ActiveList _weeklyGroceries = ActiveList(
    id: 'weekly',
    name: 'Weekly groceries',
    members: [me, sam],
    previewItems: ['Bananas', 'Oat milk', 'Greek yogurt'],
    totalItems: 8,
  );

  static List<Activity> _activities() {
    final now = DateTime.now();
    return [
      Activity(
        id: 'a1',
        actor: sam,
        description: 'Sam added Olive oil',
        at: now.subtract(const Duration(minutes: 2)),
      ),
      Activity(
        id: 'a2',
        actor: me,
        description: 'You checked off Almond milk',
        at: now.subtract(const Duration(minutes: 2)),
      ),
      Activity(
        id: 'a3',
        actor: sam,
        description: 'Sam added Hammer',
        at: now.subtract(const Duration(minutes: 2)),
      ),
    ];
  }

  /// Figma: "Home - nothing added" — shared list, no items yet.
  static HomeData get nothingAdded => const HomeData(
        activeList: ActiveList(id: 'weekly', name: 'Weekly groceries', members: [me, sam]),
        templates: _templates,
        stores: _stores,
      );

  /// Figma: "Home - no item added" — private list, no items yet.
  static HomeData get noItemAdded => const HomeData(
        activeList: ActiveList(id: 'weekly', name: 'Weekly groceries', members: [me]),
        templates: _templates,
        stores: _stores,
      );

  /// Figma: "Home - shared".
  static HomeData get shared => HomeData(
        activeList: _weeklyGroceries,
        otherLists: const [
          ListSummary(
            id: 'party',
            name: 'Party List',
            itemCount: 12,
            members: [me],
            icon: ListIcon.lock,
          ),
          ListSummary(
            id: 'costco',
            name: 'Costco run',
            itemCount: 7,
            members: [me, sam],
          ),
        ],
        activities: _activities(),
        stores: _stores,
      );

  /// Figma: "Home - privet" — the active list is only shared with yourself.
  static HomeData get privateOnly => HomeData(
        activeList: const ActiveList(
          id: 'weekly',
          name: 'Weekly groceries',
          members: [me],
          previewItems: ['Bananas', 'Oat milk', 'Greek yogurt'],
          totalItems: 8,
        ),
        otherLists: const [
          ListSummary(id: 'party', name: 'Party List', itemCount: 12, members: [me]),
          ListSummary(id: 'costco', name: 'Costco run', itemCount: 7, members: [me]),
        ],
        activities: _activities(),
        stores: _stores,
      );

  static Map<String, HomeData> get all => {
        'Nothing added': nothingAdded,
        'No item added': noItemAdded,
        'Shared': shared,
        'Private': privateOnly,
      };
}
