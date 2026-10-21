// main.dart
// Entry point for the Pokédex app (CS Elective 2 – Midterm Exam).
// ProviderScope stores the state of every Riverpod provider, so it must
// wrap the whole app. Then MaterialApp launches HomePage.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/home_page.dart';

void main() {
  runApp(const ProviderScope(child: PokedexApp()));
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
      home: const HomePage(),
    );
  }
}
