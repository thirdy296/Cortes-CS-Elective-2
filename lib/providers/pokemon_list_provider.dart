// providers/pokemon_list_provider.dart
// Owns the Pokémon list loaded from the PokéAPI.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';

/// Gives the app a single [PokemonService].
/// Being a provider means tests can swap it for a fake with `overrideWithValue`.
final pokemonServiceProvider = Provider<PokemonService>(
  (ref) => PokemonService(),
);

/// Manages the async Pokémon list: loading → data or error.
///
/// WHY an AsyncNotifier: the state is an `AsyncValue<List<Pokemon>>`, so the
/// loading / error / data cases come for free and the UI just calls `.when`.
class PokemonListNotifier extends AsyncNotifier<List<Pokemon>> {
  /// Runs once, the first time a widget watches [pokemonListProvider].
  ///
  /// The initial load goes through [fetch], so there is ONE code path for
  /// the first load, "Try again", pull-to-refresh and the AppBar refresh.
  /// `build` must return the list (or throw), so afterwards we hand back
  /// whatever [fetch] stored: the data, or the same error it caught.
  @override
  Future<List<Pokemon>> build() async {
    await fetch();
    if (state.hasError) {
      Error.throwWithStackTrace(state.error!, state.stackTrace!);
    }
    return state.requireValue;
  }

  /// Loads (or reloads) the Pokémon list from the API.
  ///
  /// 1. `state = AsyncLoading()` → the UI shows a spinner.
  /// 2. `AsyncValue.guard` runs the request and turns the result into
  ///    `AsyncData(list)` or, if it throws, `AsyncError(error)` — no try/catch.
  Future<void> fetch() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(pokemonServiceProvider).fetchPokemon(),
    );
  }
}

/// The global handle widgets use to read the list:
/// `ref.watch(pokemonListProvider)` for the state,
/// `ref.read(pokemonListProvider.notifier).fetch()` to reload.
final pokemonListProvider =
    AsyncNotifierProvider<PokemonListNotifier, List<Pokemon>>(
  PokemonListNotifier.new,
  // Riverpod 3 retries failed providers automatically. We turn that off so
  // the error screen appears and the user decides when to "Try again".
  retry: (retryCount, error) => null,
);
