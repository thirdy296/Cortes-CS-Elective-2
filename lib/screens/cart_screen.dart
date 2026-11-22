import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_line.dart';
import '../providers/cart_provider.dart';
import '../providers/order_providers.dart';
import '../utils/formatters.dart';
import '../widgets/state_views.dart';
import 'order_confirmation_screen.dart';

class CartView extends ConsumerStatefulWidget {
  const CartView({super.key, required this.onBrowse});

  /// Switches to the Shop tab.
  final VoidCallback onBrowse;

  @override
  ConsumerState<CartView> createState() => _CartViewState();
}

class _CartViewState extends ConsumerState<CartView> {
  bool _placing = false;

  Future<void> _checkout() async {
    setState(() => _placing = true);
    try {
      final receipt = await ref.read(orderActionsProvider).checkout();
      if (!mounted) return;
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OrderConfirmationScreen(receipt: receipt),
        ),
      );
    } catch (e) {
      // Nothing was saved; the cart is kept so the user can fix it.
      if (mounted) showErrorSnack(context, e);
    } finally {
      if (mounted) setState(() => _placing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lines = ref.watch(cartProvider);
    final count = ref.watch(cartCountProvider);
    final total = ref.watch(cartTotalProvider);
    final theme = Theme.of(context);

    if (lines.isEmpty) {
      return MessageView(
        icon: Icons.shopping_basket_outlined,
        title: 'Your cart is empty',
        message: 'Add some coffee from the shop.',
        action: FilledButton(
          onPressed: widget.onBrowse,
          child: const Text('Browse products'),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: lines.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, i) => _CartLineTile(line: lines[i]),
          ),
        ),
        Material(
          elevation: 8,
          color: theme.colorScheme.surfaceContainer,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        '$count ${count == 1 ? 'item' : 'items'}',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const Spacer(),
                      Text('Total  ', style: theme.textTheme.bodyLarge),
                      Text(
                        formatPeso(total),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Final prices and stock are confirmed at checkout.',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                    ),
                    onPressed: _placing ? null : _checkout,
                    icon: _placing
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.lock_outline),
                    label: Text(_placing ? 'Placing order…' : 'Checkout'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _CartLineTile extends ConsumerWidget {
  const _CartLineTile({required this.line});
  final CartLine line;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = line.product;
    final notifier = ref.read(cartProvider.notifier);
    final theme = Theme.of(context);

    void setQty(int q) {
      final error = notifier.setQuantity(p.id, q);
      if (error != null) showErrorSnack(context, error);
    }

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 52,
          height: 52,
          child: p.imageUrl == null
              ? const Icon(Icons.coffee)
              : Image.network(
                  p.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => const Icon(Icons.coffee),
                ),
        ),
      ),
      title: Text(p.name, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: Text(
        '${formatPeso(p.price)} each · ${formatPeso(line.subtotal)}',
        style: theme.textTheme.bodySmall,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Decrease',
            onPressed: () => setQty(line.quantity - 1),
            icon: const Icon(Icons.remove_circle_outline),
          ),
          Text('${line.quantity}', style: theme.textTheme.titleMedium),
          IconButton(
            tooltip: line.quantity >= p.stock ? 'No more in stock' : 'Increase',
            onPressed: line.quantity >= p.stock
                ? null
                : () => setQty(line.quantity + 1),
            icon: const Icon(Icons.add_circle_outline),
          ),
          IconButton(
            tooltip: 'Remove',
            onPressed: () => notifier.remove(p.id),
            icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
          ),
        ],
      ),
    );
  }
}
