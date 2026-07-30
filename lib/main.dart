import 'package:flutter/widgets.dart';

import 'app/store_app.dart';
import 'features/products/data/repositories/memory_product_repository.dart';
import 'features/purchases/data/repositories/memory_purchase_repository.dart';
import 'features/store/application/store_controller.dart';
import 'features/store/data/repositories/memory_store_transaction.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final productRepository = MemoryProductRepository();
  final purchaseRepository = MemoryPurchaseRepository();
  runApp(
    StoreApp(
      controller: StoreController(
        productRepository: productRepository,
        purchaseRepository: purchaseRepository,
        transaction: MemoryStoreTransaction(
          productRepository: productRepository,
          purchaseRepository: purchaseRepository,
        ),
      ),
    ),
  );
}
