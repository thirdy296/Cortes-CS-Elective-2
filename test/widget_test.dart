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

  testWidgets('favorites: heart on card + detail, panel on both screens',
      (tester) async {
    await tester.pumpWidget(buildApp(FakePokemonService()));
    await tester.pumpAndSettle();

    // Open the panel → empty message.
    await tester.tap(find.byTooltip('Show favorites'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No favorite Pokémon yet'), findsOneWidget);

    // Heart on the Charmander card → panel updates instantly.
    final charmanderCard = find.ancestor(
      of: find.text('Charmander'),
      matching: find.byType(Card),
    );
    await tester.tap(find.descendant(
      of: charmanderCard,
      matching: find.byIcon(Icons.favorite_border),
    ));
    await tester.pumpAndSettle();
    expect(find.textContaining('No favorite Pokémon yet'), findsNothing);
    expect(find.text('Favorites (1)'), findsOneWidget);
    expect(
      find.descendant(of: charmanderCard, matching: find.byIcon(Icons.favorite)),
      findsOneWidget,
    );

    // Open detail → panel is still open there and shows the favorite.
    // (The name is also shown in the panel now, so tap the card itself.)
    await tester.tap(charmanderCard);
    await tester.pumpAndSettle();
    expect(find.text('#004'), findsOneWidget);
    expect(find.text('Favorites (1)'), findsOneWidget);

    // Un-favorite from the detail page → panel empty again.
    await tester.tap(find.text('Remove from favorites'));
    await tester.pumpAndSettle();
    expect(find.text('Favorites (0)'), findsOneWidget);

    // Close the panel on the detail screen, go back: closed on home too.
    await tester.tap(find.byTooltip('Hide favorites'));
    await tester.pumpAndSettle();
    expect(find.text('Favorites (0)'), findsNothing);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Favorites (0)'), findsNothing);
    expect(find.byTooltip('Show favorites'), findsOneWidget);
  });

  testWidgets('nicknames: set, edit, remove; original name stays visible',
      (tester) async {
    await tester.pumpWidget(buildApp(FakePokemonService()));
    await tester.pumpAndSettle();

    final squirtleCard = find.ancestor(
      of: find.text('Squirtle'),
      matching: find.byType(Card),
    );

    // Set from the card's edit icon. "Remove nickname" starts disabled.
    await tester.tap(find.descendant(
      of: squirtleCard,
      matching: find.byTooltip('Edit nickname'),
    ));
    await tester.pumpAndSettle();
    final removeButton = find.widgetWithText(TextButton, 'Remove nickname');
    expect(tester.widget<TextButton>(removeButton).onPressed, isNull);
    await tester.enterText(find.byType(TextField), '  Shelly  ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(find.text('Shelly'), findsOneWidget); // trimmed
    expect(find.text('(Squirtle)'), findsOneWidget);

    // Detail shows it too; edit it there (field is prefilled).
    await tester.tap(find.text('Shelly'));
    await tester.pumpAndSettle();
    expect(find.text('Shelly'), findsOneWidget);
    expect(find.text('(Squirtle)'), findsOneWidget);
    await tester.tap(find.text('Edit nickname').last);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Shelly'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Captain');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Captain'), findsOneWidget);

    // Back on home the card updated too. Remove it via the dialog.
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Captain'), findsOneWidget);
    await tester.longPress(find.text('Captain'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove nickname'));
    await tester.pumpAndSettle();
    expect(find.text('Captain'), findsNothing);
    expect(find.text('Squirtle'), findsOneWidget);
    expect(find.text('(Squirtle)'), findsNothing);

    // Whitespace-only save does not create a nickname.
    await tester.longPress(find.text('Squirtle'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('(Squirtle)'), findsNothing);
  });
}
