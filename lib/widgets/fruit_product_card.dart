import 'package:flutter/material.dart';
import '../models/fruit_item.dart';

class FruitProductCard extends StatelessWidget {
  const FruitProductCard({
    required this.fruit,
    required this.onTap,
    required this.onAddToCartDirect,
    super.key,
  });

  final FruitItem fruit;
  final VoidCallback onTap;
  final VoidCallback onAddToCartDirect;

  Widget _buildFruitImage() {
    final imagePath = fruit.image;
    Widget imageWidget;

    if (imagePath.startsWith('http')) {
      imageWidget = Image.network(
        imagePath,
        width: 85,
        height: 85,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 85,
            height: 85,
            color: fruit.accentColor.withValues(alpha: 0.18),
            child: Icon(fruit.icon, color: fruit.accentColor, size: 40),
          );
        },
      );
    } else {
      imageWidget = Image.asset(
        imagePath,
        width: 85,
        height: 85,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 85,
            height: 85,
            color: fruit.accentColor.withValues(alpha: 0.18),
            child: Icon(fruit.icon, color: fruit.accentColor, size: 40),
          );
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: imageWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // LEFT: Actual Fruit Photo
            _buildFruitImage(),
            const SizedBox(width: 14),
            // RIGHT: Details Column (Fruit Name, Price per kg, Stock/availability, Add button)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fruit.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2A1F),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '₹${fruit.pricePerKg.toStringAsFixed(0)} / kg',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2E8B57),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: fruit.isAvailable
                          ? const Color(0xFFE9F7EC)
                          : const Color(0xFFFDE8E8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      fruit.isAvailable
                          ? 'In Stock (${fruit.stockQuantity.toStringAsFixed(1)} kg)'
                          : 'Out of Stock',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: fruit.isAvailable
                            ? const Color(0xFF2E8B57)
                            : Colors.red[700],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      key: ValueKey('add_to_cart_${fruit.name}'),
                      onPressed: fruit.isAvailable ? onTap : null,
                      icon: Icon(
                        fruit.isAvailable ? Icons.add_rounded : Icons.block_rounded,
                        size: 18,
                      ),
                      label: Text(fruit.isAvailable ? 'Add' : 'Out of Stock'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2E8B57),
                        disabledBackgroundColor: Colors.grey[300],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
