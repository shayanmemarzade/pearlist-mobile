import 'auth_service.dart';
import 'contacts.dart';

/// Back-end services used by the sign-up and invite flows. Both default to
/// mocks; assign real implementations in `main()` before `runApp`.
abstract final class AppServices {
  static AuthService auth = const MockAuthService();
  static ContactsSource contacts = const SampleContactsSource();
}
