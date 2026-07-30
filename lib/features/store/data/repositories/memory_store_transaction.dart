import '../../../products/domain/entities/product.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../purchases/domain/entities/purchase.dart';
import '../../../purchases/domain/repositories/purchase_repository.dart';
import '../../domain/repositories/store_transaction.dart';

class MemoryStoreTransaction implements StoreTransaction {
  MemoryStoreTransaction({
    required ProductRepository productRepository,
    required PurchaseRepository purchaseRepository,
  }) : _productRepository = productRepository,
       _purchaseRepository = purchaseRepository;

  final ProductRepository _productRepository;
  final PurchaseRepository _purchaseRepository;

  @override
  void completePurchase({
    required Product updatedProduct,
    required Purchase purchase,
  }) {
    _productRepository.update(updatedProduct);
    _purchaseRepository.add(purchase);
  }
}
