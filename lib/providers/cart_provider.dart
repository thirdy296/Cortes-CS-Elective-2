// The cart lives in app state (Riverpod), so it survives switching tabs and
// screens. It is emptied after a successful order and when the user signs
// out or a different user signs in.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_line.dart';
import '../models/product.dart';
import 'auth_providers.dart';

class CartNotifier extends Notifier<List<CartLine>> {
  @override
  List<CartLine> build() {
    // Clear the cart on logout / account switch.
    ref.listen<String?>(currentUserIdProvider, (previous, next) {
      if (previous != next) state = const [];
    });
    return const [];
  }

  int quantityOf(int productId) => state
      .where((l) => l.product.id == productId)
      .fold(0, (sum, l) => sum + l.quantity);

  /// Adds one of [product]. Returns an error message, or null on success.
  String? add(Product product) {
    if (!product.inStock) return '${product.name} is out of stock.';
    final current = quantityOf(product.id);
    if (current >= product.stock) {
      return 'Only ${product.stock} of ${product.name} available.';
    }
    if (current == 0) {
      state = [...state, CartLine(product: product, quantity: 1)];
    } else {
      _replace(product.id, current + 1, product: product);
    }
    return null;
  }

  /// Sets the quantity (clamped to 1..stock). Returns an error message when
  /// the request had to be clamped.
  String? setQuantity(int productId, int quantity) {
    final line = state.firstWhere((l) => l.product.id == productId);
    if (quantity <= 0) {
      remove(productId);
      return null;
    }
    if (quantity > line.product.stock) {
      _replace(productId, line.product.stock);
      return 'Only ${line.product.stock} of ${line.product.name} available.';
    }
    _replace(productId, quantity);
    return null;
  }

  void remove(int productId) =>
      state = state.where((l) => l.product.id != productId).toList();

  void clear() => state = const [];

  void _replace(int productId, int quantity, {Product? product}) {
    state = [
      for (final l in state)
        if (l.product.id == productId)
          l.copyWith(quantity: quantity, product: product)
        else
          l,
    ];
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartLine>>(
  CartNotifier.new,
);

/// Total number of items (sum of quantities), for the badge.
final cartCountProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).fold(0, (sum, l) => sum + l.quantity),
);

/// Running total shown in the cart (display only; checkout recomputes it).
final cartTotalProvider = Provider<double>(
  (ref) => ref.watch(cartProvider).fold(0.0, (sum, l) => sum + l.subtotal),
);
