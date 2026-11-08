import '../../../data/models.dart';

/// What the "Add wish" / "Add place" sheet returns.
class NewCollectionItem {
  const NewCollectionItem({
    required this.name,
    this.link,
    this.note,
    this.level = ItemLevel.high,
  });

  final String name;

  /// Wish URL or place address.
  final String? link;
  final String? note;
  final ItemLevel level;
}
