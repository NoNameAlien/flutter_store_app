import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class MemoryProductRepository implements ProductRepository {
  final List<Product> _products = [];

  @override
  void add(Product product) => _products.add(product);

  @override
  void delete(String productId) =>
      _products.removeWhere((product) => product.id == productId);

  @override
  List<Product> getProducts() => List.unmodifiable(_products);

  @override
  void update(Product product) {
    final index = _products.indexWhere((item) => item.id == product.id);
    if (index == -1) throw StateError('Товар не найден.');
    _products[index] = product;
  }
}
