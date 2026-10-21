// theme/pokemon_type_style.dart
// Colours and labels for Pokémon types.
// This is ONLY a colour lookup: the list of types shown in the filter
// always comes from the loaded data (see availableTypesProvider).
// Unknown types simply fall back to grey.

import 'package:flutter/material.dart';

const Map<String, Color> _typeColors = {
  'normal': Color(0xFFA8A77A),
  'fire': Color(0xFFEE8130),
  'water': Color(0xFF6390F0),
  'electric': Color(0xFFF7D02C),
  'grass': Color(0xFF7AC74C),
  'ice': Color(0xFF96D9D6),
  'fighting': Color(0xFFC22E28),
  'poison': Color(0xFFA33EA1),
  'ground': Color(0xFFE2BF65),
  'flying': Color(0xFFA98FF3),
  'psychic': Color(0xFFF95587),
  'bug': Color(0xFFA6B91A),
  'rock': Color(0xFFB6A136),
  'ghost': Color(0xFF735797),
  'dragon': Color(0xFF6F35FC),
  'dark': Color(0xFF705746),
  'steel': Color(0xFFB7B7CE),
  'fairy': Color(0xFFD685AD),
};

/// The colour used for a type chip/pill.
Color typeColor(String type) => _typeColors[type] ?? Colors.grey;

/// "grass" → "Grass".
String typeLabel(String type) =>
    type.isEmpty ? type : type[0].toUpperCase() + type.substring(1);

/// A small coloured pill showing one type, used on cards and the detail page.
class TypePill extends StatelessWidget {
  final String type;
  final double fontSize;

  const TypePill({super.key, required this.type, this.fontSize = 10});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.8,
        vertical: fontSize * 0.25,
      ),
      decoration: BoxDecoration(
        color: typeColor(type),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        typeLabel(type),
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
