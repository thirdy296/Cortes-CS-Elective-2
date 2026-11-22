import '../models/cart_line.dart';
import '../models/order.dart';
import '../supabase_config.dart';
import '../utils/errors.dart';

class OrderService {
  /// Checkout through the `place_order` database function.
  ///
  /// Only product ids and quantities are sent. The function reads prices,
  /// names and stock from the database, saves the order and its items,
  /// reduces stock and marks the order done, all in one transaction.
  Future<OrderReceipt> placeOrder(List<CartLine> lines) async {
    final result = await supabase.rpc(
      'place_order',
      params: {
        'items': [
          for (final line in lines)
            {'product_id': line.product.id, 'quantity': line.quantity},
        ],
      },
    );
    final row = (result as List<dynamic>).first as Map<String, dynamic>;
    return OrderReceipt(
      orderId: (row['new_order_id'] as num).toInt(),
      total: (row['order_total'] as num).toDouble(),
    );
  }

  /// The customer's own orders, newest first. RLS already limits rows to the
  /// signed-in user; the filter makes the intent explicit.
  Future<List<Order>> fetchMyOrders(String userId) async {
    final rows = await supabase
        .from('orders')
        .select(Order.selectColumns)
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .order('id', ascending: false); // stable when timestamps match
    return rows.map(Order.fromJson).toList();
  }

  /// Every order with the customer's name (admin only, enforced by RLS).
  Future<List<Order>> fetchAllOrders() async {
    final rows = await supabase
        .from('orders')
        .select(Order.adminSelectColumns)
        .order('created_at', ascending: false)
        .order('id', ascending: false); // stable when timestamps match
    return rows.map(Order.fromJson).toList();
  }

  /// Admin: change an order's status (the only column admins may update).
  Future<void> updateStatus(int orderId, String status) async => ensureChanged(
    await supabase
        .from('orders')
        .update({'status': status})
        .eq('id', orderId)
        .select('id'),
  );
}
