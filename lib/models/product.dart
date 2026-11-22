/// One row of the `products` table (with its category name joined in).
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    this.categoryName,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String description;
  final double price;
  final int stock;
  final int categoryId;
  final String? categoryName;
  final String? imageUrl;

  bool get inStock => stock > 0;

  /// Columns selected for every product query.
  static const selectColumns = '*, categories(name)';

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: (json['id'] as num).toInt(),
    name: json['name'] as String,
    description: (json['description'] as String?) ?? '',
    // real/numeric columns arrive as int or double.
    price: (json['price'] as num).toDouble(),
    stock: (json['stock'] as num).toInt(),
    categoryId: (json['category_id'] as num).toInt(),
    categoryName:
        (json['categories'] as Map<String, dynamic>?)?['name'] as String?,
    imageUrl: json['image_url'] as String?,
  );
}

/// What the admin form sends to insert or update a product.
class ProductDraft {
  const ProductDraft({
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    this.imageUrl,
  });

  final String name;
  final String description;
  final double price;
  final int stock;
  final int categoryId;
  final String? imageUrl;

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'price': price,
    'stock': stock,
    'category_id': categoryId,
    'image_url': imageUrl,
  };
}

/// One page of products plus the total that match the filters.
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
