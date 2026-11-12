// Auth state with Riverpod: the UI watches [sessionProvider] and switches
// between the login screen and the shop whenever Supabase reports a sign in
// or sign out (email, GitHub, token refresh, or sign out from any screen).

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// The current session, or null when signed out. Starts with the session
/// restored from storage, then follows every auth event.
final sessionProvider = StreamProvider<Session?>((ref) async* {
  final auth = ref.watch(authServiceProvider);
  yield auth.currentSession;
  await for (final event in auth.onAuthStateChange) {
    yield event.session;
  }
});

/// The signed-in user, or null.
final currentUserProvider = Provider<User?>(
  (ref) => ref.watch(sessionProvider).value?.user,
);

/// Short label for the account menu: email, or GitHub username.
String displayName(User user) {
  final meta = user.userMetadata ?? const {};
  return (meta['user_name'] ??
          meta['preferred_username'] ??
          user.email ??
          'Signed in')
      as String;
}

/// Which provider the user signed in with, e.g. "email" or "github".
String signInProvider(User user) =>
    (user.appMetadata['provider'] as String?) ?? 'email';
