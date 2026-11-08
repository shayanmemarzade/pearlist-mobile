import 'package:flutter/material.dart';

import '../../../data/pear_repository.dart';
import '../../home/presentation/home_screen.dart';
import '../../invite/presentation/share_lists_screen.dart';
import '../domain/sign_up_draft.dart';
import 'phone_number_screen.dart';
import 'sign_up_name_screen.dart';

/// Entry points and hand-offs between the auth screens.
abstract final class AuthNavigation {
  /// Welcome → "Get Started".
  static void startSignUp(BuildContext context, {bool joinedInvite = false}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SignUpNameScreen(
          draft: SignUpDraft()..joinedInvite = joinedInvite,
        ),
      ),
    );
  }

  /// Welcome → "Sign In".
  static void startSignIn(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PhoneNumberScreen(mode: AuthMode.signIn, draft: SignUpDraft()),
      ),
    );
  }

  /// Saves the new profile and moves on to inviting a partner. The sign-up
  /// screens are removed so Back can't return to them.
  static void finishSignUp(BuildContext context, SignUpDraft draft) {
    final repo = PearScope.read(context);
    repo
      ..updateProfile(
        name: draft.name,
        email: draft.email ?? '',
        avatarUrl: draft.photoPath,
      )
      ..setFavoriteStores(draft.stores);
    if (draft.joinedInvite) {
      goHome(context);
      return;
    }
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => const ShareListsScreen(mode: ShareListsMode.setup),
      ),
      (route) => false,
    );
  }

  /// Signed in: straight to Home.
  static void goHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }
}
