// screens/home_page.dart
// The main screen of the Pokédex app.
// It is a ConsumerWidget: it has NO setState and NO fetching logic.
// It only:
//   1. ref.watch()es the list provider and renders loading / error / data
//      with AsyncValue.when.
//   2. calls ref.read(pokemonListProvider.notifier).fetch() for
//      "Try again", pull-to-refresh, and the AppBar refresh button.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/pokemon_list_provider.dart';
import '../services/pokemon_service.dart';
import '../widgets/pokedex_app_bar.dart';
import '../widgets/pokemon_card.dart';
import '../widgets/state_views.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PokedexScaffold(
      title: 'Pokédex',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          icon: const Icon(Icons.refresh),
          // Same existing method as pull-to-refresh — no extra refresh().
          onPressed: () => ref.read(pokemonListProvider.notifier).fetch(),
        ),
      ],
      body: const _PokemonListView(),
    );
  }
}

/// Renders the three async states of the Pokémon list.
class _PokemonListView extends ConsumerWidget {
  const _PokemonListView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemonAsync = ref.watch(pokemonListProvider);

    return pokemonAsync.when(
      // Show the spinner for EVERY fetch (also refreshes), so the user always
      // sees that fetch() is running.
      skipLoadingOnRefresh: false,
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        message: userMessageFor(error),
        onRetry: () => ref.read(pokemonListProvider.notifier).fetch(),
      ),
      data: (pokemon) {
        if (pokemon.isEmpty) return const EmptyView();
        return RefreshIndicator(
          // Must return the Future so the indicator spins until it finishes.
          onRefresh: () => ref.read(pokemonListProvider.notifier).fetch(),
          child: _PokemonGrid(pokemon: pokemon),
        );
      },
    );
  }
}

/// Responsive grid: 2 columns on phones, more on wider screens.
class _PokemonGrid extends StatelessWidget {
  final List<Pokemon> pokemon;

  const _PokemonGrid({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = (width / 180).floor().clamp(2, 6);

    return GridView.builder(
      // Always scrollable so pull-to-refresh works even with few items.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: pokemon.length,
      itemBuilder: (context, index) => PokemonCard(pokemon: pokemon[index]),
    );
  }
}
