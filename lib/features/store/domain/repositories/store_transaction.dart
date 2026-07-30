import '../../../products/domain/entities/product.dart';
import '../../../purchases/domain/entities/purchase.dart';

abstract interface class StoreTransaction {
  void completePurchase({
    required Product updatedProduct,
    required Purchase purchase,
  });
}
