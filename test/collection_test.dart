import 'package:flutter_test/flutter_test.dart';
import 'package:pear_list/data/models.dart';
import 'package:pear_list/data/sample_data.dart';
import 'package:pear_list/features/collection/domain/kind_copy.dart';
import 'package:pear_list/features/collection/domain/new_collection_item.dart';
import 'package:pear_list/features/collection/presentation/widgets/collection_item_row.dart';
import 'package:pear_list/features/home/domain/home_models.dart';

void main() {
  group('Wishes and Places pages', () {
    test('each tab builds from its own lists and activity', () {
      final repo = SampleData.repository(SampleState.shared);

      final wishes = HomeData.fromRepository(repo, kind: ListKind.wishlist)!;
      expect(wishes.activeList.name, 'Our home');
      expect(wishes.activeList.boughtCount, 2);
      expect(wishes.otherLists.map((l) => l.name), ['Travel', 'Birthday idea']);
      expect(wishes.activities.every((a) => a.kind == ListKind.wishlist),
          isTrue);

      final places = HomeData.fromRepository(repo, kind: ListKind.places)!;
      expect(places.activeList.name, 'Date nights');
      expect(places.activeList.previewItems.first, 'Osteria Lucia');

      // The shopping page is unchanged.
      final shopping = HomeData.fromRepository(repo)!;
      expect(shopping.activeList.kind, ListKind.shopping);
      expect(shopping.activities.every((a) => a.kind == ListKind.shopping),
          isTrue);
    });

    test('empty states keep an empty default list and offer templates', () {
      final repo = SampleData.repository(SampleState.nothingAdded);
      final wishes = HomeData.fromRepository(repo, kind: ListKind.wishlist)!;
      expect(wishes.activeList.isEmpty, isTrue);
      expect(wishes.templates.map((t) => t.name),
          ['Birthday ideas', 'For the home', 'Travel']);
    });
  });

  group('repository', () {
    test('adding a wish logs it in the wishlist feed', () {
      final repo = SampleData.repository(SampleState.shared);
      repo.addCollectionItem(
        'our-home',
        const NewCollectionItem(
          name: 'Bath towels',
          link: ' https://www.westelm.com/towels ',
          note: '  ',
          level: ItemLevel.low,
        ),
      );
      final added = repo.listById('our-home')!.items.first;
      expect(added.name, 'Bath towels');
      expect(added.link, 'https://www.westelm.com/towels');
      expect(added.note, isNull);
      expect(added.level, ItemLevel.low);
      final activity = repo.activities.first;
      expect(activity.kind, ListKind.wishlist);
      expect(activity.listName, 'Our home');
      expect(activity.description, 'You saved Bath towels');
    });

    test('a surprise purchase is not announced', () {
      final repo = SampleData.repository(SampleState.shared);
      final before = repo.activities.length;
      repo.setBought('our-home', 'w1', bought: true, secretly: true);
      final item = repo.listById('our-home')!.items
          .firstWhere((i) => i.id == 'w1');
      expect(item.isBought, isTrue);
      expect(item.boughtSecretly, isTrue);
      expect(repo.activities.length, before);

      repo.setBought('our-home', 'w1', bought: false);
      final reopened = repo.listById('our-home')!.items
          .firstWhere((i) => i.id == 'w1');
      expect(reopened.boughtSecretly, isFalse);
    });

    test('visiting a place logs "visited"', () {
      final repo = SampleData.repository(SampleState.shared);
      repo.setBought('date-nights', 'p1', bought: true);
      expect(repo.activities.first.description, 'You visited Osteria Lucia');
    });

    test('the default list is per tab', () {
      final repo = SampleData.repository(SampleState.shared);
      repo.setDefault('birthday', true);
      expect(repo.homeListFor(ListKind.wishlist)!.id, 'birthday');
      expect(repo.homeList!.id, 'weekly');
    });
  });

  group('helpers', () {
    test('sorting', () {
      final list = SampleData.repository(SampleState.shared)
          .listById('our-home')!
          .toBuy;
      final byName = sortCollection(list, CollectionSort.alphabetical);
      expect(byName.first.name, 'Ceramic table lamp');
      final byLevel = sortCollection(list, CollectionSort.level);
      expect(byLevel.first.level, ItemLevel.high);
      expect(byLevel.last.level, ItemLevel.low);
    });

    test('links and labels', () {
      expect(linkLabel('https://www.westelm.com/products/x'), 'westelm.com');
      expect(linkLabel('415 Hayes St, San Francisco'),
          '415 Hayes St, San Francisco');
      expect(isWebLink('https://rei.com'), isTrue);
      expect(isWebLink('North Beach'), isFalse);
      expect(ListKind.places.levelLabel(ItemLevel.medium), 'Want to visit');
      expect(ListKind.wishlist.levelLabel(ItemLevel.low), 'Nice to Have');
      expect(ListKind.places.addLabel, 'Add place');
    });
  });
}
