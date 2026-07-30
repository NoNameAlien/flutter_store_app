import 'package:flutter/material.dart';
import 'package:flutter_store_app/app/store_app.dart';
import 'package:flutter_store_app/features/products/data/repositories/memory_product_repository.dart';
import 'package:flutter_store_app/features/purchases/data/repositories/memory_purchase_repository.dart';
import 'package:flutter_store_app/features/store/application/store_controller.dart';
import 'package:flutter_store_app/features/store/data/repositories/memory_store_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  StoreController createController() {
    final productRepository = MemoryProductRepository();
    final purchaseRepository = MemoryPurchaseRepository();
    return StoreController(
      productRepository: productRepository,
      purchaseRepository: purchaseRepository,
      transaction: MemoryStoreTransaction(
        productRepository: productRepository,
        purchaseRepository: purchaseRepository,
      ),
    );
  }

  testWidgets('form requires a product image', (tester) async {
    await tester.pumpWidget(StoreApp(controller: createController()));

    final inputs = find.byType(TextFormField);
    await tester.enterText(inputs.at(0), 'Наушники');
    await tester.enterText(inputs.at(1), '4990');
    await tester.tap(find.text('Добавить товар'));
    await tester.pump();

    expect(find.text('Выберите изображение товара'), findsOneWidget);
  });

  testWidgets('a purchase immediately appears in history', (tester) async {
    final controller = createController();
    controller.addProduct(
      name: 'Наушники',
      price: 4990,
      stock: 2,
      imagePath: '/missing/headphones.jpg',
      isAvailable: true,
    );
    await tester.pumpWidget(StoreApp(controller: controller));

    await tester.tap(find.text('Купить'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Купить'));
    await tester.pump();
    await tester.tap(find.text('История'));
    await tester.pumpAndSettle();

    expect(find.text('Наушники'), findsOneWidget);
    expect(find.textContaining('1 шт. × 4990 ₽'), findsOneWidget);
    expect(find.text('Итого\n4990 ₽'), findsOneWidget);
  });
}
