import '../entities/purchase.dart';

abstract interface class PurchaseRepository {
  List<Purchase> getPurchases();
  void add(Purchase purchase);
}
