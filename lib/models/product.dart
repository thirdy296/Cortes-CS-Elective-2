/// One row of the Supabase `products` table.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String description;
  final String category;
  final double price;
  final String? imageUrl;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
    description: (json['description'] as String?) ?? '',
    category: json['category'] as String,
    // `numeric` columns arrive as int or double depending on the value.
    price: (json['price'] as num).toDouble(),
    imageUrl: json['image_url'] as String?,
  );

  /// Only the columns the edit dialog is allowed to change.
  Map<String, dynamic> toUpdateJson() => {
    'name': name,
    'description': description,
    'category': category,
    'price': price,
  };

  Product copyWith({
    String? name,
    String? description,
    String? category,
    double? price,
  }) => Product(
    id: id,
    name: name ?? this.name,
    description: description ?? this.description,
    category: category ?? this.category,
    price: price ?? this.price,
    imageUrl: imageUrl,
  );
}

/// One page of products plus the total number of rows that match the
/// current filters (used to compute how many pages there are).
class ProductPage {
  const ProductPage({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });

  final List<Product> items;
  final int totalCount;

  /// Zero-based page index.
  final int page;
  final int pageSize;

  int get totalPages => totalCount == 0 ? 1 : (totalCount / pageSize).ceil();
  bool get hasPrevious => page > 0;
  bool get hasNext => page < totalPages - 1;
}

/// Lowest and highest price in the table; the slider's limits.
class PriceBounds {
  const PriceBounds(this.min, this.max);
  final double min;
  final double max;
}
