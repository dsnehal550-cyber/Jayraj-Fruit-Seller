import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import '../models/customer_address.dart';
import '../services/delivery_availability_service.dart';
import '../services/location_service.dart';
import 'address_form_screen.dart';

typedef CartOrderPlacement = Future<void> Function(
  CustomerAddress address,
  String paymentMethod,
);

class CartDeliveryAddressScreen extends StatefulWidget {
  const CartDeliveryAddressScreen({
    required this.cart,
    required this.onPlaceOrder,
    this.initialAddress,
    this.returnAddressOnly = false,
    super.key,
  });

  final List<CartItem> cart;
  final CartOrderPlacement onPlaceOrder;
  final CustomerAddress? initialAddress;
  final bool returnAddressOnly;

  @override
  State<CartDeliveryAddressScreen> createState() =>
      _CartDeliveryAddressScreenState();
}

class _CartDeliveryAddressScreenState extends State<CartDeliveryAddressScreen> {
  CustomerAddress? _address;
  bool _isLoading = true;
  bool _isGettingLocation = false;
  bool _isCheckingDelivery = false;

  @override
  void initState() {
    super.initState();
    _loadAddress();
  }

  Future<void> _loadAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final savedJson = prefs.getString('customer_saved_address');
    CustomerAddress? address = widget.initialAddress;
    if (savedJson != null && savedJson.isNotEmpty) {
      try {
        address = CustomerAddress.fromJson(
          jsonDecode(savedJson) as Map<String, dynamic>,
        );
      } on FormatException {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The saved address could not be read.')),
        );
      } on TypeError {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('The saved address could not be read.')),
        );
      }
    }
    if (!mounted) return;
    setState(() {
      _address = address;
      _isLoading = false;
    });
  }

  Future<void> _editAddress() async {
    final updated = await Navigator.of(context).push<CustomerAddress>(
      MaterialPageRoute<CustomerAddress>(
        builder: (context) => AddressFormScreen(initialAddress: _address),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _address = updated);
    }
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isGettingLocation = true);
    final position = await LocationService.requestPermissionAndGetLocation();
    if (!mounted) return;
    if (position == null) {
      setState(() => _isGettingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Current location is unavailable. Enable location access or enter an address manually.',
          ),
        ),
      );
      return;
    }

    final reverseGeocodedAddress =
        await LocationService.getAddressFromCoordinates(
          position.latitude,
          position.longitude,
        );
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final previousAddress = _address;
    final mobile = previousAddress?.mobile.trim().isNotEmpty == true
        ? previousAddress!.mobile
        : (prefs.getString('customer_mobile') ?? '');
    final street = reverseGeocodedAddress?.trim().isNotEmpty == true
        ? reverseGeocodedAddress!.trim()
        : 'Current location (${position.latitude.toStringAsFixed(5)}, '
              '${position.longitude.toStringAsFixed(5)})';
    final address = CustomerAddress(
      name: previousAddress?.name.trim().isNotEmpty == true
          ? previousAddress!.name
          : 'Customer',
      mobile: mobile,
      house: '',
      street: street,
      city: defaultCustomerCity,
      pin: '',
      latitude: position.latitude,
      longitude: position.longitude,
    );
    await prefs.setString(
      'customer_saved_address',
      jsonEncode(address.toJson()),
    );
    if (!mounted) return;
    setState(() {
      _address = address;
      _isGettingLocation = false;
    });
  }

  bool _hasRequiredAddress(CustomerAddress address) {
    final latitude = address.latitude;
    final longitude = address.longitude;
    return address.name.trim().isNotEmpty &&
        address.mobile.trim().isNotEmpty &&
        address.street.trim().isNotEmpty &&
        latitude != null &&
        longitude != null &&
        latitude.isFinite &&
        longitude.isFinite &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  String _formatAddress(CustomerAddress address) {
    return [
      address.name,
      address.house,
      address.street,
      address.landmark ?? '',
      address.city,
      address.pin,
      address.mobile,
    ].where((part) => part.trim().isNotEmpty).join(', ');
  }

  Future<void> _continueToPayment() async {
    final address = _address;
    if (address == null || !_hasRequiredAddress(address)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Add a valid delivery address with contact details and a mapped location before continuing.',
          ),
        ),
      );
      return;
    }

    setState(() => _isCheckingDelivery = true);
    final availability =
        await DeliveryAvailabilityService.checkDeliveryAvailability(
          customerLat: address.latitude!,
          customerLng: address.longitude!,
        );
    if (!mounted) return;
    setState(() => _isCheckingDelivery = false);

    if (!availability.isAvailable) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delivery Unavailable'),
          content: Text(availability.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    if (widget.returnAddressOnly) {
      Navigator.of(context).pop(address);
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => CartPaymentMethodScreen(
          cart: widget.cart,
          address: address,
          onPlaceOrder: widget.onPlaceOrder,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final address = _address;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Address'),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F7F2),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF2E8B57)),
              )
            : ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const Text(
                    'Choose where to deliver',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2A1F),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Delivery distance is checked before payment.',
                    style: TextStyle(color: Color(0xFF5B6E5F)),
                  ),
                  const SizedBox(height: 20),
                  if (address != null)
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
                          const Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: Color(0xFF2E8B57),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Selected address',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(_formatAddress(address)),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _editAddress,
                            icon: const Icon(Icons.edit_location_alt_rounded),
                            label: const Text('Change address'),
                          ),
                        ],
                      ),
                    )
                  else
                    const Text('No delivery address has been saved yet.'),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _isGettingLocation ? null : _useCurrentLocation,
                    icon: _isGettingLocation
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.my_location_rounded),
                    label: const Text('Use current location'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _editAddress,
                    icon: const Icon(Icons.edit_location_alt_rounded),
                    label: Text(
                      address == null
                          ? 'Enter address manually'
                          : 'Edit address manually',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      key: const Key('continue_to_payment_button'),
                      onPressed: _isCheckingDelivery
                          ? null
                          : _continueToPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E8B57),
                        foregroundColor: Colors.white,
                      ),
                      child: _isCheckingDelivery
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Check Delivery & Continue'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class CartPaymentMethodScreen extends StatefulWidget {
  const CartPaymentMethodScreen({
    required this.cart,
    required this.address,
    required this.onPlaceOrder,
    super.key,
  });

  final List<CartItem> cart;
  final CustomerAddress address;
  final CartOrderPlacement onPlaceOrder;

  @override
  State<CartPaymentMethodScreen> createState() =>
      _CartPaymentMethodScreenState();
}

class _CartPaymentMethodScreenState extends State<CartPaymentMethodScreen> {
  static const _paymentOptions = [
    'PhonePe',
    'Google Pay',
    'UPI QR',
    'Cash on Delivery (COD)',
  ];

  String _selectedPaymentMethod = 'Cash on Delivery (COD)';
  CustomerAddress? _address;
  bool _isPlacingOrder = false;

  @override
  void initState() {
    super.initState();
    _address = widget.address;
  }

  Future<void> _changeAddress() async {
    final updated = await Navigator.of(context).push<CustomerAddress>(
      MaterialPageRoute<CustomerAddress>(
        builder: (context) => CartDeliveryAddressScreen(
          cart: widget.cart,
          onPlaceOrder: widget.onPlaceOrder,
          initialAddress: _address,
          returnAddressOnly: true,
        ),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _address = updated);
    }
  }

  Future<void> _placeOrder() async {
    if (_isPlacingOrder) return;
    if (!_paymentOptions.contains(_selectedPaymentMethod)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a valid payment method.')),
      );
      return;
    }
    if (_selectedPaymentMethod != 'Cash on Delivery (COD)') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Online payment verification is not configured. No order was placed.',
          ),
        ),
      );
      return;
    }

    final address = _address;
    if (address?.latitude == null || address?.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'The delivery location is missing. Change the address and try again.',
          ),
        ),
      );
      return;
    }

    setState(() => _isPlacingOrder = true);
    final availability =
        await DeliveryAvailabilityService.checkDeliveryAvailability(
          customerLat: address!.latitude!,
          customerLng: address.longitude!,
        );
    if (!mounted) return;
    if (!availability.isAvailable) {
      setState(() => _isPlacingOrder = false);
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delivery Unavailable'),
          content: Text(availability.message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    try {
      await widget.onPlaceOrder(address, _selectedPaymentMethod);
    } finally {
      if (mounted) setState(() => _isPlacingOrder = false);
    }
  }

  String _formatAddress(CustomerAddress address) {
    return [
      address.name,
      address.house,
      address.street,
      address.landmark ?? '',
      address.city,
      address.pin,
      address.mobile,
    ].where((part) => part.trim().isNotEmpty).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final address = _address!;
    final subtotal = widget.cart.fold<double>(
      0,
      (sum, item) => sum + item.subtotal,
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method'),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFFF5F7F2),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Select payment method',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 16),
            RadioGroup<String>(
              groupValue: _selectedPaymentMethod,
              onChanged: (value) {
                if (value != null && !_isPlacingOrder) {
                  setState(() => _selectedPaymentMethod = value);
                }
              },
              child: Column(
                children: [
                  for (final option in _paymentOptions)
                    Card(
                      color: Colors.white,
                      child: RadioListTile<String>(
                        value: option,
                        activeColor: const Color(0xFF2E8B57),
                        title: Text(option),
                      ),
                    ),
                ],
              ),
            ),
            if (_selectedPaymentMethod == 'UPI QR')
              const Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'UPI QR payment is not connected to a verified payment provider. An order cannot be placed using this option.',
                  ),
                ),
              ),
            if (_selectedPaymentMethod == 'PhonePe' ||
                _selectedPaymentMethod == 'Google Pay')
              const Card(
                color: Colors.white,
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Online payment verification is not configured. An order cannot be placed until a verified payment integration is available.',
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Card(
              color: Colors.white,
              child: ListTile(
                title: const Text('Delivering to'),
                subtitle: Text(_formatAddress(address)),
                trailing: TextButton(
                  onPressed: _isPlacingOrder ? null : _changeAddress,
                  child: const Text('Change'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              color: Colors.white,
              child: ListTile(
                title: const Text('Order total'),
                trailing: Text('₹${subtotal.toStringAsFixed(2)}'),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: ElevatedButton(
                key: const Key('place_order_button'),
                onPressed: _isPlacingOrder ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E8B57),
                  foregroundColor: Colors.white,
                ),
                child: _isPlacingOrder
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
