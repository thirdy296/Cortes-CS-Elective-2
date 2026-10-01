// models/pokemon.dart
// Defines the Pokemon data model used throughout the app.
// The factory constructor parses the JSON returned by PokeAPI,
// extracts the ID from the URL, and builds the official-artwork image URL.

class Pokemon {
  final int id;
  final String name;
  final String imageUrl;

  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  /// Parses one entry from the PokeAPI list response.
  /// The list endpoint only gives us "name" and "url", so we extract
  /// the numeric ID from the URL instead of making an extra per-Pokémon call.
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    // URL format: https://pokeapi.co/api/v2/pokemon/25/
    final url = json['url'] as String;
    // Split on '/' and grab the second-to-last non-empty segment → the ID.
    final segments = url.split('/').where((s) => s.isNotEmpty).toList();
    final id = int.parse(segments.last);

    // Official artwork sprite hosted on GitHub by the PokeAPI project.
    final imageUrl =
        'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png';

    // Capitalise the first letter of the name (e.g. "bulbasaur" → "Bulbasaur").
    final rawName = json['name'] as String;
    final name =
        rawName[0].toUpperCase() + rawName.substring(1);

    return Pokemon(id: id, name: name, imageUrl: imageUrl);
  }
}
