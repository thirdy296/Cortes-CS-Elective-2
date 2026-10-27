import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase project settings, passed in at build time so keys never live in
/// the source code. Run the app with:
///
///   flutter run --dart-define-from-file=supabase.json
///
/// where supabase.json (git-ignored) looks like supabase.example.json.
class SupabaseConfig {
  static const url = String.fromEnvironment('SUPABASE_URL');
  static const publishableKey =
      String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static bool get isConfigured => url.isNotEmpty && publishableKey.isNotEmpty;

  /// Connects to Supabase. Call once in main() before runApp().
  /// If the keys are missing, the app still starts and prints a warning.
  static Future<void> init() async {
    if (!isConfigured) {
      debugPrint(
        'Supabase is not configured. Run with '
        '--dart-define-from-file=supabase.json',
      );
      return;
    }
    await Supabase.initialize(url: url, publishableKey: publishableKey);
  }
}

/// Shortcut to the Supabase client, e.g. `supabase.from('songs').select()`.
SupabaseClient get supabase => Supabase.instance.client;
