import 'package:go_router/go_router.dart';
import '../models/cart_notifier.dart';
import '../screens/home_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_screen.dart';

GoRouter createRouter(CartNotifier cartNotifier) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProductDetailScreen(productId: id);
        },
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout',
        redirect: (context, state) {
          if (cartNotifier.items.isEmpty) {
            return '/cart';
          }
          return null; // allow navigation
        },
        builder: (context, state) => const CheckoutScreen(),
      ),
    ],
  );
}
