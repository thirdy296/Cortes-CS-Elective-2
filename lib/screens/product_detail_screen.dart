import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/cart_notifier.dart';
import '../screens/home_screen.dart';
import '../utils/formatters.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/app_image.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    final product = sampleProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => sampleProducts.first,
    );

    final cartNotifier = AppState.of(context).cartNotifier;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name, overflow: TextOverflow.ellipsis),
        actions: [
          CartIconButton(cartNotifier: cartNotifier),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image
            Container(
              height: 320,
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: AppImage(
                urlOrAsset: product.imageUrl,
                fit: BoxFit.contain,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand + name
                  Text(
                    product.brand.toUpperCase(),
                    style: TextStyle(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.name,
                    style: theme.textTheme.titleLarge?.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 12),

                  // Price
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      formatPeso(product.price),
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Specifications
                  Text(
                    'Specifications',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  _SpecRow(
                    icon: Icons.scale_outlined,
                    label: 'Weight',
                    value: '${product.weightOz} oz',
                  ),
                  _SpecRow(
                    icon: Icons.pan_tool_outlined,
                    label: 'Grip Size',
                    value: product.gripSize,
                  ),
                  _SpecRow(
                    icon: Icons.layers_outlined,
                    label: 'Face Material',
                    value: product.faceMaterial,
                  ),
                  _SpecRow(
                    icon: Icons.business_outlined,
                    label: 'Brand',
                    value: product.brand,
                  ),

                  const SizedBox(height: 24),
                  Divider(color: theme.dividerColor),
                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'About this paddle',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.description,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.6),
                  ),
                  const SizedBox(height: 32),

                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    child: _AddToCartButton(
                      cartNotifier: cartNotifier,
                      product: product,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SpecRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpecRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: colorScheme.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _AddToCartButton extends StatefulWidget {
  final CartNotifier cartNotifier;
  final Product product;

  const _AddToCartButton({
    required this.cartNotifier,
    required this.product,
  });

  @override
  State<_AddToCartButton> createState() => _AddToCartButtonState();
}

class _AddToCartButtonState extends State<_AddToCartButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  bool _added = false;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.cartNotifier.addProduct(widget.product);
    setState(() => _added = true);
    _animController.forward().then((_) => _animController.reverse());
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _added = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      child: ElevatedButton.icon(
        onPressed: _handleTap,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Icon(
            _added ? Icons.check_rounded : Icons.add_shopping_cart_rounded,
            key: ValueKey(_added),
          ),
        ),
        label: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: Text(
            _added ? 'Added to Cart!' : 'Add to Cart',
            key: ValueKey(_added),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _added ? colorScheme.tertiary : colorScheme.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }
}
