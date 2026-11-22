import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/shop_providers.dart';
import 'price_range_filter.dart';

/// Search box, category chips and price slider above the product grid.
class CatalogFilters extends StatelessWidget {
  const CatalogFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SearchField(),
          SizedBox(height: 8),
          _CategoryChips(),
          PriceRangeFilter(),
        ],
      ),
    );
  }
}

/// Searches by product name. Waits 350 ms after typing stops so it doesn't
/// query Supabase on every keystroke.
class _SearchField extends ConsumerStatefulWidget {
  const _SearchField();

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  late final _controller = TextEditingController(
    text: ref.read(shopFilterProvider).search,
  );
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(
      const Duration(milliseconds: 350),
      () => ref.read(shopFilterProvider.notifier).setSearch(text),
    );
    setState(() {}); // show/hide the clear button
  }

  @override
  Widget build(BuildContext context) {
    // Keep the box in sync when "Clear filters" resets the search.
    ref.listen(shopFilterProvider.select((f) => f.search), (_, next) {
      if (next.isEmpty && _controller.text.isNotEmpty) _controller.clear();
    });

    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search products',
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close),
                onPressed: () {
                  _controller.clear();
                  _onChanged('');
                },
              ),
      ),
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selected = ref.watch(shopFilterProvider.select((f) => f.categoryId));
    final notifier = ref.read(shopFilterProvider.notifier);

    return categories.when(
      loading: () => const SizedBox(height: 40),
      error: (e, _) => Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: () => ref.invalidate(categoriesProvider),
          icon: const Icon(Icons.refresh),
          label: const Text('Could not load categories. Retry'),
        ),
      ),
      data: (list) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: const Text('All'),
                selected: selected == null,
                onSelected: (_) => notifier.setCategory(null),
              ),
            ),
            for (final c in list)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(c.name),
                  selected: selected == c.id,
                  onSelected: (_) => notifier.setCategory(c.id),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
