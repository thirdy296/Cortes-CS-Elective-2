// main.dart
// Entry point for the Pokédex activity (CS Elective 2 – Dart Async Activity).
// Sets up the MaterialApp with Material 3 theming and launches PokedexScreen.

import 'package:flutter/material.dart';

import 'screens/pokedex_screen.dart';

void main() {
  runApp(const PokedexApp());
}

/// Root widget. Wraps the app in a MaterialApp with a red Pokédex theme.
class PokedexApp extends StatelessWidget {
  const PokedexApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokédex',
      debugShowCheckedModeBanner: false,
      // Material 3 colour scheme seeded from Pokédex red.
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        // Slightly off-white scaffold background for a softer look.
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const PokedexScreen(),
    );
  }
}
