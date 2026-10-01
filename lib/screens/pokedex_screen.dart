// screens/pokedex_screen.dart
// The main screen of the Pokédex app.
// It is a StatefulWidget that:
//   1. Stores the Future in initState (not build) so it doesn't re-fetch
//      on every rebuild.
//   2. Uses FutureBuilder to handle loading / error / empty / data states.
//   3. Lays out results in a responsive GridView (2 columns on phones,
//      more on wider screens).

import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/state_views.dart';

/// Stateful screen that owns the Pokémon data future.
class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key});

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  // The service used to contact the PokéAPI.
  final PokemonService _service = PokemonService();

  // The Future is stored in a field so it persists across rebuilds.
  // Assigning a new Future inside setState triggers FutureBuilder to restart.
  late Future<List<Pokemon>> _pokemonFuture;

  @override
  void initState() {
    super.initState();
    // Kick off the initial fetch as soon as the widget is inserted.
    _pokemonFuture = _service.fetchPokemon();
  }

  /// Called when the user taps "Retry" in the error view.
  /// Replaces the existing Future so FutureBuilder rebuilds from scratch.
  void _retry() {
    setState(() {
      _pokemonFuture = _service.fetchPokemon();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Pokédex-style red AppBar with white text.
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: const Text(
          'Pokédex',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 1,
          ),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      // FutureBuilder handles all async states declaratively.
      body: FutureBuilder<List<Pokemon>>(
        future: _pokemonFuture,
        builder: (context, snapshot) {
          // ── Loading ──────────────────────────────────────────────
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView();
          }

          // ── Error ────────────────────────────────────────────────
          if (snapshot.hasError) {
            return ErrorView(
              message: snapshot.error.toString(),
              onRetry: _retry,
            );
          }

          // ── Empty list ───────────────────────────────────────────
          final pokemon = snapshot.data ?? [];
          if (pokemon.isEmpty) {
            return const EmptyView();
          }

          // ── Data: responsive grid ────────────────────────────────
          // Use screen width to determine column count:
          // phones get 2 columns, tablets / landscape get more.
          final width = MediaQuery.of(context).size.width;
          final crossAxisCount = (width / 180).floor().clamp(2, 6);

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              // Square-ish aspect ratio to fit image + text.
              childAspectRatio: 0.75,
            ),
            itemCount: pokemon.length,
            itemBuilder: (context, index) =>
                PokemonCard(pokemon: pokemon[index]),
          );
        },
      ),
    );
  }
}
