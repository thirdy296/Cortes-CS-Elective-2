import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';
import '../supabase_config.dart';

/// All Supabase queries for the `products` table live here, so widgets and
/// providers never build queries themselves.
class ProductService {
  static const table = 'products';

  /// Fetches ONE page of products. Filtering and paging both happen in the
  /// database:
  ///   * `.eq('category')`        – category filter (optional)
  ///   * `.gte/.lte('price')`     – price slider range
  ///   * `.range(from, to)`       – only the rows for this page
  ///   * `.count(CountOption.exact)` – total matching rows, for page numbers
  Future<ProductPage> fetchPage({
    required int page,
    required int pageSize,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1; // range() is inclusive on both ends

    var query = supabase.from(table).select();
    if (category != null) query = query.eq('category', category);
    if (minPrice != null) query = query.gte('price', minPrice);
    if (maxPrice != null) query = query.lte('price', maxPrice);

    final response = await query
        .order('price', ascending: true)
        .order('id', ascending: true) // tie-breaker keeps pages stable
        .range(from, to)
        .count(CountOption.exact);

    return ProductPage(
      items: response.data.map(Product.fromJson).toList(),
      totalCount: response.count,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Cheapest and most expensive product, used as the slider's min/max.
  Future<PriceBounds> fetchPriceBounds() async {
    final cheapest = await supabase
        .from(table)
        .select('price')
        .order('price', ascending: true)
        .limit(1)
        .maybeSingle();
    final priciest = await supabase
        .from(table)
        .select('price')
        .order('price', ascending: false)
        .limit(1)
        .maybeSingle();

    final min = (cheapest?['price'] as num?)?.toDouble() ?? 0;
    final max = (priciest?['price'] as num?)?.toDouble() ?? 0;
    return PriceBounds(min, max);
  }

  /// Distinct category names, sorted, for the filter chips.
  Future<List<String>> fetchCategories() async {
    final rows = await supabase.from(table).select('category');
    final names = {for (final row in rows) row['category'] as String};
    return names.toList()..sort();
  }

  Future<void> update(Product product) async {
    await supabase
        .from(table)
        .update(product.toUpdateJson())
        .eq('id', product.id);
  }

  Future<void> delete(int id) async {
    await supabase.from(table).delete().eq('id', id);
  }
}
