# Pokédex List — CS Elective 2: Dart Async Activity

A Flutter app that fetches and displays the first 30 Pokémon from the
[PokéAPI](https://pokeapi.co/) using Dart's `Future` and `FutureBuilder`.

---

## Features

- Fetches 30 Pokémon from `https://pokeapi.co/api/v2/pokemon?limit=30`
- Displays them in a responsive 2-column grid (more columns on wider screens)
- Each card shows the official artwork, zero-padded ID (`#001`, `#025` …), and name
- Three explicit UI states: **Loading**, **Error** (with a Retry button), and **Empty**
- Uses `Image.network` with an inline loading spinner and a fallback icon

---

## Folder Structure

```
lib/
  main.dart                     → App entry point, MaterialApp setup
  models/
    pokemon.dart                → Pokemon class with factory fromJson
  services/
    pokemon_service.dart        → PokemonService.fetchPokemon() — HTTP + timeout
  widgets/
    pokemon_card.dart           → Reusable card widget (image, ID, name)
    state_views.dart            → LoadingView, ErrorView, EmptyView
  screens/
    pokedex_screen.dart         → StatefulWidget + FutureBuilder grid
```

---

## Why Future and not Stream?

A **`Future`** is the right choice here because fetching the Pokémon list is a
**one-time HTTP request** that produces a **single result exactly once** — either
a successful list or an error.

A **`Stream`** is designed for data that arrives **over time in multiple
values** — for example live sensor readings, WebSocket messages, or a
real-time database feed. This activity does none of that: we fire one `GET`
request, wait for the response, parse it, and we are done.

Using a `Stream` where a `Future` suffices would add unnecessary complexity
(managing subscriptions, handling pauses/cancellations) with no benefit.
`FutureBuilder` maps perfectly onto the three states we need to handle:
`ConnectionState.waiting` → loading, `hasError` → error, and `hasData` → grid.

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## Resources

- [Flutter documentation](https://docs.flutter.dev/)
- [PokéAPI](https://pokeapi.co/)
- [Dart async / await](https://dart.dev/codelabs/async-await)
