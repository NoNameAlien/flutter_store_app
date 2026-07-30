import 'package:flutter_store_app/features/products/domain/entities/product.dart';
import 'package:flutter_store_app/features/products/domain/repositories/product_repository.dart';
import 'package:flutter_store_app/features/purchases/domain/entities/purchase.dart';
import 'package:flutter_store_app/features/purchases/domain/repositories/purchase_repository.dart';
import 'package:flutter_store_app/features/store/application/store_controller.dart';
import 'package:flutter_store_app/features/store/domain/repositories/store_transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

class MockPurchaseRepository extends Mock implements PurchaseRepository {}

class MockStoreTransaction extends Mock implements StoreTransaction {}

void main() {
  late MockProductRepository productRepository;
  late MockPurchaseRepository purchaseRepository;
  late MockStoreTransaction transaction;
  late StoreController controller;

  setUpAll(() {
    registerFallbackValue(
      const Product(
        id: 'fallback',
        name: 'Fallback',
        price: 1,
        stock: 1,
        imagePath: 'path',
        isAvailable: true,
      ),
    );
    registerFallbackValue(
      Purchase(
        id: 'fallback',
        productName: 'Fallback',
        quantity: 1,
        unitPrice: 1,
        purchasedAt: DateTime(2026),
      ),
    );
  });

  setUp(() {
    productRepository = MockProductRepository();
    purchaseRepository = MockPurchaseRepository();
    transaction = MockStoreTransaction();
    controller = StoreController(
      productRepository: productRepository,
      purchaseRepository: purchaseRepository,
      transaction: transaction,
    );
  });

  test('successful purchase updates stock and writes a purchase record', () {
    const product = Product(
      id: 'product-1',
      name: 'Клавиатура',
      price: 3500,
      stock: 2,
      imagePath: 'keyboard.jpg',
      isAvailable: true,
    );
    when(() => productRepository.getProducts()).thenReturn([product]);
    when(
      () => transaction.completePurchase(
        updatedProduct: any(named: 'updatedProduct'),
        purchase: any(named: 'purchase'),
      ),
    ).thenReturn(null);

    expect(controller.buy(product.id), PurchaseResult.success);

    verify(
      () => transaction.completePurchase(
        updatedProduct: any(
          named: 'updatedProduct',
          that: isA<Product>().having((item) => item.stock, 'stock', 1),
        ),
        purchase: any(
          named: 'purchase',
          that: isA<Purchase>()
              .having((item) => item.productName, 'productName', 'Клавиатура')
              .having((item) => item.unitPrice, 'unitPrice', 3500),
        ),
      ),
    ).called(1);
  });

  test(
    'purchase does not write to repositories when product is unavailable',
    () {
      const product = Product(
        id: 'product-1',
        name: 'Клавиатура',
        price: 3500,
        stock: 2,
        imagePath: 'keyboard.jpg',
        isAvailable: false,
      );
      when(() => productRepository.getProducts()).thenReturn([product]);

      expect(controller.buy(product.id), PurchaseResult.unavailable);
      verifyNever(
        () => transaction.completePurchase(
          updatedProduct: any(named: 'updatedProduct'),
          purchase: any(named: 'purchase'),
        ),
      );
    },
  );
}
