import 'package:flutter/material.dart';

import '../models/order.dart';
import '../utils/formatters.dart';

/// Finds an order's position from its [OrderTile] key, so a list can move the
/// card (and whether it is expanded) along with the order when it re-sorts.
int? orderIndexForKey(List<Order> orders, Key key) {
  final index = orders.indexWhere((o) => ValueKey(o.id) == key);
  return index < 0 ? null : index;
}

/// Expandable order summary: number, date, status, total, and its items.
/// [trailing] lets the admin list add a status picker.
class OrderTile extends StatelessWidget {
  const OrderTile({super.key, required this.order, this.trailing});

  final Order order;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final customer = order.customerName ?? order.customerEmail;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ExpansionTile(
        shape: const Border(),
        title: Row(
          children: [
            Text('Order #${order.id}', style: theme.textTheme.titleMedium),
            const SizedBox(width: 8),
            StatusChip(status: order.status),
          ],
        ),
        subtitle: Text(
          [
            formatDateTime(order.createdAt),
            '${order.itemCount} ${order.itemCount == 1 ? 'item' : 'items'}',
            formatPeso(order.total),
            ?customer,
          ].join(' · '),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text('${item.quantity} × ${item.productName}'),
                  ),
                  Text(
                    '${formatPeso(item.unitPrice)} each  ',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(formatPeso(item.subtotal)),
                ],
              ),
            ),
          const Divider(),
          Row(
            children: [
              Text('Total', style: theme.textTheme.titleSmall),
              const Spacer(),
              Text(
                formatPeso(order.total),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (trailing != null) ...[const SizedBox(height: 8), trailing!],
        ],
      ),
    );
  }
}

class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (status) {
      'cancelled' => (scheme.errorContainer, scheme.onErrorContainer),
      'pending' => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      _ => (scheme.secondaryContainer, scheme.onSecondaryContainer),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        capitalize(status),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: fg),
      ),
    );
  }
}
