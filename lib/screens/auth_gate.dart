import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../supabase_config.dart';
import 'login_screen.dart';
import 'shop_screen.dart';

/// Shows the shop when signed in and the login screen when signed out.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Without keys there is nothing to sign in to; the shop explains setup.
    if (!SupabaseConfig.isConfigured) return const ShopScreen();

    final session = ref.watch(sessionProvider);
    return session.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => LoginScreen(initialError: '$e'),
      data: (session) =>
          session == null ? const LoginScreen() : const ShopScreen(),
    );
  }
}
