import 'package:flutter_test/flutter_test.dart';
import 'package:pear_list/features/home/data/home_fixtures.dart';
import 'package:pear_list/features/home/domain/home_models.dart';
import 'package:pear_list/features/home/presentation/time_ago.dart';

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

  group('ActiveList', () {
    test('counts the items hidden behind "+N more"', () {
      expect(HomeFixtures.shared.activeList.moreCount, 5);
      expect(HomeFixtures.nothingAdded.activeList.isEmpty, isTrue);
    });
  });

  test('fixtures cover the four Figma states', () {
    final states = HomeFixtures.all;
    expect(states.length, 4);
    expect(states['Shared']!.otherLists.any((l) => l.isShared), isTrue);
    expect(
      states['Private']!.activeList.members.every((Person p) => p.isMe),
      isTrue,
    );
    expect(states['Nothing added']!.templates, isNotEmpty);
  });

  group('withItemAdded', () {
    test('adds the item to an empty list and logs the activity', () {
      final at = DateTime(2026, 11, 8, 12);
      final data = HomeFixtures.nothingAdded.withItemAdded('Eggs', at: at);
      expect(data.activeList.totalItems, 1);
      expect(data.activeList.previewItems, ['Eggs']);
      expect(data.activities.first.description, 'You added Eggs');
      expect(data.activities.first.actor.isMe, isTrue);
      expect(data.stores, isNotEmpty);
    });

    test('keeps the preview at three names and grows "+N more"', () {
      final data = HomeFixtures.shared.withItemAdded('Eggs');
      expect(data.activeList.previewItems.length, ActiveList.previewLimit);
      expect(data.activeList.moreCount, 6);
    });
  });
}
