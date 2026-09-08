import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_notifier.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final cartNotifier = AppState.of(context).cartNotifier;
    final themeMode = AppState.of(context).themeMode;
    final toggleTheme = AppState.of(context).toggleTheme;
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.sports_tennis, size: 22),
            const SizedBox(width: 8),
            const Text('Paddle Shop'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => RotationTransition(
                turns: animation,
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                key: ValueKey(isDark),
              ),
            ),
            onPressed: toggleTheme,
          ),
          CartIconButton(cartNotifier: cartNotifier),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Find Your Perfect Paddle',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${sampleProducts.length} paddles available',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ],
            ),
          ),
          // Product grid
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 600 ? 3 : 2;
                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: sampleProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: sampleProducts[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- AppState InheritedWidget for shared state ---

class AppState extends InheritedWidget {
  final CartNotifier cartNotifier;
  final ThemeMode themeMode;
  final VoidCallback toggleTheme;

  const AppState({
    super.key,
    required this.cartNotifier,
    required this.themeMode,
    required this.toggleTheme,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final result = context.dependOnInheritedWidgetOfExactType<AppState>();
    assert(result != null, 'No AppState found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(AppState oldWidget) =>
      themeMode != oldWidget.themeMode;
}
