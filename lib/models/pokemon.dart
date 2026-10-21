// models/pokemon.dart
// Defines the Pokemon data model used throughout the app.
// The factory constructor parses the JSON returned by PokeAPI,
// extracts the ID from the URL, and builds the official-artwork image URL.
// Types come from a second call (/pokemon/{id}) and are attached with copyWith.

class Pokemon {
  final int id;
  final String name;
  final String imageUrl;

  /// Lower-case type names from PokéAPI, e.g. ['grass', 'poison'].
  /// Empty if the detail request for this Pokémon failed.
  final List<String> types;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.types = const [],
  });

  /// Parses one entry from the PokeAPI list response.
  /// The list endpoint only gives us "name" and "url", so we extract
  /// the numeric ID from the URL. Types are added later via [copyWith].
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    // URL format: https://pokeapi.co/api/v2/pokemon/25/
    final url = json['url'] as String;
    // Split on '/' and grab the last non-empty segment → the ID.
    final segments = url.split('/').where((s) => s.isNotEmpty).toList();
    final id = int.parse(segments.last);

    // Official artwork sprite hosted on GitHub by the PokeAPI project.
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    // Capitalise the first letter of the name (e.g. "bulbasaur" → "Bulbasaur").
    final rawName = json['name'] as String;
    final name = rawName[0].toUpperCase() + rawName.substring(1);

    return Pokemon(id: id, name: name, imageUrl: imageUrl);
  }

  /// Reads the type names from a /pokemon/{id} detail response.
  /// JSON shape: "types": [ { "slot": 1, "type": { "name": "grass" } }, ... ]
  static List<String> typesFromDetailJson(Map<String, dynamic> json) {
    final types = json['types'] as List<dynamic>;
    return types
        .map((t) => (t as Map<String, dynamic>)['type'] as Map<String, dynamic>)
        .map((type) => type['name'] as String)
        .toList();
  }

  /// Returns a copy with new [types]. The model stays immutable.
  Pokemon copyWith({List<String>? types}) {
    return Pokemon(
      id: id,
      name: name,
      imageUrl: imageUrl,
      types: types ?? this.types,
    );
  }
}
