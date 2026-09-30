import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/customer_address.dart';
import '../models/customer_order.dart';
import '../models/fruit_item.dart';
import '../services/delivery_availability_service.dart';
import '../services/order_storage_service.dart';
import 'address_form_screen.dart';
import 'customer_orders_screen.dart';

class DirectOrderConfirmationScreen extends StatelessWidget {
  const DirectOrderConfirmationScreen({
    required this.fruit,
    required this.quantity,
    super.key,
  });

  final FruitItem fruit;
  final double quantity;

  double get total => quantity * fruit.pricePerKg;

  Widget _buildFruitImage() {
    final imagePath = fruit.image;
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
          color: fruit.accentColor.withValues(alpha: 0.18),
          child: Icon(fruit.icon, color: fruit.accentColor, size: 36),
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
          color: fruit.accentColor.withValues(alpha: 0.18),
          child: Icon(fruit.icon, color: fruit.accentColor, size: 36),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: imgWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    final qtyStr = quantity % 1 == 0
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
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
              const Text(
                'Review Your Order',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2A1F),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Please verify your selected item details before proceeding to payment.',
                style: TextStyle(fontSize: 14, color: Color(0xFF5B6E5F)),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
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
                child: Row(
                  children: [
                    _buildFruitImage(),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fruit.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2A1F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${fruit.pricePerKg.toStringAsFixed(0)} / kg',
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF5B6E5F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Quantity: $qtyStr kg',
                            style: const TextStyle(
                              fontSize: 15,
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
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Fruit Name', fruit.name),
                    _buildDetailRow('Price per kg', '₹${fruit.pricePerKg.toStringAsFixed(0)}'),
                    _buildDetailRow('Quantity', '$qtyStr kg'),
                    const Divider(height: 24),
                    _buildDetailRow(
                      'Total Price',
                      '₹${total.toStringAsFixed(0)}',
                      isBold: true,
                      color: const Color(0xFF2E8B57),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  key: const Key('confirm_order_button'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (context) => DirectPaymentScreen(
                          fruit: fruit,
                          quantity: quantity,
                          total: total,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E8B57),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'CONFIRM ORDER',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: const Color(0xFF1F2A1F),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 15,
              fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
              color: color ?? const Color(0xFF1F2A1F),
            ),
          ),
        ],
      ),
    );
  }
}

class DirectPaymentScreen extends StatefulWidget {
  const DirectPaymentScreen({
    required this.fruit,
    required this.quantity,
    required this.total,
    super.key,
  });

  final FruitItem fruit;
  final double quantity;
  final double total;

  @override
  State<DirectPaymentScreen> createState() => _DirectPaymentScreenState();
}

class _DirectPaymentScreenState extends State<DirectPaymentScreen> {
  String _selectedMainCategory = 'Online Payment';
  String? _selectedOnlineSubOption = 'PhonePe';

  String get _finalPaymentMethodString {
    if (_selectedMainCategory == 'Cash on Delivery') {
      return 'Cash on Delivery (COD)';
    }
    switch (_selectedOnlineSubOption) {
      case 'PhonePe':
        return 'Online Payment - PhonePe';
      case 'GPay':
        return 'Online Payment - Google Pay (GPay)';
      case 'UPI QR Code':
        return 'Online Payment - UPI QR Code';
      default:
        return 'Online Payment';
    }
  }

  void _onContinue() {
    if (_selectedMainCategory == 'Online Payment' && _selectedOnlineSubOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an online payment option (PhonePe, GPay, or UPI QR Code).'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => DirectDeliveryAddressScreen(
          fruit: widget.fruit,
          quantity: widget.quantity,
          total: widget.total,
          paymentMethod: _finalPaymentMethodString,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOnlineSelected = _selectedMainCategory == 'Online Payment';
    final isCodSelected = _selectedMainCategory == 'Cash on Delivery';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method'),
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
              const Text(
                'Select Payment Method',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2A1F),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose your preferred payment method to complete the order.',
                style: TextStyle(fontSize: 14, color: Color(0xFF5B6E5F)),
              ),
              const SizedBox(height: 20),

              // MAIN CATEGORY 1: ONLINE PAYMENT
              _buildMainCategoryTile(
                title: 'Online Payment',
                subtitle: 'Pay via PhonePe, Google Pay (GPay), or UPI QR',
                icon: Icons.account_balance_wallet_rounded,
                isSelected: isOnlineSelected,
                onTap: () {
                  setState(() {
                    _selectedMainCategory = 'Online Payment';
                    _selectedOnlineSubOption ??= 'PhonePe';
                  });
                },
              ),

              // SUB-OPTIONS FOR ONLINE PAYMENT
              if (isOnlineSelected) ...[
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4, bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Online Payment Option:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF5B6E5F),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // PhonePe Option
                      _buildSubOptionTile(
                        key: const Key('online_sub_phonepe'),
                        title: 'PhonePe',
                        subtitle: 'Instant simulated payment via PhonePe',
                        icon: Icons.flash_on_rounded,
                        accentColor: const Color(0xFF5F259F),
                        value: 'PhonePe',
                      ),

                      // Google Pay Option
                      _buildSubOptionTile(
                        key: const Key('online_sub_gpay'),
                        title: 'Google Pay (GPay)',
                        subtitle: 'Instant simulated payment via Google Pay',
                        icon: Icons.payment_rounded,
                        accentColor: const Color(0xFF4285F4),
                        value: 'GPay',
                      ),

                      // UPI QR Code Option
                      _buildSubOptionTile(
                        key: const Key('online_sub_upi_qr'),
                        title: 'UPI QR Code',
                        subtitle: 'Scan demo QR code with any UPI app',
                        icon: Icons.qr_code_2_rounded,
                        accentColor: const Color(0xFF2E8B57),
                        value: 'UPI QR Code',
                      ),

                      // DEMO QR CODE DISPLAY WHEN UPI QR CODE IS SELECTED
                      if (_selectedOnlineSubOption == 'UPI QR Code') ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF2E8B57), width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2E8B57).withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F7F2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Column(
                                  children: const [
                                    Icon(
                                      Icons.qr_code_2_rounded,
                                      size: 140,
                                      color: Color(0xFF1F2A1F),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'DEMO UPI QR CODE',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 1.1,
                                        color: Color(0xFF2E8B57),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF3CD),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'Demo QR Code for simulation only. Do not scan with real banking app.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF856404),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 4),

              // MAIN CATEGORY 2: CASH ON DELIVERY
              _buildMainCategoryTile(
                title: 'Cash on Delivery (COD)',
                subtitle: 'Pay cash when your fresh fruits are delivered',
                icon: Icons.payments_rounded,
                isSelected: isCodSelected,
                onTap: () {
                  setState(() {
                    _selectedMainCategory = 'Cash on Delivery';
                  });
                },
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F7EC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.info_outline_rounded, color: Color(0xFF2E8B57)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Note: All payment selections operate in local demo mode.',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2E8B57),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  key: const Key('continue_to_address_button'),
                  onPressed: _onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E8B57),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continue to Delivery Address',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainCategoryTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E8B57) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? const Color(0xFF2E8B57) : Colors.grey[400],
            ),
            const SizedBox(width: 14),
            Icon(icon, color: const Color(0xFF2E8B57), size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2A1F),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF5B6E5F),
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

  Widget _buildSubOptionTile({
    required Key key,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String value,
  }) {
    final isSelected = _selectedOnlineSubOption == value;
    return InkWell(
      key: key,
      onTap: () {
        setState(() {
          _selectedMainCategory = 'Online Payment';
          _selectedOnlineSubOption = value;
        });
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.08) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? accentColor : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? accentColor : Colors.grey[400],
              size: 20,
            ),
            const SizedBox(width: 12),
            Icon(icon, color: accentColor, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? accentColor : const Color(0xFF1F2A1F),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF5B6E5F),
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

class DirectDeliveryAddressScreen extends StatefulWidget {
  const DirectDeliveryAddressScreen({
    required this.fruit,
    required this.quantity,
    required this.total,
    required this.paymentMethod,
    super.key,
  });

  final FruitItem fruit;
  final double quantity;
  final double total;
  final String paymentMethod;

  @override
  State<DirectDeliveryAddressScreen> createState() => _DirectDeliveryAddressScreenState();
}

class _DirectDeliveryAddressScreenState extends State<DirectDeliveryAddressScreen> {
  bool _isSubmitting = false;
  CustomerAddress? _savedAddress;
  bool _isLoadingAddress = true;

  @override
  void initState() {
    super.initState();
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedJson = prefs.getString('customer_saved_address');
    if (savedJson != null && savedJson.isNotEmpty) {
      try {
        final data = jsonDecode(savedJson) as Map<String, dynamic>;
        setState(() {
          _savedAddress = CustomerAddress.fromJson(data);
        });
      } catch (_) {}
    }
    setState(() => _isLoadingAddress = false);
  }

  Future<void> _placeOrder() async {
    if (_isSubmitting) return;

    if (_savedAddress == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add a delivery address')));
      return;
    }

    setState(() => _isSubmitting = true);

    // Delivery Availability Check
    final lat = _savedAddress!.latitude;
    final lng = _savedAddress!.longitude;

    if (lat == null || lng == null) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location missing. Please update your address.')));
      return;
    }

    final availability = await DeliveryAvailabilityService.checkDeliveryAvailability(customerLat: lat, customerLng: lng);

    if (!availability.isAvailable) {
      setState(() => _isSubmitting = false);
      if (!mounted) return;
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Delivery Unavailable'),
          content: Text(availability.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final finalAddress = _savedAddress!.toFormattedString();
    final orderId = 'JFS-ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}';
    
    final newOrder = CustomerOrder(
      orderId: orderId,
      orderDateTime: DateTime.now(),
      fruitName: widget.fruit.name,
      fruitImage: widget.fruit.image,
      quantity: widget.quantity,
      pricePerKg: widget.fruit.pricePerKg,
      totalAmount: widget.total, // Delivery is 0, so total is untouched.
      paymentMethod: widget.paymentMethod,
      deliveryAddress: finalAddress,
      status: 'Order Placed',
    );

    await OrderStorageService.saveOrder(newOrder);

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => DirectOrderSuccessScreen(
          fruit: widget.fruit,
          quantity: widget.quantity,
          total: widget.total,
          paymentMethod: widget.paymentMethod,
          deliveryAddress: finalAddress,
          orderId: orderId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Address'),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F7F2),
      body: SafeArea(
        child: _isLoadingAddress
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2E8B57)))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2A1F),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Provide your address details to complete your order.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF5B6E5F)),
                    ),
                    const SizedBox(height: 20),
                    if (_savedAddress != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF2E8B57),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.radio_button_checked_rounded,
                                  color: Color(0xFF2E8B57),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Saved Address',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1F2A1F),
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () async {
                                    final updated = await Navigator.of(context).push<CustomerAddress>(
                                      MaterialPageRoute(builder: (context) => const AddressFormScreen()),
                                    );
                                    if (updated != null) {
                                      setState(() => _savedAddress = updated);
                                    }
                                  },
                                  child: const Text('Edit'),
                                )
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 32, top: 4, bottom: 8),
                              child: Text(
                                _savedAddress!.toFormattedString(),
                                style: const TextStyle(fontSize: 14, color: Color(0xFF5B6E5F)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.location_off_rounded, size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            const Text('No address saved', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final newAddress = await Navigator.of(context).push<CustomerAddress>(
                                  MaterialPageRoute(builder: (context) => const AddressFormScreen()),
                                );
                                if (newAddress != null) {
                                  setState(() => _savedAddress = newAddress);
                                }
                              },
                              icon: const Icon(Icons.add_location_alt_rounded),
                              label: const Text('Add Delivery Address'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2E8B57),
                                foregroundColor: Colors.white,
                              ),
                            )
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        key: const Key('place_order_button'),
                        onPressed: _isSubmitting ? null : _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E8B57),
                          disabledBackgroundColor: Colors.grey[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          _isSubmitting ? 'Checking Availability...' : 'PLACE ORDER',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class DirectOrderSuccessScreen extends StatelessWidget {
  const DirectOrderSuccessScreen({
    required this.fruit,
    required this.quantity,
    required this.total,
    required this.paymentMethod,
    required this.deliveryAddress,
    this.orderId,
    super.key,
  });

  final FruitItem fruit;
  final double quantity;
  final double total;
  final String paymentMethod;
  final String deliveryAddress;
  final String? orderId;

  @override
  Widget build(BuildContext context) {
    final qtyStr = quantity % 1 == 0
        ? quantity.toInt().toString()
        : quantity.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Container(
                width: 90,
                height: 90,
                decoration: const BoxDecoration(
                  color: Color(0xFFE9F7EC),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF2E8B57),
                  size: 64,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Order placed successfully',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2A1F),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Thank you for ordering fresh fruits with Jayraj Fruit Seller!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Color(0xFF5B6E5F)),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2A1F),
                      ),
                    ),
                    const Divider(height: 20),
                    if (orderId != null) _buildRow('Order ID', orderId!),
                    _buildRow('Item Ordered', '${fruit.name} × $qtyStr kg'),
                    _buildRow('Price per kg', '₹${fruit.pricePerKg.toStringAsFixed(0)} / kg'),
                    _buildRow('Delivery Charge', '₹0'),
                    _buildRow('Total Paid / Due', '₹${total.toStringAsFixed(0)}', isBold: true),
                    _buildRow('Payment Method', '$paymentMethod (Demo)'),
                    _buildRow('Delivery Address', deliveryAddress),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F7EC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Demo / Local order placed successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF2E8B57),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  key: const Key('view_my_orders_button'),
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute<void>(
                        builder: (context) => const CustomerOrdersScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.receipt_long_rounded),
                  label: const Text(
                    'View My Orders',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E8B57),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E8B57),
                    side: const BorderSide(color: Color(0xFF2E8B57), width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Back to Customer Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isBold ? FontWeight.w900 : FontWeight.w700,
                color: isBold ? const Color(0xFF2E8B57) : const Color(0xFF1F2A1F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
