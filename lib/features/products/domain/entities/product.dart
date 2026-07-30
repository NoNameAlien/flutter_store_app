class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.imagePath,
    required this.isAvailable,
  }) : assert(id != ''),
       assert(name != ''),
       assert(price > 0),
       assert(stock >= 0),
       assert(imagePath != null && imagePath != '');

  final String id;
  final String name;
  final int price;
  final int stock;
  final String? imagePath;
  final bool isAvailable;

  bool get isValid =>
      id.isNotEmpty &&
      name.trim().isNotEmpty &&
      price > 0 &&
      stock >= 0 &&
      imagePath != null &&
      imagePath!.trim().isNotEmpty;

  Product copyWith({int? stock, bool? isAvailable}) => Product(
    id: id,
    name: name,
    price: price,
    stock: stock ?? this.stock,
    imagePath: imagePath,
    isAvailable: isAvailable ?? this.isAvailable,
  );
}
