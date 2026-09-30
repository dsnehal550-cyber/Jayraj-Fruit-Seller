class CartItem {
  CartItem({
    required this.fruitId,
    required this.fruitName,
    this.fruitImage = '',
    required this.quantity,
    required this.pricePerKg,
  });

  final String fruitId;
  final String fruitName;
  final String fruitImage;
  double quantity;
  final double pricePerKg;

  double get subtotal => double.parse((quantity * pricePerKg).toStringAsFixed(2));

  Map<String, dynamic> toJson() => {
        'fruitId': fruitId,
        'fruitName': fruitName,
        'fruitImage': fruitImage,
        'quantity': quantity,
        'pricePerKg': pricePerKg,
        'subtotal': subtotal,
      };

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      fruitId: (json['fruitId'] ?? '').toString(),
      fruitName: (json['fruitName'] ?? '').toString(),
      fruitImage: (json['fruitImage'] ?? '').toString(),
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      pricePerKg: (json['pricePerKg'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
