import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_config.dart';

/// Deep link Google returns to on Android/iOS. Also listed in
/// Supabase → Authentication → URL Configuration → Redirect URLs, and
/// registered in AndroidManifest.xml and ios/Runner/Info.plist.
const kMobileAuthRedirect = 'io.supabase.cselective2://login-callback/';

/// Only this class talks to Supabase Auth.
class AuthService {
  GoTrueClient get _auth => supabase.auth;

  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;
  Session? get currentSession => _auth.currentSession;

  Future<void> signInWithEmail(String email, String password) =>
      _auth.signInWithPassword(email: email, password: password);

  /// Creates an account. The `handle_new_user` trigger copies firstname and
  /// lastname from this metadata into `profiles` and makes the user a
  /// customer. Returns true if signed in right away, false if Supabase sent
  /// a confirmation email first.
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) async {
    final res = await _auth.signUp(
      email: email,
      password: password,
      data: {'firstname': firstname, 'lastname': lastname},
      emailRedirectTo: kIsWeb ? null : kMobileAuthRedirect,
    );
    return res.session != null;
  }

  /// Google OAuth. Opens Google's sign-in page; on return supabase_flutter
  /// stores the session and [onAuthStateChange] fires `signedIn`.
  Future<void> signInWithGoogle() async {
    await _auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : kMobileAuthRedirect,
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
    );
  }

  Future<void> signOut() => _auth.signOut();
}
