// Catalog state (Riverpod).
//
// Flow:  ShopFilter (search, category, price range, page)
//          └─► productPageProvider  (runs the Supabase query via the service)
//
// The UI only changes ShopFilter; productPageProvider watches it and
// re-queries automatically, so the list never gets out of sync.

import 'dart:typed_data';

import 'package:flutter/material.dart' show RangeValues;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';

/// Products shown per page (activity asks for 6–8).
const kPageSize = 8;

final productServiceProvider = Provider<ProductService>(
  (ref) => ProductService(),
);
final categoryServiceProvider = Provider<CategoryService>(
  (ref) => CategoryService(),
);

/// Everything the user can choose that affects which products are shown.
class ShopFilter {
  const ShopFilter({
    this.search = '',
    this.categoryId,
    this.priceRange,
    this.page = 0,
  });

  final String search;

  /// `null` = all categories.
  final int? categoryId;

  /// `null` = full price range.
  final RangeValues? priceRange;

  /// Zero-based page index.
  final int page;

  bool get isFiltered =>
      search.isNotEmpty || categoryId != null || priceRange != null;

  ShopFilter copyWith({
    String? search,
    int? Function()? categoryId,
    RangeValues? Function()? priceRange,
    int? page,
  }) => ShopFilter(
    search: search ?? this.search,
    categoryId: categoryId != null ? categoryId() : this.categoryId,
    priceRange: priceRange != null ? priceRange() : this.priceRange,
    page: page ?? this.page,
  );
}

class ShopFilterNotifier extends Notifier<ShopFilter> {
  @override
  ShopFilter build() => const ShopFilter();

  // Changing a filter always returns to page 1.
  void setSearch(String text) =>
      state = state.copyWith(search: text.trim(), page: 0);

  void setCategory(int? id) =>
      state = state.copyWith(categoryId: () => id, page: 0);

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

final priceBoundsProvider = FutureProvider<PriceBounds>(
  (ref) => ref.watch(productServiceProvider).fetchPriceBounds(),
);

final categoriesProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(categoryServiceProvider).fetchAll(),
);

/// The current page of products for the current filters.
final productPageProvider = FutureProvider<ProductPage>((ref) async {
  final filter = ref.watch(shopFilterProvider);
  final page = await ref
      .watch(productServiceProvider)
      .fetchPage(
        page: filter.page,
        pageSize: kPageSize,
        search: filter.search,
        categoryId: filter.categoryId,
        minPrice: filter.priceRange?.start,
        maxPrice: filter.priceRange?.end,
      );

  // E.g. after deleting the last product on the last page: step back.
  if (page.items.isEmpty && filter.page > 0) {
    ref.read(shopFilterProvider.notifier).goToPage(page.totalPages - 1);
  }
  return page;
});

/// Refreshes everything that shows product or category data.
void refreshCatalog(Ref ref) {
  ref.invalidate(productPageProvider);
  ref.invalidate(priceBoundsProvider);
  ref.invalidate(categoriesProvider);
}

/// Admin product and category management. RLS rejects these for customers
/// even if someone calls them directly.
class CatalogAdmin {
  CatalogAdmin(this.ref);
  final Ref ref;

  ProductService get _products => ref.read(productServiceProvider);
  CategoryService get _categories => ref.read(categoryServiceProvider);

  Future<String> uploadImage(Uint8List bytes, String fileName) =>
      _products.uploadImage(bytes, fileName);

  Future<void> createProduct(ProductDraft draft) async {
    await _products.create(draft);
    refreshCatalog(ref);
  }

  Future<void> updateProduct(int id, ProductDraft draft) async {
    await _products.update(id, draft);
    refreshCatalog(ref);
  }

  Future<void> deleteProduct(int id) async {
    await _products.delete(id);
    refreshCatalog(ref);
  }

  Future<void> createCategory(String name) async {
    await _categories.create(name);
    refreshCatalog(ref);
  }

  Future<void> renameCategory(int id, String name) async {
    await _categories.rename(id, name);
    refreshCatalog(ref);
  }

  Future<void> deleteCategory(int id) async {
    await _categories.delete(id);
    // A deleted category can't stay selected in the filter.
    if (ref.read(shopFilterProvider).categoryId == id) {
      ref.read(shopFilterProvider.notifier).setCategory(null);
    }
    refreshCatalog(ref);
  }
}

final catalogAdminProvider = Provider<CatalogAdmin>(CatalogAdmin.new);
