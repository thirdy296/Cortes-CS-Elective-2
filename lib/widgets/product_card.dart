import 'package:flutter/material.dart';

import '../models/product.dart';
import '../utils/formatters.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final Product product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: product.imageUrl == null
                  ? const Icon(Icons.shopping_bag_outlined, size: 48)
                  : Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.broken_image_outlined, size: 48),
                    ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 4, 0),
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
                  product.category,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  formatPeso(product.price),
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Edit',
                visualDensity: VisualDensity.compact,
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 20),
              ),
              IconButton(
                tooltip: 'Delete',
                visualDensity: VisualDensity.compact,
                onPressed: onDelete,
                icon: Icon(
                  Icons.delete_outline,
                  size: 20,
                  color: theme.colorScheme.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
