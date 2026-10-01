// test/widget_test.dart
// Basic smoke test for the Pokédex app.
// We only verify that the app starts and the AppBar title is visible,
// since actual data fetching requires a live network connection.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_browser/main.dart';

void main() {
  testWidgets('Pokédex app smoke test – AppBar title visible',
      (WidgetTester tester) async {
    await tester.pumpWidget(const PokedexApp());

    // The AppBar should always show "Pokédex" regardless of network state.
    expect(find.text('Pokédex'), findsOneWidget);

    // The loading indicator should appear while the future is pending.
    expect(find.byType(CircularProgressIndicator), findsWidgets);
  });
}
