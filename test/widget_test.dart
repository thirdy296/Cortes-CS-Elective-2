import 'package:flutter_test/flutter_test.dart';
import 'package:shop_browser/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ShopBrowserApp());
    expect(find.text('Paddle Shop'), findsOneWidget);
  });
}
