import 'package:flutter_test/flutter_test.dart';
import 'package:pear_list/core/utils/time_format.dart';
import 'package:pear_list/data/models.dart';
import 'package:pear_list/data/sample_data.dart';
import 'package:pear_list/data/smart_aisle.dart';
import 'package:pear_list/features/add_item/domain/new_item.dart';
import 'package:pear_list/features/add_list/domain/new_list.dart';
import 'package:pear_list/features/home/domain/home_models.dart';

void main() {
  group('formatTimeAgo', () {
    final now = DateTime(2026, 11, 8, 12);

    test('formats minutes, hours, days and weeks', () {
      expect(formatTimeAgo(now.subtract(const Duration(seconds: 20)), now: now),
          'Just now');
      expect(formatTimeAgo(now.subtract(const Duration(minutes: 2)), now: now),
          '2m ago');
      expect(formatTimeAgo(now.subtract(const Duration(hours: 3)), now: now),
          '3h ago');
      expect(formatTimeAgo(now.subtract(const Duration(days: 2)), now: now),
          '2d ago');
      expect(formatTimeAgo(now.subtract(const Duration(days: 15)), now: now),
          '2w ago');
    });
  });

  group('formatItemTime', () {
    final now = DateTime(2026, 11, 8, 12); // a Sunday

    test('matches the list row labels in Figma', () {
      expect(formatItemTime(now, now: now), 'Just now');
      expect(formatItemTime(now.subtract(const Duration(minutes: 2)), now: now),
          '2m ago');
      expect(formatItemTime(DateTime(2026, 11, 7, 18), now: now), 'Yesterday');
      expect(formatItemTime(DateTime(2026, 11, 3, 9), now: now), 'Tue');
      expect(formatItemTime(DateTime(2026, 10, 12, 9), now: now), 'Oct 12');
    });
  });

  group('guessAisle', () {
    test('files items into the list’s aisles', () {
      expect(guessAisle('Apricots', kDefaultAisles), 'Produce');
      expect(guessAisle('Oat milk', kDefaultAisles), 'Dairy & eggs');
      expect(guessAisle('Sourdough bread', kDefaultAisles), 'Bakery');
      expect(guessAisle('Rice', kDefaultAisles), 'Pantry');
      expect(guessAisle('Hammer', kDefaultAisles), kOtherAisle);
    });
  });

  group('PearRepository', () {
    test('addItem files the item, maps "Any store" and logs activity', () {
      final repo = SampleData.repository(SampleState.nothingAdded);
      final item = repo.addItem(
        'weekly',
        const NewItem(name: 'Eggs', store: kAnyStore, quantity: 2),
      );
      expect(item.aisle, 'Dairy & eggs');
      expect(item.store, isNull);
      expect(item.displayName, '2 x Eggs');
      expect(repo.activities.first.description, 'You added Eggs');
    });

    test('remove and undo puts the item back in place', () {
      final repo = SampleData.repository(SampleState.shared);
      final before = repo.listById('weekly')!.items.map((i) => i.id).toList();
      final removed = repo.removeItem('weekly', 'eggs')!;
      expect(repo.listById('weekly')!.items.any((i) => i.id == 'eggs'),
          isFalse);
      repo.restoreItem('weekly', removed.index, removed.item);
      expect(repo.listById('weekly')!.items.map((i) => i.id), before);
    });

    test('checking off moves an item to Bought', () {
      final repo = SampleData.repository(SampleState.shared);
      final list = repo.listById('weekly')!;
      final bought = list.bought.length;
      repo.setBought('weekly', 'apple', bought: true);
      expect(list.bought.length, bought + 1);
      expect(list.toBuy.any((i) => i.id == 'apple'), isFalse);
    });

    test('moveItem reorders within one aisle', () {
      final repo = SampleData.repository(SampleState.shared);
      repo.moveItem('weekly', 'Produce', 0, 1);
      final produce = repo
          .listById('weekly')!
          .groupedByAisle()
          .firstWhere((g) => g.aisle == 'Produce')
          .items
          .map((i) => i.id);
      expect(produce, ['apricots', 'apple']);
    });

    test('renaming an aisle moves its items and refuses duplicates', () {
      final repo = SampleData.repository(SampleState.shared);
      final list = repo.listById('weekly')!;
      final index = list.aisles.indexOf('Produce');
      expect(repo.renameEntry('weekly', index, 'Bakery', aisle: true), isFalse);
      expect(repo.renameEntry('weekly', index, 'Fruit & veg', aisle: true),
          isTrue);
      expect(list.items.where((i) => i.aisle == 'Fruit & veg'), isNotEmpty);
    });

    test('createList shares only on Pro with a partner', () {
      final pro = SampleData.repository(SampleState.shared);
      final shared = pro.createList(
        const NewList(name: 'BBQ', shareWithPartner: true),
      );
      expect(shared.activeMembers.length, 2);

      final free = SampleData.repository(SampleState.privateOnly);
      final private = free.createList(
        const NewList(name: 'BBQ', shareWithPartner: true),
      );
      expect(private.activeMembers.length, 1);
    });
  });

  group('HomeData.fromRepository', () {
    test('shared state previews the first items and counts the rest', () {
      final home = HomeData.fromRepository(
        SampleData.repository(SampleState.shared),
      )!;
      expect(home.activeList.previewItems, ['Apple', 'Apricots', 'Eggs']);
      expect(home.activeList.moreCount, 2);
      expect(home.otherLists.length, 2);
      expect(home.templates, isEmpty);
      expect(home.stores.last, kAnyStore);
    });

    test('empty state offers templates and has no activity', () {
      final home = HomeData.fromRepository(
        SampleData.repository(SampleState.nothingAdded),
      )!;
      expect(home.activeList.isEmpty, isTrue);
      expect(home.templates, isNotEmpty);
      expect(home.activities, isEmpty);
    });

    test('turning sharing off makes the list "Only you"', () {
      final repo = SampleData.repository(SampleState.shared);
      repo.setShared('weekly', false);
      final home = HomeData.fromRepository(repo)!;
      expect(home.activeList.members.length, 1);
    });
  });
}
