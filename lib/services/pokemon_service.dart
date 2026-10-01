// services/pokemon_service.dart
// Responsible for all network communication with the PokéAPI.
// Returns a Future<List<Pokemon>> — a one-shot async result,
// which is why Future is the right choice here (not Stream).

import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

/// Fetches the first 30 Pokémon from the PokéAPI list endpoint.
class PokemonService {
  static const _baseUrl =
      'https://pokeapi.co/api/v2/pokemon?limit=30';

  /// Returns a list of 30 Pokémon parsed from the API response.
  ///
  /// Throws an [Exception] if the HTTP status code is not 200,
  /// or if the request times out after 10 seconds.
  Future<List<Pokemon>> fetchPokemon() async {
    try {
      final uri = Uri.parse(_baseUrl);

      // 10-second timeout to avoid hanging on slow networks.
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception(
          'Failed to load Pokémon. Status code: ${response.statusCode}',
        );
      }

      // Decode the JSON body.
      final Map<String, dynamic> body =
          jsonDecode(response.body) as Map<String, dynamic>;

      // The list is under the "results" key.
      final List<dynamic> results =
          body['results'] as List<dynamic>;

      // Map each JSON entry to a Pokemon model.
      return results
          .map((e) => Pokemon.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Re-throw so the FutureBuilder can catch it as an error state.
      rethrow;
    }
  }
}
