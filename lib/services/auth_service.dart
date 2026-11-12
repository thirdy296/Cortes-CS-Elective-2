import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase_config.dart';

/// Deep link the OAuth provider returns to on Android/iOS. It must also be
/// listed in Supabase → Authentication → URL Configuration → Redirect URLs,
/// and is registered in AndroidManifest.xml and ios/Runner/Info.plist.
const kMobileAuthRedirect = 'io.supabase.cselective2://login-callback/';

/// All Supabase Auth calls live here so screens never talk to Supabase
/// directly.
class AuthService {
  GoTrueClient get _auth => supabase.auth;

  Stream<AuthState> get onAuthStateChange => _auth.onAuthStateChange;
  Session? get currentSession => _auth.currentSession;

  /// Email + password sign in.
  Future<void> signInWithEmail(String email, String password) =>
      _auth.signInWithPassword(email: email, password: password);

  /// Creates an account. Returns true if the user is signed in right away,
  /// false if Supabase sent a confirmation email first.
  Future<bool> signUpWithEmail(String email, String password) async {
    final res = await _auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: kIsWeb ? null : kMobileAuthRedirect,
    );
    return res.session != null;
  }

  /// Third-party provider: GitHub OAuth.
  ///
  /// Opens GitHub's login page. On web the browser comes back to the app's
  /// URL; on mobile GitHub → Supabase → [kMobileAuthRedirect] reopens the app.
  /// Either way supabase_flutter picks up the session automatically and
  /// [onAuthStateChange] fires `signedIn`.
  Future<void> signInWithGitHub() async {
    await _auth.signInWithOAuth(
      OAuthProvider.github,
      redirectTo: kIsWeb ? null : kMobileAuthRedirect,
      authScreenLaunchMode: kIsWeb
          ? LaunchMode.platformDefault
          : LaunchMode.externalApplication,
    );
  }

  Future<void> signOut() => _auth.signOut();
}
