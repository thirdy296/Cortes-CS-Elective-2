// providers/favorites_provider.dart
// Owns which Pokémon the user marked as favorite.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import 'pokemon_list_provider.dart';

/// Manages the set of favorite Pokémon ids.
///
/// WHY a `Set<int>`: a Pokémon is either a favorite or not, ids are unique,
/// and `contains` is fast. Storing ids (not Pokemon objects) keeps favorites
/// valid even after the list is re-fetched.
///
/// Every change assigns a NEW Set (immutable update). Riverpod compares the
/// old and new state; mutating the same Set in place would not rebuild the UI.
class FavoritesNotifier extends Notifier<Set<int>> {
  /// Starts with no favorites.
  @override
  Set<int> build() => const {};

  /// Adds the Pokémon if it is not a favorite yet, otherwise removes it.
  /// Used by the heart icon on cards and on the detail page.
  void toggleFavorite(int id) {
    if (isFavorite(id)) {
      removeFavorite(id);
    } else {
      state = {...state, id};
    }
  }

  /// Whether [id] is currently a favorite.
  /// For one-off checks (e.g. the SnackBar text). Widgets that must REBUILD
  /// on change use `ref.watch(favoritesProvider.select(...))` instead.
  bool isFavorite(int id) => state.contains(id);

  /// Removes [id] from favorites. Used by the remove button in the panel.
  void removeFavorite(int id) {
    state = state.where((favoriteId) => favoriteId != id).toSet();
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<int>>(
  FavoritesNotifier.new,
);

/// DERIVED state: the actual Pokemon objects that are favorites.
///
/// It combines two providers: the loaded list + the favorite ids. Riverpod
/// re-runs this automatically when EITHER one changes, so the favorites
/// panel is always in sync without any manual bookkeeping.
final favoritePokemonProvider = Provider<List<Pokemon>>((ref) {
  final favoriteIds = ref.watch(favoritesProvider);
  // `.value` is the last loaded list (null while nothing has loaded yet).
  final allPokemon = ref.watch(pokemonListProvider).value ?? const <Pokemon>[];
  return allPokemon.where((p) => favoriteIds.contains(p.id)).toList();
});
