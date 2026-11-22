import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../supabase_config.dart';
import '../utils/errors.dart';
import '../widgets/state_views.dart';
import 'home_screens.dart';
import 'login_screen.dart';

/// Signed out → login. Signed in → load the profile, then show the admin or
/// customer app depending on the role stored in the database.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!SupabaseConfig.isConfigured) {
      return const Scaffold(
        body: MessageView(
          icon: Icons.cloud_off,
          title: 'Supabase is not configured',
          message: 'Run with --dart-define-from-file=supabase.json',
        ),
      );
    }

    final session = ref.watch(sessionProvider);
    return session.when(
      loading: () => const Scaffold(body: LoadingView()),
      error: (e, _) => LoginScreen(initialError: friendlyError(e)),
      data: (session) {
        if (session == null) return const LoginScreen();
        final profile = ref.watch(profileProvider);
        return profile.when(
          loading: () =>
              const Scaffold(body: LoadingView(label: 'Loading your account')),
          error: (e, _) => Scaffold(
            body: ErrorView(
              error: e,
              onRetry: () => ref.invalidate(profileProvider),
            ),
            bottomNavigationBar: SafeArea(
              child: TextButton(
                onPressed: () => ref.read(authServiceProvider).signOut(),
                child: const Text('Sign out'),
              ),
            ),
          ),
          data: (p) => p == null
              ? const Scaffold(body: LoadingView())
              : p.isAdmin
              ? const AdminHome()
              : const CustomerHome(),
        );
      },
    );
  }
}
