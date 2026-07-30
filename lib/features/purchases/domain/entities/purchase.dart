class Purchase {
  const Purchase({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.purchasedAt,
  });

  final String id;
  final String productName;
  final int quantity;
  final int unitPrice;
  final DateTime purchasedAt;

  int get total => unitPrice * quantity;
}
