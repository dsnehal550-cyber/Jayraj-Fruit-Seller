import 'package:flutter/material.dart';
import '../models/fruit_item.dart';

class FruitDetailSheet extends StatefulWidget {
  const FruitDetailSheet({
    required this.fruit,
    required this.onAddToCart,
    super.key,
  });

  final FruitItem fruit;
  final void Function(FruitItem fruit, double quantity) onAddToCart;

  @override
  State<FruitDetailSheet> createState() => _FruitDetailSheetState();
}

class _FruitDetailSheetState extends State<FruitDetailSheet> {
  final TextEditingController _quantityController = TextEditingController(text: '1');
  double _enteredQuantity = 1.0;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _validateQuantity(_quantityController.text);
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _validateQuantity(String text) {
    setState(() {
      final parsed = double.tryParse(text.trim());
      if (parsed == null || parsed <= 0) {
        _enteredQuantity = 0.0;
        _errorMessage = 'Please enter a valid quantity in kg (e.g. 0.5, 1.25, 2.5)';
      } else if (parsed > widget.fruit.stockQuantity) {
        _enteredQuantity = parsed;
        _errorMessage = 'Requested quantity (${parsed.toStringAsFixed(2)} kg) exceeds available stock (${widget.fruit.stockQuantity.toStringAsFixed(1)} kg)';
      } else {
        _enteredQuantity = parsed;
        _errorMessage = null;
      }
    });
  }

  double get calculatedTotal => _enteredQuantity * widget.fruit.pricePerKg;

  bool get isAddToCartEnabled {
    return widget.fruit.isAvailable && _errorMessage == null && _enteredQuantity > 0;
  }

  @override
  Widget build(BuildContext context) {
    final fruit = widget.fruit;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF5F7F2),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: fruit.accentColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(fruit.icon, color: fruit.accentColor, size: 38),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fruit.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2A1F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${fruit.pricePerKg.toStringAsFixed(0)} / kg',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E8B57),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: fruit.isAvailable
                              ? const Color(0xFFE9F7EC)
                              : const Color(0xFFFDE8E8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          fruit.isAvailable
                              ? 'In Stock (${fruit.stockQuantity.toStringAsFixed(1)} kg available)'
                              : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: fruit.isAvailable
                                ? const Color(0xFF2E8B57)
                                : Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2A1F),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              fruit.description,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5B6E5F),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Enter Quantity (in kg)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2A1F),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              key: const Key('fruit_quantity_input'),
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              enabled: fruit.isAvailable,
              onChanged: _validateQuantity,
              decoration: InputDecoration(
                hintText: 'e.g. 0.5, 1.25, 2.5',
                suffixText: 'kg',
                suffixStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E8B57),
                ),
                prefixIcon: const Icon(Icons.scale_rounded, color: Color(0xFF2E8B57)),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF2E8B57), width: 1.5),
                ),
              ),
            ),
            if (_errorMessage != null && fruit.isAvailable) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Price:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2A1F),
                    ),
                  ),
                  Text(
                    '₹${calculatedTotal.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF2E8B57),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                key: const Key('add_to_cart_confirm_button'),
                onPressed: isAddToCartEnabled
                    ? () {
                        widget.onAddToCart(fruit, _enteredQuantity);
                        Navigator.of(context).pop();
                      }
                    : null,
                icon: const Icon(Icons.add_shopping_cart_rounded),
                label: Text(
                  fruit.isAvailable ? 'Add to Cart' : 'Out of Stock',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E8B57),
                  disabledBackgroundColor: Colors.grey[400],
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
