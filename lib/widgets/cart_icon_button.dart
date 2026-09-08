import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/cart_notifier.dart';

class CartIconButton extends StatelessWidget {
  final CartNotifier cartNotifier;

  const CartIconButton({super.key, required this.cartNotifier});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: cartNotifier,
      builder: (context, _) {
        final count = cartNotifier.totalItemCount;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_outlined),
              tooltip: 'Cart',
              onPressed: () => context.go('/cart'),
            ),
            if (count > 0)
              Positioned(
                top: 6,
                right: 6,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      shape: BoxShape.circle,
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
