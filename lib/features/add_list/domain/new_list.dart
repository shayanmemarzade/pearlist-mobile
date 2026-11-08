import '../../../data/models.dart';

/// What the "Add new list" sheet returns.
class NewList {
  const NewList({
    required this.name,
    this.kind = ListKind.shopping,
    this.shareWithPartner = false,
  });

  final String name;
  final ListKind kind;
  final bool shareWithPartner;
}
