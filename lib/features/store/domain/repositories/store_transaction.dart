import '../../../products/domain/entities/product.dart';
import '../../../purchases/domain/entities/purchase.dart';

/// Commits the inventory change and the purchase record as one operation.
///
/// A database or API implementation must provide a real transaction here.
abstract interface class StoreTransaction {
  void completePurchase({
    required Product updatedProduct,
    required Purchase purchase,
  });
}
