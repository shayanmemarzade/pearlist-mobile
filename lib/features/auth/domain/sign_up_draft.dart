/// What the user enters across the sign-up screens; saved to the
/// repository when the flow finishes.
class SignUpDraft {
  String name = '';
  List<String> stores = [];

  /// 10 US digits.
  String phone = '';

  /// Local path of the picked profile photo.
  String? photoPath;
  String? email;

  /// Signed up from an invitation: the shared lists are already there, so
  /// the "Share your lists" step is skipped.
  bool joinedInvite = false;
}

/// Sign up (new account) or sign in (existing account) — the phone and
/// code screens are shared.
enum AuthMode { signUp, signIn }
