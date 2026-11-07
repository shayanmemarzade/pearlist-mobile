/// What the "Add item" sheet returns. Send this to the items API.
class NewItem {
  const NewItem({
    required this.name,
    this.store,
    this.quantity = 1,
    this.urgent = false,
  });

  final String name;

  /// Null means no preference.
  final String? store;
  final int quantity;
  final bool urgent;
}
