import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';
import '../supabase_config.dart';
import '../utils/errors.dart';

/// The only code that queries the `products` table and the image bucket.
class ProductService {
  static const _table = 'products';
  static const imageBucket = 'product-images';

  /// One page of products, filtered and paged in the database:
  ///   * `.ilike('name')`          – search box
  ///   * `.eq('category_id')`      – category chips
  ///   * `.gte/.lte('price')`      – price slider
  ///   * `.range(from, to)`        – only this page's rows
  ///   * `.count(CountOption.exact)` – total, for page numbers
  Future<ProductPage> fetchPage({
    required int page,
    required int pageSize,
    String search = '',
    int? categoryId,
    double? minPrice,
    double? maxPrice,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1; // range() is inclusive

    var query = supabase.from(_table).select(Product.selectColumns);
    if (search.isNotEmpty) {
      // Escape the LIKE wildcards so "%" and "_" are searched literally.
      final escaped = search.replaceAll(RegExp(r'([%_\\])'), r'\$1');
      query = query.ilike('name', '%$escaped%');
    }
    if (categoryId != null) query = query.eq('category_id', categoryId);
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

  /// Cheapest and most expensive product: the slider's limits.
  Future<PriceBounds> fetchPriceBounds() async {
    Future<double> edge({required bool ascending}) async {
      final row = await supabase
          .from(_table)
          .select('price')
          .order('price', ascending: ascending)
          .limit(1)
          .maybeSingle();
      return (row?['price'] as num?)?.toDouble() ?? 0;
    }

    return PriceBounds(
      await edge(ascending: true),
      await edge(ascending: false),
    );
  }

  Future<void> create(ProductDraft draft) =>
      supabase.from(_table).insert(draft.toJson());

  Future<void> update(int id, ProductDraft draft) async => ensureChanged(
    await supabase
        .from(_table)
        .update(draft.toJson())
        .eq('id', id)
        .select('id'),
  );

  Future<void> delete(int id) async => ensureChanged(
    await supabase.from(_table).delete().eq('id', id).select('id'),
  );

  /// Uploads an image to Supabase Storage and returns its public URL.
  Future<String> uploadImage(Uint8List bytes, String fileName) async {
    final ext = fileName.contains('.')
        ? fileName.split('.').last.toLowerCase()
        : 'jpg';
    final contentType = switch (ext) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
    final path = 'products/${DateTime.now().microsecondsSinceEpoch}.$ext';
    final storage = supabase.storage.from(imageBucket);
    await storage.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: contentType, upsert: false),
    );
    return storage.getPublicUrl(path);
  }
}
