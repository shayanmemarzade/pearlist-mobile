import 'invites.dart';
import 'models.dart';
import 'notifications.dart';
import 'preferences.dart';
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
    phone: '4155550132',
    isMe: true,
  );
  static const Person sam = Person(
    id: 'sam',
    name: 'Sam',
    email: 'sam@gmail.com',
    phone: '4155550148',
  );

  /// Sam's invitation, for the "Join Sam's shared lists?" screens.
  static const IncomingInvite samInvite = IncomingInvite(
    id: 'invite-from-sam',
    from: sam,
    lists: {ListKind.shopping, ListKind.wishlist, ListKind.places},
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

    final collections = _collections(
      now: now,
      members: members,
      partner: partner,
      withItems: withItems,
    );

    return PearRepository(
      me: olivia,
      partner: shared ? sam : null,
      isPro: shared,
      billing: shared ? ProBilling.yearly : null,
      invites: state == SampleState.shared
          ? [
              Invite(
                id: 'invite-lena',
                name: 'Lena',
                address: 'Lena@Gmail.com',
                lists: {...ListKind.values},
                status: InviteStatus.sent,
                sentAt: now.subtract(const Duration(days: 2)),
              ),
            ]
          : null,
      notifications: state == SampleState.shared ? _notifications(now) : null,
      lists: [weekly, ...otherLists, ...collections.lists],
      activities: [...activities, ...collections.activities]
        ..sort((a, b) => b.at.compareTo(a.at)),
    );
  }

  /// Sam's invitation as seen by someone who already has an account.
  static const IncomingInvite samInviteSignedIn = IncomingInvite(
    id: 'invite-from-sam-2',
    from: sam,
    lists: {ListKind.shopping, ListKind.wishlist, ListKind.places},
    summaries: {
      ListKind.shopping: (lists: 2, items: 14),
      ListKind.wishlist: (lists: 1, items: 12),
      ListKind.places: (lists: 1, items: 4),
    },
  );

  /// Figma "Notification - filled".
  static List<AppNotification> _notifications(DateTime now) => [
        AppNotification(
          id: 'n1',
          type: NotificationType.invite,
          title: 'Sam invited you to Date nights',
          body: 'Places \u00b7 7 spots to try together',
          at: now.subtract(const Duration(minutes: 5)),
          actor: sam,
          invite: samInviteSignedIn,
        ),
        AppNotification(
          id: 'n2',
          type: NotificationType.completed,
          title: 'Sam checked off all 9 items.',
          body: 'Places \u00b7 7 spots to try together',
          at: now.subtract(const Duration(minutes: 15)),
          actor: sam,
          read: true,
        ),
        AppNotification(
          id: 'n3',
          type: NotificationType.wishBought,
          title: 'A wish was bought',
          body: 'Something from Birthday ideas is taken care of. We won\u2019t '
              'spoil which one.',
          at: now.subtract(const Duration(minutes: 25)),
          read: true,
        ),
        AppNotification(
          id: 'n4',
          type: NotificationType.wishBought,
          title: 'A wish was bought',
          body: 'Something from Our home is taken care of. We won\u2019t '
              'spoil which one.',
          at: now.subtract(const Duration(hours: 1)),
          read: true,
        ),
      ];

  /// Wish lists and place lists (Figma pages "Wish List" and "Places List").
  static ({List<ShoppingList> lists, List<Activity> activities}) _collections({
    required DateTime now,
    required List<Person> members,
    required Person partner,
    required bool withItems,
  }) {
    ShoppingItem entry(
      String id,
      String name, {
      required Duration ago,
      String? link,
      String? note,
      ItemLevel level = ItemLevel.high,
      Person? by,
      bool bought = false,
      bool secretly = false,
    }) {
      return ShoppingItem(
        id: id,
        name: name,
        aisle: kOtherAisle,
        addedBy: by ?? olivia,
        addedAt: now.subtract(ago),
        link: link,
        note: note,
        level: level,
        boughtAt: bought ? now.subtract(ago ~/ 2) : null,
        boughtSecretly: secretly,
      );
    }

    final ourHome = ShoppingList(
      id: 'our-home',
      name: 'Our home',
      kind: ListKind.wishlist,
      owner: olivia,
      members: members,
      isDefault: true,
      items: withItems
          ? [
              entry('w1', 'Linen duvet cover',
                  ago: const Duration(seconds: 20),
                  note: 'Queen size, natural color, not white.'),
              entry('w2', 'Noise-cancelling headphones',
                  ago: const Duration(minutes: 2),
                  level: ItemLevel.medium,
                  by: partner,
                  link: 'https://www.traderjoes.com'),
              entry('w3', 'Stand mixer, 5 qt',
                  ago: const Duration(days: 4),
                  link: 'https://www.westelm.com/products/stand-mixer'),
              entry('w4', 'Ceramic table lamp',
                  ago: const Duration(days: 35),
                  level: ItemLevel.low,
                  link: 'https://www.westelm.com/products/ceramic-lamp'),
              entry('w5', 'Travel pillow',
                  ago: const Duration(days: 40),
                  level: ItemLevel.low,
                  link: 'https://www.rei.com/product/travel-pillow'),
              entry('w6', 'Cast iron skillet',
                  ago: const Duration(days: 12),
                  bought: true,
                  link: 'https://www.lodgecastiron.com'),
              entry('w7', 'Espresso cups',
                  ago: const Duration(days: 9),
                  level: ItemLevel.medium,
                  bought: true,
                  secretly: true),
            ]
          : null,
    );
    final dateNights = ShoppingList(
      id: 'date-nights',
      name: 'Date nights',
      kind: ListKind.places,
      owner: olivia,
      members: members,
      isDefault: true,
      items: withItems
          ? [
              entry('p1', 'Osteria Lucia',
                  ago: const Duration(minutes: 2),
                  link: '415 Hayes St, San Francisco',
                  note: 'Book ahead, ask for the patio.'),
              entry('p2', 'Trattoria da Enzo',
                  ago: const Duration(minutes: 3),
                  level: ItemLevel.medium,
                  by: partner,
                  link: 'North Beach, San Francisco'),
              entry('p3', 'Café Frieda',
                  ago: const Duration(minutes: 5),
                  link: '1300 Valencia St, San Francisco'),
              entry('p4', 'The Lantern Room',
                  ago: const Duration(minutes: 8),
                  level: ItemLevel.low),
              entry('p5', 'Nopa',
                  ago: const Duration(days: 6),
                  bought: true,
                  link: '560 Divisadero St, San Francisco'),
            ]
          : null,
    );

    final lists = <ShoppingList>[
      ourHome,
      dateNights,
      if (withItems) ...[
        ShoppingList(
          id: 'travel',
          name: 'Travel',
          kind: ListKind.wishlist,
          owner: olivia,
          items: [
            for (var i = 0; i < 12; i++)
              entry('travel-$i', 'Travel wish ${i + 1}',
                  ago: Duration(days: i + 1)),
          ],
        ),
        ShoppingList(
          id: 'birthday',
          name: 'Birthday idea',
          kind: ListKind.wishlist,
          owner: olivia,
          members: members,
          items: [
            for (var i = 0; i < 7; i++)
              entry('bday-$i', 'Gift idea ${i + 1}', ago: Duration(days: i)),
          ],
        ),
        ShoppingList(
          id: 'weekend-trips',
          name: 'Weekend trips',
          kind: ListKind.places,
          owner: olivia,
          items: [
            for (final (i, name) in const [
              'Point Reyes', 'Sonoma', 'Big Sur', 'Lake Tahoe', 'Mendocino',
              'Carmel', 'Yosemite', 'Santa Cruz', 'Half Moon Bay',
              'Napa', 'Monterey', 'Bodega Bay',
            ].indexed)
              entry('trip-$i', name, ago: Duration(days: i + 2)),
          ],
        ),
        ShoppingList(
          id: 'coffee-spots',
          name: 'Coffee spots',
          kind: ListKind.places,
          owner: olivia,
          members: members,
          items: [
            for (final (i, name) in const [
              'Sightglass', 'Ritual', 'Blue Bottle', 'Andytown',
              'Saint Frank', 'Linea', 'Four Barrel', 'Wrecking Ball',
              'Equator',
            ].indexed)
              entry('coffee-$i', name, ago: Duration(days: i + 1)),
          ],
        ),
      ],
    ];

    final other = partner.isMe ? null : partner;
    final activities = !withItems
        ? <Activity>[]
        : [
            Activity(
              id: 'wa1',
              actor: other ?? olivia,
              description:
                  other == null ? 'You added Stand mixer' : 'Sam added Stand mixer',
              at: now.subtract(const Duration(minutes: 2)),
              kind: ListKind.wishlist,
              listName: 'Our home',
            ),
            Activity(
              id: 'wa2',
              actor: olivia,
              description: 'You saved Ceramic table lamp',
              at: now.subtract(const Duration(hours: 1)),
              kind: ListKind.wishlist,
              listName: 'Our home',
            ),
            Activity(
              id: 'pa1',
              actor: other ?? olivia,
              description: other == null
                  ? 'You added Trattoria da Enzo'
                  : 'Sam added Trattoria da Enzo',
              at: now.subtract(const Duration(minutes: 3)),
              kind: ListKind.places,
              listName: 'Date nights',
            ),
            Activity(
              id: 'pa2',
              actor: olivia,
              description: 'You visited Nopa',
              at: now.subtract(const Duration(days: 3)),
              kind: ListKind.places,
              listName: 'Date nights',
            ),
          ];

    return (lists: lists, activities: activities);
  }
}
