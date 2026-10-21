// providers/favorites_panel_provider.dart
// Owns whether the retractable favorites panel is open.

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages the open/closed state of the favorites panel.
///
/// WHY a provider (not setState): the panel appears on BOTH the home page
/// and the detail page. Keeping the flag in Riverpod means that if you open
/// it on one screen, it is still open when you navigate to the other.
class FavoritesPanelNotifier extends Notifier<bool> {
  /// The panel starts closed.
  @override
  bool build() => false;

  /// Opens the panel if closed, closes it if open (AppBar favorites button).
  void toggle() => state = !state;

  /// Closes the panel (the close button inside the panel).
  void close() => state = false;
}

final favoritesPanelProvider = NotifierProvider<FavoritesPanelNotifier, bool>(
  FavoritesPanelNotifier.new,
);
