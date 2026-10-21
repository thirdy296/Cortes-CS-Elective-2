// widgets/pokemon_card.dart
// A reusable card widget that displays a single Pokémon's
// official artwork, formatted ID (#001, #025 …), name, and types.

import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../theme/pokemon_type_style.dart';

/// Displays one Pokémon in a rounded card with image, ID, and name.
class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCard({super.key, required this.pokemon});

  @override
  Widget build(BuildContext context) {
    // Format the ID as a zero-padded 3-digit string (e.g. 001, 025).
    final formattedId = '#${pokemon.id.toString().padLeft(3, '0')}';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      // Light cream/white background keeps the card clean against artwork.
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Pokémon artwork ──────────────────────────────────────
            Expanded(
              child: Image.network(
                pokemon.imageUrl,
                fit: BoxFit.contain,
                // Show a tiny spinner while the image loads.
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                },
                // Fallback icon if the image URL fails.
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.image_not_supported_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // ── ID badge ─────────────────────────────────────────────
            Text(
              formattedId,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade400,
                letterSpacing: 1.2,
              ),
            ),

            const SizedBox(height: 2),

            // ── Name ─────────────────────────────────────────────────
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

            // ── Types ─────────────────────────────────────────────────────
            Wrap(
              spacing: 4,
              alignment: WrapAlignment.center,
              children: [
                for (final type in pokemon.types) TypePill(type: type),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
