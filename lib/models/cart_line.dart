import 'product.dart';

/// One product in the cart. The price here is only for display; checkout
/// re-reads prices and stock from the database.
class CartLine {
  const CartLine({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get subtotal => product.price * quantity;

  CartLine copyWith({Product? product, int? quantity}) => CartLine(
    product: product ?? this.product,
    quantity: quantity ?? this.quantity,
  );
}
