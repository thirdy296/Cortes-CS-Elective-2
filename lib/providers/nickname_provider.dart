// providers/nickname_provider.dart
// Owns the nicknames the user gave to Pokémon.

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages nicknames as a map of Pokémon id → nickname.
///
/// WHY a `Map<int, String>`: lookups by id are instant, and a Pokémon without
/// a nickname simply has no entry. The original name is never changed, so
/// the UI can always show it underneath the nickname.
///
/// Every change assigns a NEW Map (immutable update). Riverpod notices the
/// new object and rebuilds the widgets that watch it.
class NicknameNotifier extends Notifier<Map<int, String>> {
  /// Starts with no nicknames.
  @override
  Map<int, String> build() => const {};

  /// Saves [nickname] for [id] (trimmed).
  /// Empty or whitespace-only input is treated as "remove the nickname",
  /// so we never store a blank name.
  void setNickname(int id, String nickname) {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty) {
      removeNickname(id);
      return;
    }
    state = {...state, id: trimmed};
  }

  /// Deletes the nickname for [id], so the original name shows again.
  void removeNickname(int id) {
    if (!state.containsKey(id)) return; // nothing to do → no rebuild
    state = Map.of(state)..remove(id);
  }
}

final nicknameProvider = NotifierProvider<NicknameNotifier, Map<int, String>>(
  NicknameNotifier.new,
);
