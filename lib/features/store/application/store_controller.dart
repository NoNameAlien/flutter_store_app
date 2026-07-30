import 'package:flutter/foundation.dart';

import '../../products/domain/entities/product.dart';
import '../../products/domain/repositories/product_repository.dart';
import '../../purchases/domain/entities/purchase.dart';
import '../../purchases/domain/repositories/purchase_repository.dart';
import '../domain/repositories/store_transaction.dart';

enum PurchaseResult {
  success,
  productNotFound,
  unavailable,
  outOfStock,
  invalidProduct,
  storageError,
}

class StoreController extends ChangeNotifier {
  StoreController({
    required ProductRepository productRepository,
    required PurchaseRepository purchaseRepository,
    required StoreTransaction transaction,
  }) : _productRepository = productRepository,
       _purchaseRepository = purchaseRepository,
       _transaction = transaction;

  final ProductRepository _productRepository;
  final PurchaseRepository _purchaseRepository;
  final StoreTransaction _transaction;
  int _nextId = 0;

  List<Product> get products => _productRepository.getProducts();
  List<Product> get catalogProducts =>
      products.where((product) => product.isAvailable).toList();
  List<Purchase> get purchases =>
      _purchaseRepository.getPurchases().reversed.toList();

  void addProduct({
    required String name,
    required int price,
    required int stock,
    required String imagePath,
    required bool isAvailable,
  }) {
    final normalizedName = name.trim();
    final normalizedImagePath = imagePath.trim();
    if (normalizedName.isEmpty) {
      throw ArgumentError.value(
        name,
        'name',
        'Название товара не может быть пустым.',
      );
    }
    if (price <= 0) {
      throw ArgumentError.value(
        price,
        'price',
        'Цена должна быть больше нуля.',
      );
    }
    if (stock < 0) {
      throw ArgumentError.value(
        stock,
        'stock',
        'Остаток не может быть отрицательным.',
      );
    }
    if (normalizedImagePath.isEmpty) {
      throw ArgumentError.value(
        imagePath,
        'imagePath',
        'Выберите изображение товара.',
      );
    }

    _productRepository.add(
      Product(
        id: _newId(),
        name: normalizedName,
        price: price,
        stock: stock,
        imagePath: normalizedImagePath,
        isAvailable: isAvailable,
      ),
    );
    notifyListeners();
  }

  void changeStock(String productId, int delta) {
    final product = _findProduct(productId);
    if (product == null) return;
    _ensureValidProduct(product);
    final nextStock = product.stock + delta;
    if (nextStock < 0) return;
    _productRepository.update(product.copyWith(stock: nextStock));
    notifyListeners();
  }

  void changeAvailability(String productId, bool isAvailable) {
    final product = _findProduct(productId);
    if (product == null) return;
    _ensureValidProduct(product);
    _productRepository.update(product.copyWith(isAvailable: isAvailable));
    notifyListeners();
  }

  void deleteProduct(String productId) {
    _productRepository.delete(productId);
    notifyListeners();
  }

  PurchaseResult buy(String productId) {
    final product = _findProduct(productId);
    if (product == null) return PurchaseResult.productNotFound;
    if (!product.isValid) return PurchaseResult.invalidProduct;
    if (!product.isAvailable) return PurchaseResult.unavailable;
    if (product.stock == 0) return PurchaseResult.outOfStock;

    try {
      _transaction.completePurchase(
        updatedProduct: product.copyWith(stock: product.stock - 1),
        purchase: Purchase(
          id: _newId(),
          productName: product.name,
          quantity: 1,
          unitPrice: product.price,
          purchasedAt: DateTime.now(),
        ),
      );
    } catch (_) {
      return PurchaseResult.storageError;
    }
    notifyListeners();
    return PurchaseResult.success;
  }

  Product? _findProduct(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  void _ensureValidProduct(Product product) {
    if (!product.isValid) {
      throw StateError(
        'В хранилище находится некорректный товар: ${product.id}.',
      );
    }
  }

  String _newId() => '${DateTime.now().microsecondsSinceEpoch}-${_nextId++}';
}
