import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/order.dart';
import '../services/order_service.dart';
import 'auth_providers.dart';
import 'cart_provider.dart';
import 'shop_providers.dart';

final orderServiceProvider = Provider<OrderService>((ref) => OrderService());

/// The customer's own orders, newest first.
final myOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return const [];
  return ref.watch(orderServiceProvider).fetchMyOrders(userId);
});

/// All orders (admin).
final allOrdersProvider = FutureProvider<List<Order>>(
  (ref) => ref.watch(orderServiceProvider).fetchAllOrders(),
);

class OrderActions {
  OrderActions(this.ref);
  final Ref ref;

  /// Places the order for everything in the cart. On success the cart is
  /// emptied and stock/order lists refresh. On failure nothing was saved
  /// (the database function rolls back) and the cart is kept.
  Future<OrderReceipt> checkout() async {
    final lines = ref.read(cartProvider);
    if (lines.isEmpty) throw StateError('Your cart is empty.');
    final receipt = await ref.read(orderServiceProvider).placeOrder(lines);
    ref.read(cartProvider.notifier).clear();
    ref.invalidate(myOrdersProvider);
    refreshCatalog(ref); // stock changed
    return receipt;
  }

  Future<void> updateStatus(int orderId, String status) async {
    await ref.read(orderServiceProvider).updateStatus(orderId, status);
    ref.invalidate(allOrdersProvider);
  }
}

final orderActionsProvider = Provider<OrderActions>(OrderActions.new);
