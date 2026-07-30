import 'package:flutter_store_app/features/products/data/repositories/memory_product_repository.dart';
import 'package:flutter_store_app/features/purchases/data/repositories/memory_purchase_repository.dart';
import 'package:flutter_store_app/features/store/application/store_controller.dart';
import 'package:flutter_store_app/features/store/data/repositories/memory_store_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late StoreController controller;
  late MemoryProductRepository productRepository;
  late MemoryPurchaseRepository purchaseRepository;

  setUp(() {
    productRepository = MemoryProductRepository();
    purchaseRepository = MemoryPurchaseRepository();
    controller = StoreController(
      productRepository: productRepository,
      purchaseRepository: purchaseRepository,
      transaction: MemoryStoreTransaction(
        productRepository: productRepository,
        purchaseRepository: purchaseRepository,
      ),
    );
  });

  void addProduct({int stock = 2, bool isAvailable = true}) {
    controller.addProduct(
      name: 'Наушники',
      price: 4990,
      stock: stock,
      imagePath: '/tmp/headphones.jpg',
      isAvailable: isAvailable,
    );
  }

  test('purchase decreases stock and creates immutable history record', () {
    addProduct();
    final product = controller.products.single;

    expect(controller.buy(product.id), PurchaseResult.success);
    expect(controller.products.single.stock, 1);
    expect(controller.purchases, hasLength(1));
    expect(controller.purchases.single.productName, 'Наушники');
    expect(controller.purchases.single.quantity, 1);
    expect(controller.purchases.single.unitPrice, 4990);
  });

  test('out of stock or unavailable products cannot be bought', () {
    addProduct(stock: 0);
    expect(
      controller.buy(controller.products.single.id),
      PurchaseResult.outOfStock,
    );
    expect(controller.purchases, isEmpty);

    controller.deleteProduct(controller.products.single.id);
    addProduct(isAvailable: false);
    expect(
      controller.buy(controller.products.single.id),
      PurchaseResult.unavailable,
    );
    expect(controller.purchases, isEmpty);
  });

  test('catalog follows availability and inventory never becomes negative', () {
    addProduct(isAvailable: false);
    final product = controller.products.single;
    expect(controller.catalogProducts, isEmpty);

    controller.changeAvailability(product.id, true);
    controller.changeStock(product.id, -99);
    expect(controller.catalogProducts, hasLength(1));
    expect(controller.products.single.stock, 2);
  });

  test('controller rejects invalid product data outside the UI', () {
    expect(
      () => controller.addProduct(
        name: ' ',
        price: 900,
        stock: 4,
        imagePath: 'cover.jpg',
        isAvailable: true,
      ),
      throwsArgumentError,
    );
    expect(
      () => controller.addProduct(
        name: 'Чехол',
        price: 0,
        stock: 4,
        imagePath: 'cover.jpg',
        isAvailable: true,
      ),
      throwsArgumentError,
    );
    expect(
      () => controller.addProduct(
        name: 'Чехол',
        price: 900,
        stock: 4,
        imagePath: ' ',
        isAvailable: true,
      ),
      throwsArgumentError,
    );
    expect(controller.products, isEmpty);
  });
}
