import 'package:flutter/painting.dart';

import '../../../core/theme/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models.dart';

/// Wording and icons that differ between the Shopping, Wishes and Places
/// tabs (Figma pages "Shopping List", "Wish List" and "Places List").
extension ListKindCopy on ListKind {
  /// Title of the tab's main page.
  String get pageTitle => switch (this) {
        ListKind.shopping => 'Shopping list',
        ListKind.wishlist => 'My wishlist',
        ListKind.places => 'Places',
      };

  /// Back link on a list page.
  String get backLabel => this == ListKind.places ? 'Places' : 'Home';

  String get itemNoun => switch (this) {
        ListKind.shopping => 'item',
        ListKind.wishlist => 'wish',
        ListKind.places => 'place',
      };

  /// Section title above the open items.
  String get itemsTitle => switch (this) {
        ListKind.shopping => 'Items',
        ListKind.wishlist => 'Wishes',
        ListKind.places => 'Places',
      };

  String get addLabel => 'Add $itemNoun';

  String get otherListsTitle =>
      this == ListKind.wishlist ? 'Other wishlists' : 'Other lists';

  /// 18px green icon in the main card.
  String get cardIcon => switch (this) {
        ListKind.shopping => AppIcons.cart,
        ListKind.wishlist => AppIcons.giftGreen,
        ListKind.places => AppIcons.pinGreen,
      };

  String get detailsTitle => switch (this) {
        ListKind.shopping => 'Item details',
        ListKind.wishlist => 'Wish details',
        ListKind.places => 'Place details',
      };

  /// "Bought" for items and wishes, "Visited" for places.
  String get doneLabel => this == ListKind.places ? 'Visited' : 'Bought';

  String get markDoneLabel =>
      this == ListKind.places ? 'Mark as visited' : 'Mark as bought';

  String get levelTitle =>
      this == ListKind.places ? 'Interest level' : 'Wish level';

  String get sortByLevelLabel =>
      this == ListKind.places ? 'Place level' : 'Wish level';

  String levelLabel(ItemLevel level) => switch ((this, level)) {
        (ListKind.places, ItemLevel.high) => 'Must visit',
        (ListKind.places, ItemLevel.medium) => 'Want to visit',
        (ListKind.places, ItemLevel.low) => 'Maybe',
        (_, ItemLevel.high) => 'Must have',
        (_, ItemLevel.medium) => 'Would Love',
        (_, ItemLevel.low) => 'Nice to Have',
      };

  /// 18px icon in the level picker.
  String levelIcon(ItemLevel level) => switch ((this, level)) {
        (ListKind.places, ItemLevel.high) => AppIcons.pinLike,
        (ListKind.places, ItemLevel.medium) => AppIcons.flag18,
        (ListKind.places, ItemLevel.low) => AppIcons.map16,
        (_, ItemLevel.high) => AppIcons.heart18,
        (_, ItemLevel.medium) => AppIcons.ribbon18,
        (_, ItemLevel.low) => AppIcons.gift18,
      };

  /// Tint of the selected level icon (Figma: gold on wishes, brown on
  /// places).
  Color get levelIconSelected =>
      this == ListKind.places ? const Color(0xFFB4824D) : AppColors.gold;

  /// 12px icon inside the level badge; places use text-only badges.
  String? levelBadgeIcon(ItemLevel level) => this == ListKind.places
      ? null
      : switch (level) {
          ItemLevel.high => AppIcons.heart12,
          ItemLevel.medium => AppIcons.ribbon12,
          ItemLevel.low => AppIcons.gift12,
        };
}

/// Badge colours per level (Figma "Badgs": purple, magenta, sand).
({Color background, Color foreground}) levelBadgeColors(ItemLevel level) =>
    switch (level) {
      ItemLevel.high => (
          background: const Color(0xFFF9F0FF),
          foreground: const Color(0xFF531DAB),
        ),
      ItemLevel.medium => (
          background: const Color(0xFFFFF0F6),
          foreground: const Color(0xFFC41D7F),
        ),
      ItemLevel.low => (
          background: const Color(0xFFFCF5EF),
          foreground: const Color(0xFFB4824D),
        ),
    };

/// "westelm.com" for a URL, the text itself for an address.
String linkLabel(String link) {
  final uri = Uri.tryParse(link);
  if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
    return uri.host.startsWith('www.') ? uri.host.substring(4) : uri.host;
  }
  return link;
}

/// True for web links; anything else is treated as an address.
bool isWebLink(String link) {
  final uri = Uri.tryParse(link.trim());
  return uri != null &&
      (uri.scheme == 'http' || uri.scheme == 'https') &&
      uri.host.isNotEmpty;
}
