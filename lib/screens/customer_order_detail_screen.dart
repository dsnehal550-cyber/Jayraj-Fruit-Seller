import 'package:flutter/material.dart';
import '../models/customer_order.dart';

class CustomerOrderDetailScreen extends StatelessWidget {
  const CustomerOrderDetailScreen({
    required this.order,
    super.key,
  });

  final CustomerOrder order;

  Widget _buildFruitImage() {
    final imagePath = order.fruitImage;
    Widget imgWidget;

    if (imagePath.startsWith('http')) {
      imgWidget = Image.network(
        imagePath,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 80,
          height: 80,
          color: const Color(0xFF2E8B57).withValues(alpha: 0.18),
          child: const Icon(Icons.shopping_bag_rounded, color: Color(0xFF2E8B57), size: 36),
        ),
      );
    } else {
      imgWidget = Image.asset(
        imagePath,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          width: 80,
          height: 80,
          color: const Color(0xFF2E8B57).withValues(alpha: 0.18),
          child: const Icon(Icons.shopping_bag_rounded, color: Color(0xFF2E8B57), size: 36),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: imgWidget,
    );
  }

  String _formatDateTime(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = _monthName(dt.month);
    final year = dt.year;
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final min = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$day $month $year, $hour:$min $ampm';
  }

  String _monthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1) % 12];
  }

  @override
  Widget build(BuildContext context) {
    final qtyStr = order.quantity % 1 == 0
        ? order.quantity.toInt().toString()
        : order.quantity.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Details'),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ORDER ID & STATUS BADGE
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          order.orderId,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF1F2A1F),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9F7EC),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order.status,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2E8B57),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Placed on ${_formatDateTime(order.orderDateTime)}',
                      style: const TextStyle(fontSize: 13, color: Color(0xFF5B6E5F)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ORDER ITEM CARD
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    _buildFruitImage(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.fruitName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2A1F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${order.pricePerKg.toStringAsFixed(0)} / kg',
                            style: const TextStyle(fontSize: 14, color: Color(0xFF5B6E5F)),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quantity: $qtyStr kg',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2E8B57),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // PAYMENT & ADDRESS DETAILS
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow('Item Cost', '₹${(order.quantity * order.pricePerKg).toStringAsFixed(0)}'),
                    _buildRow('Delivery Charge', '₹0'),
                    _buildRow('Total Amount', '₹${order.totalAmount.toStringAsFixed(0)}', isBold: true),
                    const Divider(height: 24),
                    _buildRow('Payment Method', order.paymentMethod),
                    const SizedBox(height: 12),
                    const Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2A1F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order.deliveryAddress,
                      style: const TextStyle(fontSize: 14, color: Color(0xFF5B6E5F), height: 1.3),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ORDER STATUS TIMELINE
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Tracker',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2A1F),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildStatusStep('Order Placed', 'Order received by seller', isDone: true, isCurrent: order.status == 'Order Placed'),
                    _buildStatusStep('Confirmed', 'Seller accepted order', isDone: order.status == 'Confirmed' || order.status == 'Out for Delivery' || order.status == 'Delivered', isCurrent: order.status == 'Confirmed'),
                    _buildStatusStep('Out for Delivery', 'Order is on the way', isDone: order.status == 'Out for Delivery' || order.status == 'Delivered', isCurrent: order.status == 'Out for Delivery'),
                    _buildStatusStep('Delivered', 'Order delivered successfully', isDone: order.status == 'Delivered', isCurrent: order.status == 'Delivered', isLast: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: const Color(0xFF1F2A1F),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 16 : 14,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: isBold ? const Color(0xFF2E8B57) : const Color(0xFF1F2A1F),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusStep(String title, String subtitle, {required bool isDone, required bool isCurrent, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isDone ? const Color(0xFF2E8B57) : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: isDone
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: isDone ? const Color(0xFF2E8B57) : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: isCurrent ? FontWeight.w900 : (isDone ? FontWeight.w700 : FontWeight.w500),
                  color: isDone ? const Color(0xFF1F2A1F) : Colors.grey[600],
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}
