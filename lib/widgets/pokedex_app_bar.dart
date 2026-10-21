// widgets/pokedex_app_bar.dart
// The shared AppBar (with the favorites badge button) and PokedexScaffold,
// which places the favorites panel right under the AppBar.
// Every screen uses PokedexScaffold, so the AppBar + panel are not duplicated.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/favorites_panel_provider.dart';
import '../providers/favorites_provider.dart';
import 'favorites_panel.dart';

/// A Scaffold with [PokedexAppBar] and the [FavoritesPanel] above [body].
class PokedexScaffold extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final Widget body;

  const PokedexScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PokedexAppBar(title: title, actions: actions),
      body: Column(
        children: [
          const FavoritesPanel(),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// Pokédex-style red AppBar. Screen-specific [actions] come first,
/// followed by the favorites button that every screen shares.
class PokedexAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;

  const PokedexAppBar({super.key, required this.title, this.actions = const []});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          letterSpacing: 1,
        ),
      ),
      centerTitle: true,
      elevation: 4,
      actions: [...actions, const FavoritesBadgeButton()],
    );
  }
}

/// Heart button with a count badge that opens/closes the favorites panel.
class FavoritesBadgeButton extends ConsumerWidget {
  const FavoritesBadgeButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // select(): rebuild only when the NUMBER of favorites changes.
    final count = ref.watch(favoritesProvider.select((ids) => ids.length));
    final isOpen = ref.watch(favoritesPanelProvider);

    return IconButton(
      tooltip: isOpen ? 'Hide favorites' : 'Show favorites',
      onPressed: () => ref.read(favoritesPanelProvider.notifier).toggle(),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        backgroundColor: Colors.white,
        textColor: Colors.red,
        child: Icon(isOpen ? Icons.favorite : Icons.favorite_border),
      ),
    );
  }
}
