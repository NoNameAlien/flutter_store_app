import 'package:flutter/material.dart';

import '../features/catalog/presentation/catalog_page.dart';
import '../features/products/presentation/admin_page.dart';
import '../features/purchases/presentation/history_page.dart';
import '../features/store/application/store_controller.dart';
import 'store_scope.dart';

class StoreApp extends StatelessWidget {
  const StoreApp({super.key, required this.controller});

  final StoreController controller;

  @override
  Widget build(BuildContext context) {
    const seed = Color(0xff2e5bff);
    return StoreScope(
      controller: controller,
      child: MaterialApp(
        title: 'Магазин',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: seed,
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xfff7f8fc),
          appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
          inputDecorationTheme: const InputDecorationTheme(
            border: OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffd9deeb)),
            ),
          ),
          cardTheme: CardThemeData(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            margin: EdgeInsets.zero,
          ),
        ),
        home: const StoreHomePage(),
      ),
    );
  }
}

class StoreHomePage extends StatefulWidget {
  const StoreHomePage({super.key});

  @override
  State<StoreHomePage> createState() => _StoreHomePageState();
}

class _StoreHomePageState extends State<StoreHomePage> {
  int _selectedIndex = 0;

  static const _pages = [AdminPage(), CatalogPage(), HistoryPage()];
  static const _titles = ['Управление товарами', 'Каталог', 'История покупок'];

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_titles[_selectedIndex])),
    body: IndexedStack(index: _selectedIndex, children: _pages),
    bottomNavigationBar: NavigationBar(
      selectedIndex: _selectedIndex,
      onDestinationSelected: (index) => setState(() => _selectedIndex = index),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: 'Товары',
        ),
        NavigationDestination(
          icon: Icon(Icons.storefront_outlined),
          selectedIcon: Icon(Icons.storefront),
          label: 'Купить',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'История',
        ),
      ],
    ),
  );
}
