import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application_1/main.dart';
import 'package:flutter_application_1/models/product.dart';
import 'package:flutter_application_1/providers/shop_providers.dart';
import 'package:flutter_application_1/utils/formatters.dart';

void main() {
  testWidgets('Shop screen shows setup message without Supabase keys', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    expect(find.text('Shop'), findsOneWidget);
    expect(find.textContaining('Supabase is not configured'), findsOneWidget);
  });

  test('ProductPage computes page count', () {
    const page = ProductPage(items: [], totalCount: 17, page: 0, pageSize: 8);
    expect(page.totalPages, 3);
    expect(page.hasPrevious, isFalse);
    expect(page.hasNext, isTrue);
  });

  test('Changing a filter resets to the first page', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final notifier = container.read(shopFilterProvider.notifier);

    notifier.goToPage(2);
    expect(container.read(shopFilterProvider).page, 2);

    notifier.setCategory('Home');
    expect(container.read(shopFilterProvider).page, 0);
    expect(container.read(shopFilterProvider).category, 'Home');
  });

  test('formatPeso', () {
    expect(formatPeso(1299), '₱1,299');
    expect(formatPeso(12.5), '₱12.50');
    expect(formatPeso(1234567), '₱1,234,567');
  });
}
