// test/widget_test.dart
// Widget tests for the Pokédex app.
// The real PokemonService is replaced with a fake through Riverpod's
// `overrideWithValue`, so the tests run without a network connection.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_browser/main.dart';
import 'package:shop_browser/models/pokemon.dart';
import 'package:shop_browser/providers/pokemon_list_provider.dart';
import 'package:shop_browser/services/pokemon_service.dart';

/// Returns fixed data, or throws while [shouldFail] is true.
class FakePokemonService implements PokemonService {
  bool shouldFail;
  int calls = 0;

  FakePokemonService({this.shouldFail = false});

  @override
  Future<List<Pokemon>> fetchPokemon() async {
    calls++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    if (shouldFail) {
      throw const PokemonApiException('No internet connection.');
    }
    return const [
      Pokemon(id: 1, name: 'Bulbasaur', imageUrl: '', types: ['grass', 'poison']),
      Pokemon(id: 4, name: 'Charmander', imageUrl: '', types: ['fire']),
      Pokemon(id: 7, name: 'Squirtle', imageUrl: '', types: ['water']),
    ];
  }
}

Widget buildApp(FakePokemonService service) => ProviderScope(
      overrides: [pokemonServiceProvider.overrideWithValue(service)],
      child: const PokedexApp(),
    );

void main() {
  testWidgets('initial load shows a spinner, then the list', (tester) async {
    await tester.pumpWidget(buildApp(FakePokemonService()));

    expect(find.text('Pokédex'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    await tester.pumpAndSettle();
    expect(find.text('Bulbasaur'), findsOneWidget);
    expect(find.text('Charmander'), findsOneWidget);
  });

  testWidgets('error shows a message and Try again re-runs fetch()',
      (tester) async {
    final service = FakePokemonService(shouldFail: true);
    await tester.pumpWidget(buildApp(service));
    await tester.pumpAndSettle();

    expect(find.text('No internet connection.'), findsOneWidget);
    expect(service.calls, 1); // retry is disabled → exactly one attempt

    service.shouldFail = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(service.calls, 2);
    expect(find.text('Bulbasaur'), findsOneWidget);
  });

  testWidgets('AppBar refresh and pull-to-refresh both call fetch()',
      (tester) async {
    final service = FakePokemonService();
    await tester.pumpWidget(buildApp(service));
    await tester.pumpAndSettle();
    expect(service.calls, 1);

    await tester.tap(find.byTooltip('Refresh'));
    await tester.pumpAndSettle();
    expect(service.calls, 2);

    await tester.fling(find.text('Bulbasaur'), const Offset(0, 400), 1000);
    await tester.pumpAndSettle();
    expect(service.calls, 3);
  });
}
