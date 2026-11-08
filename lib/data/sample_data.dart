import 'models.dart';
import 'pear_repository.dart';

/// The Home states drawn in Figma, as sample repositories for previews and
/// until the API is connected.
enum SampleState {
  nothingAdded('Nothing added'),
  noItemAdded('No item added'),
  shared('Shared'),
  privateOnly('Private');

  const SampleState(this.label);
  final String label;
}

abstract final class SampleData {
  static const Person olivia = Person(
    id: 'me',
    name: 'Olivia Rhye',
    email: 'olivia@gmail.com',
    isMe: true,
  );
  static const Person sam = Person(
    id: 'sam',
    name: 'Sam',
    email: 'sam@gmail.com',
  );

  static PearRepository repository(SampleState state) {
    final now = DateTime.now();
    final shared = state == SampleState.nothingAdded ||
        state == SampleState.shared;
    final withItems =
        state == SampleState.shared || state == SampleState.privateOnly;
    final members = shared ? [olivia, sam] : [olivia];
    final partner = shared ? sam : olivia;

    ShoppingItem item(
      String id,
      String name, {
      required String aisle,
      required Duration ago,
      String? store,
      int quantity = 1,
      bool urgent = false,
      Person? by,
      bool bought = false,
    }) {
      return ShoppingItem(
        id: id,
        name: name,
        quantity: quantity,
        store: store,
        aisle: aisle,
        urgent: urgent,
        addedBy: by ?? olivia,
        addedAt: now.subtract(ago),
        boughtAt: bought ? now.subtract(ago ~/ 2) : null,
      );
    }

    final weekly = ShoppingList(
      id: 'weekly',
      name: 'Weekly groceries',
      owner: olivia,
      members: members,
      isDefault: true,
      autoClearBought: true,
      items: withItems
          ? [
              item('apple', 'Apple',
                  aisle: 'Produce',
                  store: 'Whole Foods',
                  urgent: true,
                  ago: const Duration(seconds: 20)),
              item('apricots', 'Apricots',
                  aisle: 'Produce',
                  store: "Trader Joe's",
                  quantity: 2,
                  urgent: true,
                  by: partner,
                  ago: const Duration(minutes: 2)),
              item('eggs', 'Eggs',
                  aisle: 'Dairy & eggs',
                  store: 'Whole Foods',
                  quantity: 3,
                  ago: const Duration(days: 1)),
              item('yogurt', 'Greek yogurt',
                  aisle: 'Dairy & eggs',
                  store: "Trader Joe's",
                  by: partner,
                  ago: const Duration(days: 3)),
              item('bread', 'Bread',
                  aisle: 'Bakery',
                  store: 'Whole Foods',
                  ago: const Duration(days: 20)),
              for (final (i, name) in const [
                'Bananas',
                'Oat milk',
                'Olive oil',
                'Almond milk',
              ].indexed)
                item('bought$i', name,
                    aisle: i == 0 ? 'Produce' : 'Pantry',
                    ago: Duration(days: i + 1),
                    bought: true),
            ]
          : [],
    );

    List<ShoppingItem> filler(String prefix, List<String> names) => [
          for (final (i, name) in names.indexed)
            item('$prefix$i', name,
                aisle: kOtherAisle, ago: Duration(hours: i + 1)),
        ];

    final otherLists = withItems
        ? [
            ShoppingList(
              id: 'party',
              name: 'Party List',
              owner: olivia,
              items: filler('party', const [
                'Chips', 'Salsa', 'Soda', 'Cups', 'Napkins', 'Ice',
                'Lemons', 'Candles', 'Balloons', 'Cake', 'Plates', 'Dip',
              ]),
            ),
            ShoppingList(
              id: 'costco',
              name: 'Costco run',
              owner: olivia,
              members: members,
              items: filler('costco', const [
                'Paper towels', 'Rice', 'Coffee', 'Water', 'Nuts',
                'Detergent', 'Salmon',
              ]),
            ),
          ]
        : <ShoppingList>[];

    final activities = state == SampleState.shared
        ? [
            Activity(
              id: 'a1',
              actor: sam,
              description: 'Sam added Olive oil',
              at: now.subtract(const Duration(minutes: 2)),
            ),
            Activity(
              id: 'a2',
              actor: olivia,
              description: 'You checked off Almond milk',
              at: now.subtract(const Duration(minutes: 2)),
            ),
            Activity(
              id: 'a3',
              actor: sam,
              description: 'Sam added Hammer',
              at: now.subtract(const Duration(minutes: 2)),
            ),
          ]
        : state == SampleState.privateOnly
            ? [
                Activity(
                  id: 'a1',
                  actor: olivia,
                  description: 'You added Apple',
                  at: now.subtract(const Duration(seconds: 20)),
                ),
                Activity(
                  id: 'a2',
                  actor: olivia,
                  description: 'You checked off Almond milk',
                  at: now.subtract(const Duration(days: 1)),
                ),
              ]
            : <Activity>[];

    return PearRepository(
      me: olivia,
      partner: shared ? sam : null,
      isPro: shared,
      lists: [weekly, ...otherLists],
      activities: activities,
    );
  }
}
