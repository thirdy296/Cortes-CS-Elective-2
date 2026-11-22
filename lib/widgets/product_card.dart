import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/formatters.dart';

/// Product tile. The bottom row depends on the role: admins get Edit and
/// Delete, customers get Add to cart. Exactly one of the two sets of
/// callbacks is passed in.
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onEdit,
    this.onDelete,
    this.onAddToCart,
    this.inCart = 0,
  });

  final Product product;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onAddToCart;

  /// How many of this product the customer already has in the cart.
  final int inCart;

  bool get _isAdminCard => onEdit != null || onDelete != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(
                  color: scheme.surfaceContainerHighest,
                  child: product.imageUrl == null || product.imageUrl!.isEmpty
                      ? Icon(Icons.coffee, size: 48, color: scheme.primary)
                      : Image.network(
                          product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Icon(
                            Icons.coffee,
                            size: 48,
                            color: scheme.primary,
                          ),
                        ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: _StockBadge(stock: product.stock),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  product.categoryName ?? '',
                  maxLines: 1,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 4, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    formatPeso(product.price),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: scheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_isAdminCard) ...[
                  IconButton(
                    tooltip: 'Edit ${product.name}',
                    visualDensity: VisualDensity.compact,
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 20),
                  ),
                  IconButton(
                    tooltip: 'Delete ${product.name}',
                    visualDensity: VisualDensity.compact,
                    onPressed: onDelete,
                    icon: Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: scheme.error,
                    ),
                  ),
                ] else
                  _AddToCartButton(
                    product: product,
                    inCart: inCart,
                    onPressed: onAddToCart,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({
    required this.product,
    required this.inCart,
    required this.onPressed,
  });

  final Product product;
  final int inCart;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final maxed = inCart >= product.stock;
    final tooltip = !product.inStock
        ? 'Out of stock'
        : maxed
        ? 'All available stock is in your cart'
        : 'Add to cart';
    return Tooltip(
      message: tooltip,
      child: IconButton.filledTonal(
        visualDensity: VisualDensity.compact,
        onPressed: product.inStock && !maxed ? onPressed : null,
        icon: Badge(
          isLabelVisible: inCart > 0,
          label: Text('$inCart'),
          child: const Icon(Icons.add_shopping_cart, size: 20),
        ),
      ),
    );
  }
}

class _StockBadge extends StatelessWidget {
  const _StockBadge({required this.stock});
  final int stock;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg, text) = switch (stock) {
      0 => (scheme.errorContainer, scheme.onErrorContainer, 'Out of stock'),
      <= 5 => (
        scheme.tertiaryContainer,
        scheme.onTertiaryContainer,
        'Only $stock left',
      ),
      _ => (
        scheme.secondaryContainer,
        scheme.onSecondaryContainer,
        '$stock in stock',
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
