// widgets/favorites_panel.dart
// The retractable favorites panel shown under the AppBar on every screen.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/favorites_panel_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/nickname_provider.dart';

/// Expands/collapses with AnimatedSize based on [favoritesPanelProvider].
class FavoritesPanel extends ConsumerWidget {
  const FavoritesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOpen = ref.watch(favoritesPanelProvider);

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: isOpen
          ? const _FavoritesPanelContent()
          : const SizedBox(width: double.infinity),
    );
  }
}

/// The panel body. Watches the DERIVED [favoritePokemonProvider], so it
/// updates instantly whenever a favorite is added or removed anywhere.
class _FavoritesPanelContent extends ConsumerWidget {
  const _FavoritesPanelContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritePokemonProvider);

    return Material(
      color: Colors.red.shade50,
      elevation: 2,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 240),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 4, 0),
              child: Row(
                children: [
                  Text(
                    'Favorites (${favorites.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Close favorites',
                    icon: const Icon(Icons.expand_less),
                    onPressed: () =>
                        ref.read(favoritesPanelProvider.notifier).close(),
                  ),
                ],
              ),
            ),
            // ── Empty message or list ────────────────────────────────
            if (favorites.isEmpty)
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  'No favorite Pokémon yet — tap the ♡ on a card to add one.',
                  style: TextStyle(color: Colors.black54),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) =>
                      _FavoriteTile(pokemon: favorites[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One favorite: sprite, nickname (or name), and a remove button.
class _FavoriteTile extends ConsumerWidget {
  final Pokemon pokemon;

  const _FavoriteTile({required this.pokemon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nickname = ref.watch(
      nicknameProvider.select((nicknames) => nicknames[pokemon.id]),
    );

    return ListTile(
      dense: true,
      leading: Image.network(
        pokemon.imageUrl,
        width: 40,
        height: 40,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.catching_pokemon, color: Colors.grey),
      ),
      title: Text(
        nickname ?? pokemon.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      // Original name stays visible under the nickname.
      subtitle: nickname == null ? null : Text('(${pokemon.name})'),
      trailing: IconButton(
        tooltip: 'Remove ${pokemon.name} from favorites',
        icon: const Icon(Icons.close),
        onPressed: () =>
            ref.read(favoritesProvider.notifier).removeFavorite(pokemon.id),
      ),
    );
  }
}
