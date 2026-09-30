import 'package:flutter/material.dart';
import '../models/fruit_item.dart';
import '../screens/buy_now_flow_screens.dart';

class FruitDetailsPage extends StatefulWidget {
  const FruitDetailsPage({
    required this.fruit,
    required this.onAddToCart,
    super.key,
  });

  final FruitItem fruit;
  final void Function(FruitItem fruit, double quantity) onAddToCart;

  @override
  State<FruitDetailsPage> createState() => _FruitDetailsPageState();
}

class _FruitDetailsPageState extends State<FruitDetailsPage> {
  final TextEditingController _quantityController = TextEditingController(text: '1');
  double _enteredQuantity = 1.0;
  String? _errorMessage;
  bool _isAddTapped = false;

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
        _errorMessage =
            'Requested quantity (${parsed.toStringAsFixed(2)} kg) exceeds available stock (${widget.fruit.stockQuantity.toStringAsFixed(1)} kg)';
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

  Widget _buildHeaderImage() {
    final fruit = widget.fruit;
    final imagePath = fruit.image;
    Widget imgWidget;

    if (imagePath.startsWith('http')) {
      imgWidget = Image.network(
        imagePath,
        width: double.infinity,
        height: 240,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 240,
            color: fruit.accentColor.withValues(alpha: 0.18),
            child: Icon(fruit.icon, color: fruit.accentColor, size: 80),
          );
        },
      );
    } else {
      imgWidget = Image.asset(
        imagePath,
        width: double.infinity,
        height: 240,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 240,
            color: fruit.accentColor.withValues(alpha: 0.18),
            child: Icon(fruit.icon, color: fruit.accentColor, size: 80),
          );
        },
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: imgWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final fruit = widget.fruit;

    return Scaffold(
      appBar: AppBar(
        title: Text(fruit.name),
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
              _buildHeaderImage(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      fruit.name,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2A1F),
                      ),
                    ),
                  ),
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
              const SizedBox(height: 8),
              Text(
                '₹${fruit.pricePerKg.toStringAsFixed(0)} / kg',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF2E8B57),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
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
              const SizedBox(height: 24),
              // INITIAL STATE: Show only ADD button if _isAddTapped == false
              if (!_isAddTapped) ...[
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    key: const Key('add_button'),
                    onPressed: fruit.isAvailable
                        ? () {
                            setState(() {
                              _isAddTapped = true;
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E8B57),
                      disabledBackgroundColor: Colors.grey[400],
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      fruit.isAvailable ? 'ADD' : 'Out of Stock',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                // REVEALED QUANTITY & BUY NOW SECTION
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter Quantity (in kg)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1F2A1F),
                        ),
                      ),
                      const SizedBox(height: 10),
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
                          fillColor: const Color(0xFFF5F7F2),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          border: OutlineInputBorder(
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
                      const SizedBox(height: 16),
                      Row(
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
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2E8B57),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: OutlinedButton.icon(
                                key: const Key('add_to_cart_confirm_button'),
                                onPressed: isAddToCartEnabled
                                    ? () {
                                        widget.onAddToCart(fruit, _enteredQuantity);
                                        Navigator.of(context).pop();
                                      }
                                    : null,
                                icon: const Icon(Icons.shopping_cart_outlined),
                                label: const Text('Add to Cart'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF2E8B57),
                                  side: const BorderSide(color: Color(0xFF2E8B57), width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              height: 50,
                              child: ElevatedButton.icon(
                                key: const Key('buy_now_button'),
                                onPressed: isAddToCartEnabled
                                    ? () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (context) => DirectOrderConfirmationScreen(
                                              fruit: fruit,
                                              quantity: _enteredQuantity,
                                            ),
                                          ),
                                        );
                                      }
                                    : null,
                                icon: const Icon(Icons.flash_on_rounded),
                                label: const Text(
                                  'BUY NOW',
                                  style: TextStyle(fontWeight: FontWeight.w800),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2E8B57),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
