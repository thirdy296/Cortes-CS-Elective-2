// services/pokemon_service.dart
// Responsible for all network communication with the PokéAPI.
// Returns a Future<List<Pokemon>> — a one-shot async result,
// which is why Future is the right choice here (not Stream).
//
// It makes 1 list request, then loads every Pokémon's details concurrently
// with Future.wait so each Pokémon gets its real `types`.
// Every failure is converted into a [PokemonApiException] with a readable
// message, so the UI never has to show a raw stack trace.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/pokemon.dart';

/// An error with a message that is safe to show to the user.
class PokemonApiException implements Exception {
  final String message;

  const PokemonApiException(this.message);

  @override
  String toString() => message;
}

/// Turns any error into text that is safe to show in the UI.
/// Unknown errors get a generic message instead of a stack trace.
String userMessageFor(Object error) => error is PokemonApiException
    ? error.message
    : 'Something went wrong while loading Pokémon.';

/// Fetches the first 30 Pokémon (with their types) from the PokéAPI.
class PokemonService {
  static const _baseUrl = 'https://pokeapi.co/api/v2';
  static const _listUrl = '$_baseUrl/pokemon?limit=30';
  static const _timeout = Duration(seconds: 10);

  /// Returns 30 Pokémon, each with its `types` filled in.
  ///
  /// Throws a [PokemonApiException] if the list itself cannot be loaded
  /// (no internet, timeout, non-200 status, or bad JSON).
  Future<List<Pokemon>> fetchPokemon() async {
    // One client for all 31 requests so connections are reused.
    final client = http.Client();
    try {
      final body = await _getJson(client, Uri.parse(_listUrl));

      // The list is under the "results" key.
      final results = body['results'] as List<dynamic>;
      final basicPokemon = results
          .map((e) => Pokemon.fromJson(e as Map<String, dynamic>))
          .toList();

      // Load all details at the same time (concurrently), not one by one.
      return await Future.wait(
        basicPokemon.map((pokemon) => _withTypes(client, pokemon)),
      );
    } on PokemonApiException {
      rethrow;
    } on TimeoutException {
      throw const PokemonApiException(
        'The PokéAPI took too long to respond. Please try again.',
      );
    } on http.ClientException {
      throw const PokemonApiException(
        'No internet connection. Check your network and try again.',
      );
    } on FormatException {
      throw const PokemonApiException(
        'The PokéAPI sent data we could not read.',
      );
    } on TypeError {
      // A JSON field had an unexpected type (e.g. "results" was missing).
      throw const PokemonApiException(
        'The PokéAPI sent data in an unexpected format.',
      );
    } catch (_) {
      throw const PokemonApiException(
        'Something went wrong while loading Pokémon.',
      );
    } finally {
      client.close();
    }
  }

  /// Loads /pokemon/{id} and returns [pokemon] with its types attached.
  ///
  /// Fails gracefully: if this one detail call fails, the Pokémon is still
  /// returned (with no types) so a single bad request can't break the list.
  Future<Pokemon> _withTypes(http.Client client, Pokemon pokemon) async {
    try {
      final json = await _getJson(
        client,
        Uri.parse('$_baseUrl/pokemon/${pokemon.id}'),
      );
      return pokemon.copyWith(types: Pokemon.typesFromDetailJson(json));
    } catch (e) {
      debugPrint('Could not load types for ${pokemon.name}: $e');
      return pokemon;
    }
  }

  /// GETs [uri] with a timeout and decodes the JSON object body.
  /// Throws [PokemonApiException] for any non-200 status code.
  Future<Map<String, dynamic>> _getJson(http.Client client, Uri uri) async {
    final response = await client.get(uri).timeout(_timeout);

    if (response.statusCode != 200) {
      throw PokemonApiException(
        'The PokéAPI returned an error (status ${response.statusCode}).',
      );
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
