// widgets/favorite_heart_button.dart
// The heart icon used on cards, plus a shared helper that toggles a
// favorite and shows a short SnackBar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/favorites_provider.dart';

/// A plain heart icon button: filled red when [isFavorite], outlined if not.
/// It holds no state itself; the parent watches the provider and passes in
/// [isFavorite], which keeps this widget simple and reusable.
class FavoriteHeartButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onPressed;

  const FavoriteHeartButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : Colors.grey,
      ),
    );
  }
}

/// Calls the notifier's [FavoritesNotifier.toggleFavorite], then shows
/// "Added to / Removed from favorites". The state change lives in the
/// notifier; this function only adds the UI feedback.
void toggleFavoriteWithFeedback(
  BuildContext context,
  WidgetRef ref,
  Pokemon pokemon,
) {
  final favorites = ref.read(favoritesProvider.notifier);
  favorites.toggleFavorite(pokemon.id);

  final added = favorites.isFavorite(pokemon.id);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          added
              ? 'Added ${pokemon.name} to favorites'
              : 'Removed ${pokemon.name} from favorites',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
}
