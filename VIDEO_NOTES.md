# Video Notes — Pokédex Midterm (Riverpod)

## 1. Architecture: who owns what
| Provider (file) | Type | Owns |
|---|---|---|
| `pokemonListProvider` (`pokemon_list_provider.dart`) | `AsyncNotifier<List<Pokemon>>` | The API list: loading / error / data |
| `nicknameProvider` (`nickname_provider.dart`) | `Notifier<Map<int, String>>` | id → nickname |
| `favoritesProvider` (`favorites_provider.dart`) | `Notifier<Set<int>>` | Favorite ids |
| `typeFilterProvider` (`type_filter_provider.dart`) | `Notifier<String?>` | Selected type (`null` = All) |
| `favoritesPanelProvider` (`favorites_panel_provider.dart`) | `Notifier<bool>` | Panel open/closed |

**Derived providers** (plain `Provider`, they store nothing and re-run when an input changes):
- `filteredPokemonProvider` = list + selected type → `AsyncValue<List<Pokemon>>` (uses `whenData`, so loading/error pass through). The home page shows this.
- `favoritePokemonProvider` = list + favorite ids → the favorite `Pokemon` objects for the panel.
- `availableTypesProvider` = list → sorted, distinct types for the chips (nothing hardcoded).

Flow: widget calls `ref.read(x.notifier).method()` → notifier assigns a **new** `state` → every widget that `ref.watch`es it (or a derived provider) rebuilds.

## 2. Why state management matters
Without it, state lives inside one widget and must be passed down via constructors and callbacks. Every screen that needs it adds more plumbing, and copies drift out of sync. Here the same favorites and nicknames are used by **cards, the detail page, the favorites panel and the AppBar badge**. With Riverpod each reads one source of truth: favorite on the detail page and the card heart, badge and panel update instantly, with no callbacks passed around. `select()` makes each card rebuild only when **its own** favorite flag or nickname changes.

## 3. Why Riverpod over BLoC here
- **Compile-safe, global providers:** no `BuildContext` lookup, no "provider not found" runtime errors.
- **`AsyncValue`:** loading / error / data for free; `AsyncValue.guard` replaces try/catch.
- **Less boilerplate:** a method like `toggleFavorite()` instead of an Event class + State class + `on<Event>` handler.
- **Derived state is one line:** `ref.watch` two providers inside a `Provider`.
- **Successor to Provider:** same author, same ideas, so it is a natural upgrade path.

## 4. Where each requirement lives
| Requirement | File → method |
|---|---|
| List + fetch | `pokemon_list_provider.dart` → `build()`, `fetch()` (`AsyncLoading` + `AsyncValue.guard`) |
| Types via `Future.wait` | `services/pokemon_service.dart` → `fetchPokemon()`, `_withTypes()` |
| loading/error/data + Try again | `screens/home_page.dart` → `_PokemonListView.build` (`.when`) |
| Pull-to-refresh + AppBar refresh | `home_page.dart` → `RefreshIndicator.onRefresh`, Refresh `IconButton` → `fetch()` |
| Nicknames | `nickname_provider.dart` → `setNickname()`, `removeNickname()`; UI `widgets/nickname_editor_dialog.dart` |
| Nickname + original name | `widgets/pokemon_name_label.dart` (card, detail); panel tile |
| Favorites | `favorites_provider.dart` → `toggleFavorite()`, `isFavorite()`, `removeFavorite()`, `favoritePokemonProvider` |
| Favorites panel | `widgets/favorites_panel.dart`; open state `favorites_panel_provider.dart` → `toggle()`, `close()` |
| Shared AppBar + panel | `widgets/pokedex_app_bar.dart` → `PokedexScaffold`, `FavoritesBadgeButton` |
| Heart indicator + select | `widgets/pokemon_card.dart` (`favoritesProvider.select`), `widgets/favorite_heart_button.dart` |
| Type filter | `type_filter_provider.dart` → `selectType()`, `clearFilter()`, `availableTypesProvider`, `filteredPokemonProvider`; UI `widgets/type_filter_bar.dart` |
