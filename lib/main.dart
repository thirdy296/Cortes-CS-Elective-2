import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/auth_gate.dart';
import 'supabase_config.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  // ProviderScope stores the state of every Riverpod provider.
  runApp(const ProviderScope(child: BrewAndBeanApp()));
}

class BrewAndBeanApp extends StatelessWidget {
  const BrewAndBeanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brew & Bean',
      theme: AppTheme.light(),
      home: const AuthGate(),
    );
  }
}
