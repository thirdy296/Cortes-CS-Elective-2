// screens/pokemon_detail_page.dart
// Detail screen for one Pokémon. Uses the SAME providers as the cards and
// the favorites panel, so a change here is instantly visible everywhere.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/favorites_provider.dart';
import '../theme/pokemon_type_style.dart';
import '../widgets/favorite_heart_button.dart';
import '../widgets/pokedex_app_bar.dart';
import '../widgets/pokemon_card.dart';

class PokemonDetailPage extends ConsumerWidget {
  final Pokemon pokemon;

  const PokemonDetailPage({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesProvider.select((ids) => ids.contains(pokemon.id)),
    );

    return PokedexScaffold(
      title: pokemon.formattedId,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                // ── Artwork (Hero animates it from the card) ──────────
                Hero(
                  tag: 'pokemon-image-${pokemon.id}',
                  child: SizedBox(
                    height: 240,
                    child: PokemonImage(url: pokemon.imageUrl),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Name ──────────────────────────────────────────────
                Text(
                  pokemon.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // ── Types ─────────────────────────────────────────────
                if (pokemon.types.isEmpty)
                  const Text(
                    'Type unknown',
                    style: TextStyle(color: Colors.grey),
                  )
                else
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final type in pokemon.types)
                        TypePill(type: type, fontSize: 14),
                    ],
                  ),
                const SizedBox(height: 24),

                // ── Actions ───────────────────────────────────────────
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () =>
                          toggleFavoriteWithFeedback(context, ref, pokemon),
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : null,
                      ),
                      label: Text(
                        isFavorite
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
