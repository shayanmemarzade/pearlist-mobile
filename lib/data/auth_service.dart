/// Phone-number sign-in with a 4-digit text code.
///
/// The app ships with [MockAuthService], which accepts any code except
/// "0000". Replace it with the real backend by implementing this interface.
abstract interface class AuthService {
  /// Texts a code to [phone] (10 US digits).
  Future<void> sendCode(String phone);

  /// True when [code] is the one sent to [phone].
  Future<bool> verifyCode(String phone, String code);
}

class MockAuthService implements AuthService {
  const MockAuthService();

  static const Duration _latency = Duration(milliseconds: 400);

  @override
  Future<void> sendCode(String phone) => Future.delayed(_latency);

  @override
  Future<bool> verifyCode(String phone, String code) async {
    await Future<void>.delayed(_latency);
    return code.length == 4 && code != '0000';
  }
}

/// Seconds before "Resend code" becomes available again.
const int kResendCodeSeconds = 45;
