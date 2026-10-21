// widgets/pokemon_card.dart
// A reusable card widget that displays a single Pokémon's
// official artwork, formatted ID (#001, #025 …), name, and types,
// plus a heart in the top-right corner to toggle it as a favorite.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/favorites_provider.dart';
import '../screens/pokemon_detail_page.dart';
import '../theme/pokemon_type_style.dart';
import 'favorite_heart_button.dart';

/// Displays one Pokémon. Tap → detail page. Heart → toggle favorite.
class PokemonCard extends ConsumerWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // SELECTIVE REBUILD: select() makes this card watch only a bool —
    // "is MY id in the favorites set?". Favoriting another Pokémon changes
    // the set, but this bool stays the same, so this card does NOT rebuild.
    final isFavorite = ref.watch(
      favoritesProvider.select((ids) => ids.contains(pokemon.id)),
    );

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // Light cream/white background keeps the card clean against artwork.
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => PokemonDetailPage(pokemon: pokemon),
          ),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: _CardBody(pokemon: pokemon),
            ),
            // ── Favorite indicator (top-right corner) ────────────────
            Positioned(
              top: 0,
              right: 0,
              child: FavoriteHeartButton(
                isFavorite: isFavorite,
                onPressed: () =>
                    toggleFavoriteWithFeedback(context, ref, pokemon),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Artwork, ID, name and type pills.
class _CardBody extends StatelessWidget {
  final Pokemon pokemon;

  const _CardBody({required this.pokemon});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ── Pokémon artwork ──────────────────────────────────────────
        Expanded(
          child: Hero(
            tag: 'pokemon-image-${pokemon.id}',
            child: PokemonImage(url: pokemon.imageUrl),
          ),
        ),

        const SizedBox(height: 8),

        // ── ID badge ─────────────────────────────────────────────────
        Text(
          pokemon.formattedId,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.red.shade400,
            letterSpacing: 1.2,
          ),
        ),

        const SizedBox(height: 2),

        // ── Name ─────────────────────────────────────────────────────
        Text(
          pokemon.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 6),

        // ── Types ────────────────────────────────────────────────────
        Wrap(
          spacing: 4,
          alignment: WrapAlignment.center,
          children: [for (final type in pokemon.types) TypePill(type: type)],
        ),
      ],
    );
  }
}

/// Network artwork with a small spinner while loading and a fallback icon.
class PokemonImage extends StatelessWidget {
  final String url;

  const PokemonImage({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      fit: BoxFit.contain,
      // Show a tiny spinner while the image loads.
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      },
      // Fallback icon if the image URL fails.
      errorBuilder: (context, error, stackTrace) => const Icon(
        Icons.image_not_supported_outlined,
        size: 48,
        color: Colors.grey,
      ),
    );
  }
}
