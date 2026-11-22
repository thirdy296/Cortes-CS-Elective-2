import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/order.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/models/profile.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/providers/shop_providers.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/utils/formatters.dart';

Product _product({int id = 1, int stock = 3, double price = 100}) => Product(
  id: id,
  name: 'Bean $id',
  description: '',
  price: price,
  stock: stock,
  categoryId: 1,
);

void main() {
  testWidgets('Shows setup message without Supabase keys', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: BrewAndBeanApp()));
    expect(find.textContaining('Supabase is not configured'), findsOneWidget);
  });

  testWidgets('Login offers Google and email, and validates', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: LoginScreen())),
    );
    expect(find.text('Continue with Google'), findsOneWidget);
    await tester.tap(find.text('Sign in'));
    await tester.pump();
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter your password'), findsOneWidget);
  });

  testWidgets('Sign-up page asks for names and matching passwords', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: MaterialApp(home: SignUpScreen())),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Password'),
      'secret1',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Confirm password'),
      'secret2',
    );
    await tester.ensureVisible(find.text('Create account'));
    await tester.tap(find.text('Create account'));
    await tester.pump();
    expect(find.text('Required'), findsNWidgets(2));
    expect(find.text('Passwords do not match'), findsOneWidget);
  });

  group('Cart', () {
    late ProviderContainer container;
    late CartNotifier cart;
    setUp(() {
      container = ProviderContainer();
      cart = container.read(cartProvider.notifier);
    });
    tearDown(() => container.dispose());

    test('adds, counts and totals', () {
      expect(cart.add(_product(id: 1, price: 100)), isNull);
      expect(cart.add(_product(id: 1, price: 100)), isNull);
      expect(cart.add(_product(id: 2, price: 50)), isNull);
      expect(container.read(cartCountProvider), 3);
      expect(container.read(cartTotalProvider), 250);
    });

    test('blocks out-of-stock and quantities above stock', () {
      expect(cart.add(_product(stock: 0)), contains('out of stock'));
      expect(container.read(cartProvider), isEmpty);

      final p = _product(stock: 2);
      cart.add(p);
      cart.add(p);
      expect(cart.add(p), contains('Only 2'));
      expect(cart.setQuantity(p.id, 5), contains('Only 2'));
      expect(cart.quantityOf(p.id), 2);
    });

    test('quantity 0 removes the line; clear empties', () {
      cart.add(_product(id: 1));
      cart.add(_product(id: 2));
      cart.setQuantity(1, 0);
      expect(container.read(cartProvider).map((l) => l.product.id), [2]);
      cart.clear();
      expect(container.read(cartProvider), isEmpty);
    });
  });

  test('Changing a filter resets to page 1', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final filter = container.read(shopFilterProvider.notifier);
    filter.goToPage(2);
    filter.setSearch(' arabica ');
    expect(container.read(shopFilterProvider).page, 0);
    expect(container.read(shopFilterProvider).search, 'arabica');
    filter.goToPage(1);
    filter.setCategory(3);
    expect(container.read(shopFilterProvider).page, 0);
    expect(container.read(shopFilterProvider).categoryId, 3);
  });

  test('Models parse Supabase rows', () {
    final product = Product.fromJson({
      'id': 4,
      'name': 'Moka Pot',
      'description': null,
      'price': 999,
      'stock': 14,
      'category_id': 2,
      'image_url': null,
      'categories': {'name': 'Brewing Gear'},
    });
    expect(product.price, 999.0);
    expect(product.categoryName, 'Brewing Gear');

    final profile = Profile.fromJson({
      'id': 'u1',
      'email': 'a@b.co',
      'firstname': 'Ana',
      'lastname': null,
      'roles': {'role': 'admin'},
    });
    expect(profile.isAdmin, isTrue);
    expect(profile.displayName, 'Ana');

    final order = Order.fromJson({
      'id': 7,
      'created_at': '2026-11-22T03:00:00Z',
      'status': 'done',
      'total': 1240,
      'order_items': [
        {
          'id': 2,
          'product_id': null,
          'product_name': 'Mug',
          'unit_price': 299,
          'quantity': 2,
        },
        {
          'id': 1,
          'product_id': 5,
          'product_name': 'Beans',
          'unit_price': 642,
          'quantity': 1,
        },
      ],
    });
    expect(order.itemCount, 3);
    expect(order.items.first.productName, 'Beans');
  });

  test('formatPeso', () {
    expect(formatPeso(1299), '₱1,299');
    expect(formatPeso(12.5), '₱12.50');
  });
}
