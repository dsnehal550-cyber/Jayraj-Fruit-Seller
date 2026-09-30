class CustomerOrder {
  const CustomerOrder({
    required this.orderId,
    required this.orderDateTime,
    required this.fruitName,
    required this.fruitImage,
    required this.quantity,
    required this.pricePerKg,
    required this.totalAmount,
    required this.paymentMethod,
    required this.deliveryAddress,
    this.status = 'Order Placed',
  });

  final String orderId;
  final DateTime orderDateTime;
  final String fruitName;
  final String fruitImage;
  final double quantity;
  final double pricePerKg;
  final double totalAmount;
  final String paymentMethod;
  final String deliveryAddress;
  final String status;

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'orderDateTime': orderDateTime.toIso8601String(),
        'fruitName': fruitName,
        'fruitImage': fruitImage,
        'quantity': quantity,
        'pricePerKg': pricePerKg,
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod,
        'deliveryAddress': deliveryAddress,
        'status': status,
      };

  factory CustomerOrder.fromJson(Map<String, dynamic> json) {
    return CustomerOrder(
      orderId: (json['orderId'] ?? '').toString(),
      orderDateTime: json['orderDateTime'] != null
          ? DateTime.tryParse(json['orderDateTime'].toString()) ?? DateTime.now()
          : DateTime.now(),
      fruitName: (json['fruitName'] ?? '').toString(),
      fruitImage: (json['fruitImage'] ?? '').toString(),
      quantity: (json['quantity'] is num) ? (json['quantity'] as num).toDouble() : 1.0,
      pricePerKg: (json['pricePerKg'] is num) ? (json['pricePerKg'] as num).toDouble() : 0.0,
      totalAmount: (json['totalAmount'] is num) ? (json['totalAmount'] as num).toDouble() : 0.0,
      paymentMethod: (json['paymentMethod'] ?? 'Cash on Delivery').toString(),
      deliveryAddress: (json['deliveryAddress'] ?? '').toString(),
      status: (json['status'] ?? 'Order Placed').toString(),
    );
  }
}
