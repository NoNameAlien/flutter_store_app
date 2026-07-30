import '../entities/product.dart';

abstract interface class ProductRepository {
  List<Product> getProducts();
  void add(Product product);
  void update(Product product);
  void delete(String productId);
}
