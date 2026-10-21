// widgets/type_filter_bar.dart
// Horizontally scrollable row of type ChoiceChips under the AppBar.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/type_filter_provider.dart';
import '../theme/pokemon_type_style.dart';

class TypeFilterBar extends ConsumerWidget {
  const TypeFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final types = ref.watch(availableTypesProvider);
    final selectedType = ref.watch(typeFilterProvider);
    final filter = ref.read(typeFilterProvider.notifier);

    // Nothing loaded yet → no chips to show.
    if (types.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 52,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: selectedType == null,
                  onSelected: (_) => filter.clearFilter(),
                ),
                for (final type in types)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _TypeChip(
                      type: type,
                      selected: selectedType == type,
                      // Tapping the selected chip again clears the filter.
                      onSelected: (isSelected) => isSelected
                          ? filter.selectType(type)
                          : filter.clearFilter(),
                    ),
                  ),
              ],
            ),
          ),
          // Clear (x) action, only while a filter is active.
          if (selectedType != null)
            IconButton(
              tooltip: 'Clear filter',
              icon: const Icon(Icons.close),
              onPressed: filter.clearFilter,
            ),
        ],
      ),
    );
  }
}

/// A ChoiceChip coloured by its Pokémon type.
class _TypeChip extends StatelessWidget {
  final String type;
  final bool selected;
  final ValueChanged<bool> onSelected;

  const _TypeChip({
    required this.type,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = typeColor(type);
    return ChoiceChip(
      label: Text(typeLabel(type)),
      selected: selected,
      onSelected: onSelected,
      showCheckmark: false,
      backgroundColor: color.withValues(alpha: 0.15),
      selectedColor: color,
      side: BorderSide(color: color),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
