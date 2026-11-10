// State management for the shop (Riverpod).
//
// Flow:  ShopFilter (what the user picked)  ──►  productPageProvider
//        (category, price range, page)           (runs the Supabase query)
//
// The UI only changes ShopFilter; productPageProvider watches it and
// re-queries Supabase automatically, so the list can never get out of sync
// with the filters or the current page.

import 'package:flutter/material.dart' show RangeValues;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../services/product_service.dart';

/// Products shown per page (activity asks for 6–8).
const kPageSize = 8;

final productServiceProvider = Provider<ProductService>(
  (ref) => ProductService(),
);

/// Everything the user can choose that affects which products are shown.
class ShopFilter {
  const ShopFilter({this.category, this.priceRange, this.page = 0});

  /// `null` = all categories.
  final String? category;

  /// `null` = no price filter (full range).
  final RangeValues? priceRange;

  /// Zero-based page index.
  final int page;

  ShopFilter copyWith({
    String? Function()? category,
    RangeValues? Function()? priceRange,
    int? page,
  }) => ShopFilter(
    category: category != null ? category() : this.category,
    priceRange: priceRange != null ? priceRange() : this.priceRange,
    page: page ?? this.page,
  );
}

class ShopFilterNotifier extends Notifier<ShopFilter> {
  @override
  ShopFilter build() => const ShopFilter();

  /// Changing a filter always jumps back to page 1, otherwise you could be
  /// stuck on "page 3" of a result set that only has one page.
  void setCategory(String? category) =>
      state = state.copyWith(category: () => category, page: 0);

  void setPriceRange(RangeValues range) =>
      state = state.copyWith(priceRange: () => range, page: 0);

  void clearFilters() => state = const ShopFilter();

  void goToPage(int page) => state = state.copyWith(page: page < 0 ? 0 : page);
  void nextPage() => goToPage(state.page + 1);
  void previousPage() => goToPage(state.page - 1);
}

final shopFilterProvider = NotifierProvider<ShopFilterNotifier, ShopFilter>(
  ShopFilterNotifier.new,
);

/// Min/max price in the table — the slider's limits.
final priceBoundsProvider = FutureProvider<PriceBounds>(
  (ref) => ref.watch(productServiceProvider).fetchPriceBounds(),
);

/// Category names for the filter chips.
final categoriesProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(productServiceProvider).fetchCategories(),
);

/// The current page of products, fetched from Supabase with the current
/// filters. Re-runs whenever [shopFilterProvider] changes.
final productPageProvider = FutureProvider<ProductPage>((ref) async {
  final filter = ref.watch(shopFilterProvider);
  final service = ref.watch(productServiceProvider);

  final page = await service.fetchPage(
    page: filter.page,
    pageSize: kPageSize,
    category: filter.category,
    minPrice: filter.priceRange?.start,
    maxPrice: filter.priceRange?.end,
  );

  // E.g. after deleting the last item on the last page: step back to the
  // last page that still has products.
  if (page.items.isEmpty && filter.page > 0) {
    ref.read(shopFilterProvider.notifier).goToPage(page.totalPages - 1);
  }
  return page;
});

/// Update / delete, then refresh everything that depends on the table.
class ProductActions {
  ProductActions(this.ref);
  final Ref ref;

  Future<void> update(Product product) async {
    await ref.read(productServiceProvider).update(product);
    _refresh();
  }

  Future<void> delete(int id) async {
    await ref.read(productServiceProvider).delete(id);
    _refresh();
  }

  void _refresh() {
    ref.invalidate(productPageProvider);
    ref.invalidate(priceBoundsProvider);
    ref.invalidate(categoriesProvider);
  }
}

final productActionsProvider = Provider<ProductActions>(ProductActions.new);
