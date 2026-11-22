/// Statuses allowed by the `orders.status` check constraint.
const kOrderStatuses = ['pending', 'done', 'shipped', 'delivered', 'cancelled'];

class Order {
  const Order({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.total,
    required this.items,
    this.customerName,
    this.customerEmail,
  });

  final int id;
  final DateTime createdAt;
  final String status;
  final double total;
  final List<OrderItem> items;

  /// Only filled in for the admin order list.
  final String? customerName;
  final String? customerEmail;

  int get itemCount => items.fold(0, (sum, i) => sum + i.quantity);

  static const selectColumns = '*, order_items(*)';
  static const adminSelectColumns =
      '*, order_items(*), profiles(email, firstname, lastname)';

  factory Order.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'] as Map<String, dynamic>?;
    final name = [
      profile?['firstname'],
      profile?['lastname'],
    ].whereType<String>().where((s) => s.trim().isNotEmpty).join(' ');
    final items =
        (json['order_items'] as List<dynamic>? ?? const [])
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => a.id.compareTo(b.id));
    return Order(
      id: (json['id'] as num).toInt(),
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      status: json['status'] as String,
      total: (json['total'] as num).toDouble(),
      items: items,
      customerName: name.isEmpty ? null : name,
      customerEmail: profile?['email'] as String?,
    );
  }
}

/// A saved order line: a snapshot of the product name and the price paid.
class OrderItem {
  const OrderItem({
    required this.id,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.productId,
  });

  final int id;
  final int? productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  double get subtotal => unitPrice * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    id: (json['id'] as num).toInt(),
    productId: (json['product_id'] as num?)?.toInt(),
    productName: json['product_name'] as String,
    unitPrice: (json['unit_price'] as num).toDouble(),
    quantity: (json['quantity'] as num).toInt(),
  );
}

/// What checkout returns.
class OrderReceipt {
  const OrderReceipt({required this.orderId, required this.total});
  final int orderId;
  final double total;
}
