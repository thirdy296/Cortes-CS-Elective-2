import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../utils/formatters.dart';
import '../widgets/app_image.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartNotifier = AppState.of(context).cartNotifier;
    final items = cartNotifier.items;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Summary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.go('/cart'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.tertiary.withValues(alpha: 0.15),
                    colorScheme.primary.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colorScheme.tertiary.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Order Placed Successfully!',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.tertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Thank you for your purchase. Your paddle is on its way!',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            Text(
              'Order Details',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 12),

            // Item list
            ...items.map((item) {
              final subtotal = item.product.price * item.quantity;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: AppImage(
                            urlOrAsset: item.product.imageUrl,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                style: theme.textTheme.titleMedium
                                    ?.copyWith(fontSize: 13),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Qty: ${item.quantity}  ×  ${formatPeso(item.product.price)}',
                                style: TextStyle(
                                  color: colorScheme.outline,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          formatPeso(subtotal),
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),

            const SizedBox(height: 12),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 12),

            // Grand total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Grand Total',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                Text(
                  formatPeso(cartNotifier.totalPrice),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Go back to shop
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  cartNotifier.clear();
                  context.go('/');
                },
                icon: const Icon(Icons.explore_outlined),
                label: const Text('Continue Shopping'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
