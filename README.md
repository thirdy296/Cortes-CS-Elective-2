# Pokédex — CS Elective 2: Midterm Exam (Riverpod)

A Flutter Pokédex that loads the first 30 Pokémon from the
[PokéAPI](https://pokeapi.co/) and manages all app state with
**Riverpod** (`flutter_riverpod`, hand-written `Notifier` / `AsyncNotifier`,
no code generation).

See **[VIDEO_NOTES.md](VIDEO_NOTES.md)** for the architecture walkthrough.

---

## Features

- Fetches 30 Pokémon from `https://pokeapi.co/api/v2/pokemon?limit=30`, then
  each Pokémon's details (`/pokemon/{id}`) concurrently with `Future.wait` for its types
- Loading spinner, readable error message with **Try again**, empty state
- Pull-to-refresh and an AppBar refresh button (both call `fetch()`)
- **Nicknames**: set / edit / remove; the original name stays visible
- **Favorites**: heart on every card and on the detail page, plus a retractable
  favorites panel (with count badge) on every screen
- **Type filter**: coloured chips built from the loaded data

---

## Folder Structure

```
lib/
  main.dart                       → ProviderScope + MaterialApp
  models/pokemon.dart             → Pokemon (id, name, imageUrl, types)
  services/pokemon_service.dart   → PokéAPI calls + readable errors
  providers/
    pokemon_list_provider.dart    → PokemonListNotifier (AsyncNotifier)
    nickname_provider.dart        → NicknameNotifier
    favorites_provider.dart       → FavoritesNotifier + favoritePokemonProvider
    type_filter_provider.dart     → TypeFilterNotifier + derived providers
    favorites_panel_provider.dart → FavoritesPanelNotifier
  screens/
    home_page.dart                → grid, filter bar, refresh
    pokemon_detail_page.dart      → detail, favorite, nickname
  theme/pokemon_type_style.dart   → type colours + TypePill
  widgets/                        → card, panel, AppBar, dialog, filter bar, ...
test/widget_test.dart             → widget tests with a fake service
```

---

## Getting Started

```bash
flutter pub get
flutter test
flutter run
```
