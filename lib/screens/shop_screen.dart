import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../providers/shop_providers.dart';
import '../supabase_config.dart';
import '../widgets/edit_product_dialog.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/price_range_filter.dart';
import '../widgets/product_card.dart';
import 'music_player_screen.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: [
          IconButton(
            tooltip: 'Music player',
            icon: const Icon(Icons.music_note_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MusicPlayerScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Clear filters',
            icon: const Icon(Icons.filter_alt_off_outlined),
            onPressed: SupabaseConfig.isConfigured
                ? ref.read(shopFilterProvider.notifier).clearFilters
                : null,
          ),
        ],
      ),
      body: SupabaseConfig.isConfigured
          ? const _ShopBody()
          : const _Message(
              icon: Icons.cloud_off,
              text:
                  'Supabase is not configured.\nRun with '
                  '--dart-define-from-file=supabase.json',
            ),
    );
  }
}

class _ShopBody extends ConsumerWidget {
  const _ShopBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(productPageProvider);

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(children: [_CategoryChips(), PriceRangeFilter()]),
        ),
        const Divider(height: 1),
        Expanded(
          child: pageAsync.when(
            // Keep showing the old page while the next one loads.
            skipLoadingOnReload: true,
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _Message(
              icon: Icons.error_outline,
              text: 'Could not load products.\n$e',
              action: TextButton(
                onPressed: () => ref.invalidate(productPageProvider),
                child: const Text('Retry'),
              ),
            ),
            data: (page) => page.items.isEmpty
                ? const _Message(
                    icon: Icons.search_off,
                    text: 'No products match these filters.',
                  )
                : _ProductGrid(products: page.items),
          ),
        ),
        if (pageAsync.isLoading && pageAsync.hasValue)
          const LinearProgressIndicator(minHeight: 2),
        if (pageAsync.value case final page?) PaginationBar(page: page),
      ],
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider).value ?? const [];
    final selected = ref.watch(shopFilterProvider.select((f) => f.category));
    final notifier = ref.read(shopFilterProvider.notifier);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final name in [null, ...categories])
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(name ?? 'All'),
                selected: selected == name,
                onSelected: (_) => notifier.setCategory(name),
              ),
            ),
        ],
      ),
    );
  }
}

class _ProductGrid extends ConsumerWidget {
  const _ProductGrid({required this.products});
  final List<Product> products;

  Future<void> _edit(BuildContext context, WidgetRef ref, Product p) async {
    final edited = await showEditProductDialog(context, p);
    if (edited == null || !context.mounted) return;
    await _run(
      context,
      () => ref.read(productActionsProvider).update(edited),
      'Saved "${edited.name}"',
    );
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, Product p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text('"${p.name}" will be removed from the shop.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await _run(
      context,
      () => ref.read(productActionsProvider).delete(p.id),
      'Deleted "${p.name}"',
    );
  }

  Future<void> _run(
    BuildContext context,
    Future<void> Function() action,
    String success,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
      messenger.showSnackBar(SnackBar(content: Text(success)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) {
        final p = products[i];
        return ProductCard(
          product: p,
          onEdit: () => _edit(context, ref, p),
          onDelete: () => _delete(context, ref, p),
        );
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});
  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 12),
            Text(text, textAlign: TextAlign.center),
            ?action,
          ],
        ),
      ),
    );
  }
}
