/// Phone contacts, used to pick people to invite.
class Contact {
  const Contact({required this.id, required this.name, required this.phone});

  final String id;
  final String name;

  /// Formatted US number, e.g. "(415) 555-0148".
  final String phone;

  String get initial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
  }
}

/// Reads the device address book.
///
/// The app ships with [SampleContactsSource]; swap in a real implementation
/// (e.g. on top of the `flutter_contacts` package) that asks the OS for
/// permission in [requestPermission].
abstract interface class ContactsSource {
  Future<bool> requestPermission();
  Future<List<Contact>> load();
}

class SampleContactsSource implements ContactsSource {
  const SampleContactsSource();

  static const List<Contact> contacts = [
    Contact(id: 'c1', name: 'Sam', phone: '(415) 555-0148'),
    Contact(id: 'c2', name: 'Lena', phone: '(415) 555-0177'),
    Contact(id: 'c3', name: 'Alex Rivera', phone: '(628) 555-0102'),
    Contact(id: 'c4', name: 'Sara Novak', phone: '(415) 555-0190'),
    Contact(id: 'c5', name: 'Tom Becker', phone: '(510) 555-0133'),
    Contact(id: 'c6', name: 'Nina Park', phone: '(415) 555-0161'),
  ];

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<List<Contact>> load() async => contacts;
}
