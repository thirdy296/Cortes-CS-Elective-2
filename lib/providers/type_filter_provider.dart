// providers/type_filter_provider.dart
// Owns the selected type filter, plus two DERIVED providers built from it.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import 'pokemon_list_provider.dart';

/// Manages the currently selected Pokémon type. `null` means "All".
///
/// WHY only a String: the filter is a single choice. The filtered list is
/// NOT stored here; it is derived in [filteredPokemonProvider], so it can
/// never get out of sync with the real list.
class TypeFilterNotifier extends Notifier<String?> {
  /// No filter at start → show every Pokémon.
  @override
  String? build() => null;

  /// Shows only Pokémon of [type] (e.g. "fire"). Called by a type chip.
  void selectType(String type) => state = type;

  /// Removes the filter. Called by the "All" chip, the (x) button and the
  /// "Clear filter" button.
  void clearFilter() => state = null;
}

final typeFilterProvider = NotifierProvider<TypeFilterNotifier, String?>(
  TypeFilterNotifier.new,
);

/// DERIVED: sorted, distinct types found in the loaded Pokémon.
/// Nothing is hardcoded — if the API returns new types, chips appear for them.
final availableTypesProvider = Provider<List<String>>((ref) {
  final allPokemon = ref.watch(pokemonListProvider).value ?? const <Pokemon>[];
  final types = {
    for (final pokemon in allPokemon) ...pokemon.types,
  }; // a Set removes duplicates
  return types.toList()..sort();
});

/// DERIVED: the list the home page shows = loaded list + selected type.
///
/// It returns an AsyncValue so the home page still gets loading / error
/// from the original list. `whenData` filters only the data case.
final filteredPokemonProvider = Provider<AsyncValue<List<Pokemon>>>((ref) {
  final pokemonAsync = ref.watch(pokemonListProvider);
  final selectedType = ref.watch(typeFilterProvider);

  if (selectedType == null) return pokemonAsync;

  return pokemonAsync.whenData(
    (pokemon) => pokemon.where((p) => p.types.contains(selectedType)).toList(),
  );
});
