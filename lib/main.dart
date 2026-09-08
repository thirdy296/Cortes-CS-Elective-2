import 'package:flutter/material.dart';
import 'models/cart_notifier.dart';
import 'theme/app_theme.dart';
import 'router.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ShopBrowserApp());
}

class ShopBrowserApp extends StatefulWidget {
  const ShopBrowserApp({super.key});

  @override
  State<ShopBrowserApp> createState() => _ShopBrowserAppState();
}

class _ShopBrowserAppState extends State<ShopBrowserApp> {
  ThemeMode _themeMode = ThemeMode.light;
  final CartNotifier _cartNotifier = CartNotifier();
  late final _router = createRouter(_cartNotifier);

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  void dispose() {
    _cartNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppState(
      cartNotifier: _cartNotifier,
      themeMode: _themeMode,
      toggleTheme: _toggleTheme,
      child: MaterialApp.router(
        title: 'Shop Browser',
        debugShowCheckedModeBanner: false,
        theme: lightTheme(),
        darkTheme: darkTheme(),
        themeMode: _themeMode,
        routerConfig: _router,
      ),
    );
  }
}
