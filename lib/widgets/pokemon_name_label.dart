// widgets/pokemon_name_label.dart
// Shows a Pokémon's nickname prominently with the original name underneath,
// e.g.  "Sparky"
//       "(Pikachu)"   ← smaller, grey
// Without a nickname it just shows the original name.

import 'package:flutter/material.dart';

class PokemonNameLabel extends StatelessWidget {
  final String name;
  final String? nickname;

  /// Font size of the main line; the original-name line is smaller.
  final double fontSize;

  const PokemonNameLabel({
    super.key,
    required this.name,
    required this.nickname,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    final mainStyle = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: Colors.black87,
    );
    final nickname = this.nickname;

    if (nickname == null) {
      return Text(name, style: mainStyle, overflow: TextOverflow.ellipsis);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(nickname, style: mainStyle, overflow: TextOverflow.ellipsis),
        Text(
          '($name)',
          style: TextStyle(fontSize: fontSize * 0.75, color: Colors.grey),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
