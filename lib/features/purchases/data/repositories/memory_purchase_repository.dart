import '../../domain/entities/purchase.dart';
import '../../domain/repositories/purchase_repository.dart';

class MemoryPurchaseRepository implements PurchaseRepository {
  final List<Purchase> _purchases = [];

  @override
  void add(Purchase purchase) => _purchases.add(purchase);

  @override
  List<Purchase> getPurchases() => List.unmodifiable(_purchases);
}
