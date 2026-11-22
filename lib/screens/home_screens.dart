import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cart_provider.dart';
import '../providers/shop_providers.dart';
import '../widgets/account_menu.dart';
import 'admin_orders_screen.dart';
import 'cart_screen.dart';
import 'catalog_screen.dart';
import 'categories_screen.dart';
import 'order_history_screen.dart';
import 'product_form_screen.dart';

/// Customer app: Shop, Cart, Orders. No management controls anywhere.
class CustomerHome extends ConsumerStatefulWidget {
  const CustomerHome({super.key});

  @override
  ConsumerState<CustomerHome> createState() => _CustomerHomeState();
}

class _CustomerHomeState extends ConsumerState<CustomerHome> {
  int _tab = 0;

  static const _titles = ['Brew & Bean', 'Your cart', 'Your orders'];

  @override
  Widget build(BuildContext context) {
    final count = ref.watch(cartCountProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_tab]),
        actions: [
          if (_tab == 0) const _ClearFiltersButton(),
          const AccountMenu(),
          const SizedBox(width: 8),
        ],
      ),
      // IndexedStack keeps each tab's scroll position and state.
      body: IndexedStack(
        index: _tab,
        children: [
          const CatalogView(),
          CartView(onBrowse: () => setState(() => _tab = 0)),
          const OrderHistoryView(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.storefront_outlined),
            selectedIcon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: count > 0,
              label: Text('$count'),
              child: const Icon(Icons.shopping_cart),
            ),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
        ],
      ),
    );
  }
}

/// Admin app: Products (with Add FAB, Edit/Delete), Orders, Categories.
class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _tab = 0;

  static const _titles = ['Products', 'All orders', 'Categories'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(_titles[_tab]),
            const SizedBox(width: 8),
            const Chip(
              label: Text('Admin'),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
        actions: [
          if (_tab == 0) const _ClearFiltersButton(),
          const AccountMenu(),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              heroTag: 'add-product',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProductFormScreen()),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add product'),
            )
          : null,
      body: IndexedStack(
        index: _tab,
        children: const [CatalogView(), AdminOrdersView(), CategoriesView()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          NavigationDestination(
            icon: Icon(Icons.category_outlined),
            selectedIcon: Icon(Icons.category),
            label: 'Categories',
          ),
        ],
      ),
    );
  }
}

class _ClearFiltersButton extends ConsumerWidget {
  const _ClearFiltersButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtered = ref.watch(shopFilterProvider.select((f) => f.isFiltered));
    return IconButton(
      tooltip: 'Clear filters',
      onPressed: filtered
          ? ref.read(shopFilterProvider.notifier).clearFilters
          : null,
      icon: const Icon(Icons.filter_alt_off_outlined),
    );
  }
}
