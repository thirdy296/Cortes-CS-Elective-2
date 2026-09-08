import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/cart_notifier.dart';
import '../screens/home_screen.dart';
import '../utils/formatters.dart';
import '../widgets/app_image.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartNotifier = AppState.of(context).cartNotifier;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListenableBuilder(
        listenable: cartNotifier,
        builder: (context, _) {
          final items = cartNotifier.items;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    size: 80,
                    color: colorScheme.outline.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your cart is empty',
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add some paddles to get started!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => context.go('/'),
                    icon: const Icon(Icons.explore_outlined),
                    label: const Text('Browse Paddles'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _CartItemTile(
                      item: item,
                      cartNotifier: cartNotifier,
                    );
                  },
                ),
              ),

              // Bottom total + checkout
              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                decoration: BoxDecoration(
                  color: theme.cardTheme.color,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal (${cartNotifier.totalItemCount} items)',
                          style: theme.textTheme.bodyMedium
                              ?.copyWith(color: colorScheme.outline),
                        ),
                        Text(
                          formatPeso(cartNotifier.totalPrice),
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: colorScheme.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: items.isNotEmpty
                            ? () => context.go('/checkout')
                            : null,
                        icon: const Icon(Icons.lock_outline_rounded),
                        label: const Text('Proceed to Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CartItemTile extends StatefulWidget {
  final CartItem item;
  final CartNotifier cartNotifier;

  const _CartItemTile({required this.item, required this.cartNotifier});

  @override
  State<_CartItemTile> createState() => _CartItemTileState();
}

class _CartItemTileState extends State<_CartItemTile> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final item = widget.item;
    final subtotal = item.product.price * item.quantity;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: AppImage(
                urlOrAsset: item.product.imageUrl,
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // Name + brand
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.brand,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.product.name,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontSize: 13, height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatPeso(subtotal),
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Quantity stepper
            _QuantityStepper(
              quantity: item.quantity,
              onIncrement: () {
                widget.cartNotifier.increment(item.product.id);
              },
              onDecrement: () {
                widget.cartNotifier.decrement(item.product.id);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatefulWidget {
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _QuantityStepper({
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  State<_QuantityStepper> createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<_QuantityStepper> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: widget.quantity <= 1
                ? Icons.delete_outline_rounded
                : Icons.remove_rounded,
            color: widget.quantity <= 1 ? colorScheme.error : null,
            onTap: () {
              setState(() {});
              widget.onDecrement();
            },
          ),
          Container(
            width: 32,
            alignment: Alignment.center,
            child: Text(
              '${widget.quantity}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            onTap: () {
              setState(() {});
              widget.onIncrement();
            },
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  const _StepButton({required this.icon, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(icon, size: 16, color: color ?? colorScheme.primary),
      ),
    );
  }
}
