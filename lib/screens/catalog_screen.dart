import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_line.dart';
import '../models/product.dart';
import '../providers/auth_providers.dart';
import '../providers/cart_provider.dart';
import '../providers/shop_providers.dart';
import '../widgets/catalog_filters.dart';
import '../widgets/pagination_bar.dart';
import '../widgets/product_card.dart';
import '../widgets/state_views.dart';
import 'product_form_screen.dart';

/// Product list shared by both roles. Admins see Edit/Delete on each card
/// and an Add button (FAB, provided by AdminHome); customers see Add to cart.
class CatalogView extends ConsumerWidget {
  const CatalogView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageAsync = ref.watch(productPageProvider);
    final filtered = ref.watch(shopFilterProvider.select((f) => f.isFiltered));

    return Column(
      children: [
        const CatalogFilters(),
        const Divider(height: 1),
        Expanded(
          child: pageAsync.when(
            skipLoadingOnReload: true, // keep the old page while loading
            loading: () => const LoadingView(label: 'Loading products'),
            error: (e, _) => ErrorView(
              error: e,
              onRetry: () => ref.invalidate(productPageProvider),
            ),
            data: (page) => page.items.isEmpty
                ? MessageView(
                    icon: Icons.search_off,
                    title: filtered
                        ? 'No products match these filters'
                        : 'No products yet',
                    action: filtered
                        ? OutlinedButton(
                            onPressed: ref
                                .read(shopFilterProvider.notifier)
                                .clearFilters,
                            child: const Text('Clear filters'),
                          )
                        : null,
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(priceBoundsProvider);
                      ref.invalidate(categoriesProvider);
                      ref.invalidate(productPageProvider);
                      await ref.read(productPageProvider.future);
                    },
                    child: _ProductGrid(products: page.items),
                  ),
          ),
        ),
        if (pageAsync.isLoading && pageAsync.hasValue)
          const LinearProgressIndicator(minHeight: 2),
        if (pageAsync.value case final page? when page.items.isNotEmpty)
          PaginationBar(page: page),
      ],
    );
  }
}

class _ProductGrid extends ConsumerWidget {
  const _ProductGrid({required this.products});
  final List<Product> products;

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Product p,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.delete_outline),
        title: Text('Delete "${p.name}"?'),
        content: Text(
          '"${p.name}" will be removed from the catalog. '
          'Past orders keep their copy of it.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete ${p.name}'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(catalogAdminProvider).deleteProduct(p.id);
      if (context.mounted) showInfoSnack(context, 'Deleted "${p.name}"');
    } catch (e) {
      if (context.mounted) showErrorSnack(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(isAdminProvider);
    final List<CartLine> cart = isAdmin ? const [] : ref.watch(cartProvider);

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) {
        final p = products[i];
        if (isAdmin) {
          return ProductCard(
            product: p,
            onEdit: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProductFormScreen(product: p)),
            ),
            onDelete: () => _confirmDelete(context, ref, p),
          );
        }
        final inCart = cart
            .where((l) => l.product.id == p.id)
            .fold(0, (sum, l) => sum + l.quantity);
        return ProductCard(
          product: p,
          inCart: inCart,
          onAddToCart: () {
            final error = ref.read(cartProvider.notifier).add(p);
            error == null
                ? showInfoSnack(context, 'Added ${p.name} to cart')
                : showErrorSnack(context, error);
          },
        );
      },
    );
  }
}
