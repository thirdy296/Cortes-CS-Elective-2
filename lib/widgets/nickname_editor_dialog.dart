// widgets/nickname_editor_dialog.dart
// Dialog to set, edit or remove a Pokémon's nickname.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/nickname_provider.dart';

/// Opens the nickname editor for [pokemon] (from a card or the detail page).
Future<void> showNicknameEditor(BuildContext context, Pokemon pokemon) {
  return showDialog<void>(
    context: context,
    builder: (_) => NicknameEditorDialog(pokemon: pokemon),
  );
}

/// A ConsumerStatefulWidget ONLY because it owns a TextEditingController,
/// which must be created once and disposed. The nickname itself lives in
/// [nicknameProvider]; this widget never calls setState.
class NicknameEditorDialog extends ConsumerStatefulWidget {
  final Pokemon pokemon;

  const NicknameEditorDialog({super.key, required this.pokemon});

  @override
  ConsumerState<NicknameEditorDialog> createState() =>
      _NicknameEditorDialogState();
}

class _NicknameEditorDialogState extends ConsumerState<NicknameEditorDialog> {
  late final TextEditingController _controller;

  int get _id => widget.pokemon.id;

  @override
  void initState() {
    super.initState();
    // Prefill with the current nickname (ref.read: we only need it once).
    final current = ref.read(nicknameProvider)[_id];
    _controller = TextEditingController(text: current ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(nicknameProvider.notifier).setNickname(_id, _controller.text);
    Navigator.of(context).pop();
  }

  void _remove() {
    ref.read(nicknameProvider.notifier).removeNickname(_id);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final hasNickname = ref.watch(
      nicknameProvider.select((nicknames) => nicknames.containsKey(_id)),
    );

    return AlertDialog(
      title: Text('Nickname for ${widget.pokemon.name}'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 20,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _save(),
        decoration: InputDecoration(
          labelText: 'Nickname',
          hintText: widget.pokemon.name,
          helperText: 'Leave empty to remove the nickname',
        ),
      ),
      actions: [
        TextButton(
          // Only enabled when there is a nickname to remove.
          onPressed: hasNickname ? _remove : null,
          child: const Text('Remove nickname'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}
