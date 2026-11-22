// Auth + role state. Screens never touch Supabase: they watch these
// providers, and the providers call the services.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/profile.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final profileServiceProvider = Provider<ProfileService>(
  (ref) => ProfileService(),
);

/// The current session, or null when signed out. Starts with the session
/// restored from storage, then follows every auth event (sign in, Google
/// redirect, token refresh, sign out).
final sessionProvider = StreamProvider<Session?>((ref) async* {
  final auth = ref.watch(authServiceProvider);
  yield auth.currentSession;
  await for (final event in auth.onAuthStateChange) {
    yield event.session;
  }
});

/// The signed-in user's id, or null. Only changes when the user changes,
/// so token refreshes don't refetch the profile.
final currentUserIdProvider = Provider<String?>(
  (ref) => ref.watch(sessionProvider).value?.user.id,
);

/// The signed-in user's profile and role.
final profileProvider = FutureProvider<Profile?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  return ref.watch(profileServiceProvider).fetchMyProfile(userId);
});

/// True for admins. The UI uses it to show or hide controls; the database
/// enforces the same rule with RLS, so hiding a button is not the security.
final isAdminProvider = Provider<bool>(
  (ref) => ref.watch(profileProvider).value?.isAdmin ?? false,
);
