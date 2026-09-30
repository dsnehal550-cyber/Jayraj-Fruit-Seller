import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/sample_fruits.dart';
import 'models/cart_item.dart';
import 'models/customer_address.dart';
import 'models/fruit_item.dart';
import 'screens/address_form_screen.dart';
import 'screens/customer_orders_screen.dart';
import 'services/location_service.dart';
import 'widgets/fruit_details_page.dart';
import 'widgets/fruit_product_card.dart';

void main() {
  runApp(const JayrajFruitSellerApp());
}

class JayrajFruitSellerApp extends StatelessWidget {
  const JayrajFruitSellerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jayraj Fruit Seller',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E8B57),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7F2),
        useMaterial3: true,
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: const Color(0xFF1F2A1F),
          displayColor: const Color(0xFF1F2A1F),
        ),
      ),
      home: const AppSplashScreen(),
    );
  }
}

class AppSplashScreen extends StatefulWidget {
  const AppSplashScreen({super.key});

  @override
  State<AppSplashScreen> createState() => _AppSplashScreenState();
}

class _AppSplashScreenState extends State<AppSplashScreen> {
  @override
  void initState() {
    super.initState();
    _startSplash();
  }

  Future<void> _startSplash() async {
    await Future<void>.delayed(const Duration(milliseconds: 2000));
    if (!mounted) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedProfile = prefs.getString('customer_profile');
    final savedMobile = prefs.getString('customer_mobile');

    if (!mounted) {
      return;
    }

    if (savedProfile != null && savedMobile != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (context) => const CustomerHomeScreen()),
      );
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (context) => const CustomerMobileLoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 180,
              height: 180,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF90C68A).withValues(alpha: 0.28),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/jayraj_logo.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomerProfile {
  const CustomerProfile({
    required this.name,
    required this.email,
    required this.city,
  });

  final String name;
  final String email;
  final String city;

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'city': city,
      };

  factory CustomerProfile.fromJson(Map<String, dynamic> json) {
    return CustomerProfile(
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      city: (json['city'] ?? 'CSN').toString(),
    );
  }
}

class CustomerMobileLoginScreen extends StatefulWidget {
  const CustomerMobileLoginScreen({super.key});

  @override
  State<CustomerMobileLoginScreen> createState() => _CustomerMobileLoginScreenState();
}

class _CustomerMobileLoginScreenState extends State<CustomerMobileLoginScreen> {
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final ValueNotifier<bool> _otpSent = ValueNotifier<bool>(false);
  final ValueNotifier<String> _generatedOtp = ValueNotifier<String>('123456');

  @override
  void dispose() {
    _mobileController.dispose();
    _otpController.dispose();
    _otpSent.dispose();
    _generatedOtp.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final mobile = _mobileController.text.trim();
    if (mobile.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your mobile number.')),
      );
      return;
    }

    _generatedOtp.value = '123456';
    _otpSent.value = true;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent. Use 123456 for demo verification.')),
    );
  }

  Future<void> _verifyOtpAndContinue() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the OTP.')),
      );
      return;
    }

    if (otp != _generatedOtp.value) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect OTP. Use 123456 for demo verification.')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final savedProfile = prefs.getString('customer_profile');
    final mobile = _mobileController.text.trim();
    await prefs.setString('customer_mobile', mobile);

    if (savedProfile != null) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (context) => const CustomerHomeScreen()),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => CustomerProfileSetupScreen(mobileNumber: mobile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 18),
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF90C68A).withValues(alpha: 0.22),
                        blurRadius: 18,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/jayraj_logo.png',
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Customer login',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2A1F),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your mobile number to continue.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5B6E5F),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Mobile number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2A1F),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _mobileController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Enter mobile number',
                  prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFF2E8B57)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ValueListenableBuilder<bool>(
                valueListenable: _otpSent,
                builder: (context, otpSent, _) {
                  if (!otpSent) {
                    return FruitPrimaryButton(
                      label: 'Get OTP',
                      onPressed: _sendOtp,
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'OTP',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2A1F),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter OTP',
                          prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF2E8B57)),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F7EC),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Demo OTP: 123456',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF2E8B57),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      FruitPrimaryButton(
                        label: 'Verify OTP',
                        onPressed: _verifyOtpAndContinue,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomerProfileSetupScreen extends StatefulWidget {
  const CustomerProfileSetupScreen({required this.mobileNumber, super.key});

  final String mobileNumber;

  @override
  State<CustomerProfileSetupScreen> createState() => _CustomerProfileSetupScreenState();
}

class _CustomerProfileSetupScreenState extends State<CustomerProfileSetupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _selectedCity = 'CSN';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in your name and email.')),
      );
      return;
    }

    final profile = CustomerProfile(
      name: name,
      email: email,
      city: _selectedCity,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customer_profile', jsonEncode(profile.toJson()));
    await prefs.setString('customer_mobile', widget.mobileNumber);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (context) => const CustomerHomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete your profile',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2A1F),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Welcome to Jayraj Fruit Seller, ${widget.mobileNumber}',
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5B6E5F),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Name',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2A1F),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Enter your full name',
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF2E8B57)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2A1F),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'you@example.com',
                  prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF2E8B57)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'City',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2A1F),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCity,
                    items: const [
                      DropdownMenuItem(value: 'CSN', child: Text('CSN')),
                      DropdownMenuItem(value: 'Aurangabad', child: Text('Aurangabad')),
                      DropdownMenuItem(value: 'Pune', child: Text('Pune')),
                      DropdownMenuItem(value: 'Nagpur', child: Text('Nagpur')),
                      DropdownMenuItem(value: 'Mumbai', child: Text('Mumbai')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCity = value);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 28),
              FruitPrimaryButton(
                label: 'Continue to Home',
                onPressed: _saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  final List<FruitItem> _catalog = sampleFruitCatalog;
  final List<CartItem> _cart = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndRequestLocation();
    });
  }

  Future<void> _checkAndRequestLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final savedAddress = prefs.getString('customer_saved_address');
    if (savedAddress == null || savedAddress.isEmpty) {
      if (!mounted) return;
      _showLocationBottomSheet(context);
    }
  }

  void _showLocationBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(color: Color(0xFFE9F7EC), shape: BoxShape.circle),
                child: const Icon(Icons.location_on_rounded, color: Color(0xFF2E8B57), size: 48),
              ),
              const SizedBox(height: 20),
              const Text('Get your device location', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1F2A1F))),
              const SizedBox(height: 8),
              const Text(
                'Please enable location permission for better delivery experience',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Color(0xFF5B6E5F)),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.of(ctx).pop();
                    await _handleEnableDeviceLocation();
                  },
                  icon: const Icon(Icons.my_location_rounded),
                  label: const Text('Enable device location', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E8B57),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _showAddAddressOptionsSheet();
                  },
                  icon: const Icon(Icons.add_location_alt_rounded),
                  label: const Text('Add address', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF2E8B57),
                    side: const BorderSide(color: Color(0xFF2E8B57), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddAddressOptionsSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Add Address',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2E8B57)),
                ),
                const SizedBox(height: 24),
                ListTile(
                  leading: const Icon(Icons.my_location_rounded, color: Color(0xFF2E8B57)),
                  title: const Text('Use current location', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _handleEnableDeviceLocation();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit_location_alt_rounded, color: Color(0xFF2E8B57)),
                  title: const Text('Add manually', style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) => const AddressFormScreen()));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleEnableDeviceLocation() async {
    final position = await LocationService.requestPermissionAndGetLocation();
    if (position == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permission denied or unavailable. Please use "Add address" instead.')),
      );
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) => const AddressFormScreen()));
      return;
    }

    final addressStr = await LocationService.getAddressFromCoordinates(position.latitude, position.longitude);
    
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Location Detected'),
        content: Text('Detected Address:\n${addressStr ?? "Unknown Location"}\n\nLat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).push(MaterialPageRoute<void>(builder: (context) => const AddressFormScreen()));
            },
            child: const Text('Enter Manually'),
          ),
              ElevatedButton(
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  final address = CustomerAddress(
                    name: 'Device User',
                    mobile: prefs.getString('customer_mobile') ?? '',
                    house: '',
                    street: addressStr ?? '',
                    city: 'CSN', // Default fallback
                    pin: '',
                    latitude: position.latitude,
                    longitude: position.longitude,
                  );
                  await prefs.setString('customer_saved_address', jsonEncode(address.toJson()));
                  if (!ctx.mounted) return;
                  Navigator.of(ctx).pop();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location saved successfully')));
                },
                child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _addToCart(FruitItem fruit, double quantity) {
    if (quantity <= 0 || quantity > fruit.stockQuantity || !fruit.isAvailable) {
      return;
    }
    setState(() {
      final index = _cart.indexWhere((item) => item.fruitId == fruit.id || item.fruitName == fruit.name);
      if (index == -1) {
        _cart.add(CartItem(
          fruitId: fruit.id,
          fruitName: fruit.name,
          fruitImage: fruit.image,
          quantity: quantity,
          pricePerKg: fruit.pricePerKg,
        ));
      } else {
        _cart[index].quantity += quantity;
      }
    });

    final total = quantity * fruit.pricePerKg;
    final qtyFormatted = quantity % 1 == 0 ? quantity.toInt().toString() : quantity.toStringAsFixed(2);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $qtyFormatted kg of ${fruit.name} to cart (₹${total.toStringAsFixed(0)})'),
        duration: const Duration(seconds: 2),
        backgroundColor: const Color(0xFF2E8B57),
      ),
    );
  }

  void _openFruitDetail(FruitItem fruit) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => FruitDetailsPage(
          fruit: fruit,
          onAddToCart: _addToCart,
        ),
      ),
    );
  }

  void _openCart() async {
    final updatedCart = await Navigator.of(context).push<List<CartItem>>(
      MaterialPageRoute<List<CartItem>>(
        builder: (context) => CustomerCartScreen(
          cart: List<CartItem>.from(_cart),
          onCartChanged: (updated) {
            setState(() => _cart
              ..clear()
              ..addAll(updated));
          },
        ),
      ),
    );

    if (updatedCart != null) {
      setState(() {
        _cart
          ..clear()
          ..addAll(updatedCart);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredCatalog = _catalog.where((fruit) {
      final query = _searchController.text.trim().toLowerCase();
      final matchesQuery = query.isEmpty ||
          fruit.name.toLowerCase().contains(query) ||
          fruit.description.toLowerCase().contains(query);
      final matchesCategory = _selectedCategory == 'All' || fruit.category == _selectedCategory;
      return matchesQuery && matchesCategory;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Jayraj Fruit Seller'),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            key: const Key('orders_app_bar_button'),
            tooltip: 'My Orders',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => const CustomerOrdersScreen(),
                ),
              );
            },
            icon: const Icon(Icons.receipt_long_outlined),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                key: const Key('cart_app_bar_button'),
                onPressed: _openCart,
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: IgnorePointer(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_cart.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customer Home',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2A1F),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fresh picks and daily essentials for you.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5B6E5F),
                ),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2E8B57), Color(0xFF74B37E)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Weekend Fresh Combo',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Get up to 20% off on seasonal fruits.',
                            style: TextStyle(
                              color: Color(0xFFEAF9EE),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.local_florist_rounded, color: Colors.white, size: 34),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Search fruits',
                  prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2E8B57)),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    'All',
                    'Fresh Fruits',
                    'Best Offers',
                    'Offers Today',
                  ].map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedCategory = cat);
                          }
                        },
                        selectedColor: const Color(0xFF2E8B57),
                        backgroundColor: const Color(0xFFE9F7EC),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF2E8B57),
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        side: BorderSide.none,
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Fruit Catalogue',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2A1F),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filteredCatalog.isEmpty
                    ? const Center(
                        child: Text(
                          'No fruits found for this search or category.',
                          style: TextStyle(
                            color: Color(0xFF5B6E5F),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredCatalog.length,
                        itemBuilder: (context, index) {
                          final fruit = filteredCatalog[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: FruitProductCard(
                              fruit: fruit,
                              onTap: () => _openFruitDetail(fruit),
                              onAddToCartDirect: () => _openFruitDetail(fruit),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomerCartScreen extends StatefulWidget {
  const CustomerCartScreen({
    required this.cart,
    required this.onCartChanged,
    super.key,
  });

  final List<CartItem> cart;
  final ValueChanged<List<CartItem>> onCartChanged;

  @override
  State<CustomerCartScreen> createState() => _CustomerCartScreenState();
}

class _CustomerCartScreenState extends State<CustomerCartScreen> {
  late final List<CartItem> _cart = List<CartItem>.from(widget.cart);

  double get subtotal => _cart.fold(0.0, (sum, item) => sum + item.subtotal);

  void _updateCart() {
    widget.onCartChanged(_cart);
  }

  void _editQuantityModal(CartItem item) {
    final controller = TextEditingController(text: item.quantity.toString());
    showDialog<void>(
      context: context,
      builder: (context) {
        String? err;
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Edit Quantity for ${item.fruitName}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Quantity in kg',
                      suffixText: 'kg',
                      errorText: err,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final val = double.tryParse(controller.text.trim());
                    if (val == null || val <= 0) {
                      setDialogState(() => err = 'Enter valid kg quantity');
                      return;
                    }
                    setState(() {
                      item.quantity = val;
                    });
                    _updateCart();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: _cart.isEmpty
              ? const Center(
                  child: Text(
                    'Your cart is empty.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2A1F),
                    ),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: _cart.length,
                        itemBuilder: (context, index) {
                          final item = _cart[index];
                          final qtyStr = item.quantity % 1 == 0
                              ? item.quantity.toInt().toString()
                              : item.quantity.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                if (item.fruitImage.isNotEmpty) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: item.fruitImage.startsWith('http')
                                        ? Image.network(
                                            item.fruitImage,
                                            width: 54,
                                            height: 54,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 54,
                                              height: 54,
                                              color: const Color(0xFFE9F7EC),
                                              child: const Icon(Icons.apple_rounded, color: Color(0xFF2E8B57), size: 28),
                                            ),
                                          )
                                        : Image.asset(
                                            item.fruitImage,
                                            width: 54,
                                            height: 54,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => Container(
                                              width: 54,
                                              height: 54,
                                              color: const Color(0xFFE9F7EC),
                                              child: const Icon(Icons.apple_rounded, color: Color(0xFF2E8B57), size: 28),
                                            ),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                ],
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.fruitName,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1F2A1F),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '₹${item.pricePerKg.toStringAsFixed(0)} / kg',
                                        style: const TextStyle(
                                          color: Color(0xFF5B6E5F),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (item.quantity > 0.5) {
                                            item.quantity = double.parse((item.quantity - 0.5).toStringAsFixed(2));
                                          } else {
                                            _cart.removeAt(index);
                                          }
                                        });
                                        _updateCart();
                                      },
                                      icon: const Icon(Icons.remove_circle_outline),
                                    ),
                                    InkWell(
                                      onTap: () => _editQuantityModal(item),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                        child: Text(
                                          '$qtyStr kg',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF2E8B57),
                                          ),
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          item.quantity = double.parse((item.quantity + 0.5).toStringAsFixed(2));
                                        });
                                        _updateCart();
                                      },
                                      icon: const Icon(Icons.add_circle_outline),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${item.subtotal.toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF1F2A1F),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        setState(() => _cart.removeAt(index));
                                        _updateCart();
                                      },
                                      child: const Text('Remove'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Cart Total',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2A1F),
                            ),
                          ),
                          Text(
                            '₹${subtotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2E8B57),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    FruitPrimaryButton(
                      label: 'Checkout',
                      onPressed: _cart.isEmpty
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (context) => CheckoutScreen(cart: _cart),
                                ),
                              );
                            },
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({required this.cart, super.key});

  final List<CartItem> cart;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _houseController = TextEditingController();
  final _areaController = TextEditingController();
  final _cityController = TextEditingController(text: 'Chhatrapati Sambhajinagar');
  final _pinController = TextEditingController();

  String _deliveryMethod = 'Self Pickup';
  String _paymentMethod = 'Cash on Delivery';
  String _distanceOption = 'Nearby area';
  bool _showCityError = false;

  double get itemsSubtotal => widget.cart.fold(0.0, (sum, item) => sum + item.subtotal);

  double get deliveryCharge {
    if (_deliveryMethod == 'Self Pickup') {
      return 0;
    }

    switch (_distanceOption) {
      case 'Nearby area':
        return 10;
      case '3–5 km':
        return 20;
      case '5–10 km':
        return 30;
      case '10+ km':
        return 50;
      default:
        return 0;
    }
  }

  double get finalTotal => itemsSubtotal + deliveryCharge;

  bool get isValidCity {
    final city = _cityController.text.trim();
    return city == 'Chhatrapati Sambhajinagar' || city == 'CSN';
  }

  String? _cityValidator(String? value) {
    if (_deliveryMethod != 'Home Delivery') {
      return null;
    }
    final enteredCity = value?.trim() ?? '';
    if (enteredCity != 'Chhatrapati Sambhajinagar' && enteredCity != 'CSN') {
      return 'Home delivery is currently available only in Chhatrapati Sambhajinagar.';
    }
    return null;
  }

  void _placeOrder() {
    final isValid = _formKey.currentState?.validate() ?? true;

    if (_deliveryMethod == 'Home Delivery' && !isValidCity) {
      setState(() => _showCityError = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Home delivery is currently available only in Chhatrapati Sambhajinagar.'),
        ),
      );
      return;
    }

    if (!isValid) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => OrderConfirmationScreen(
          orderTotal: finalTotal,
          deliveryMethod: _deliveryMethod,
          paymentMethod: _paymentMethod,
          orderItems: widget.cart,
          deliveryAddress: _deliveryMethod == 'Home Delivery'
              ? '${_houseController.text}, ${_areaController.text}, ${_cityController.text} - ${_pinController.text}'
              : 'Jayraj Fruit Seller, City Centre, Chhatrapati Sambhajinagar',
        ),
      ),
    );
  }

  Widget _buildSelectableOption({
    required String title,
    required String groupValue,
    required ValueChanged<String> onChanged,
  }) {
    final isSelected = groupValue == title;
    return InkWell(
      onTap: () => onChanged(title),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E8B57) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? const Color(0xFF2E8B57) : Colors.grey[400],
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: const Color(0xFF1F2A1F),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Delivery method',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2A1F),
                ),
              ),
              const SizedBox(height: 12),
              _buildSelectableOption(
                title: 'Home Delivery',
                groupValue: _deliveryMethod,
                onChanged: (val) => setState(() => _deliveryMethod = val),
              ),
              _buildSelectableOption(
                title: 'Self Pickup',
                groupValue: _deliveryMethod,
                onChanged: (val) => setState(() => _deliveryMethod = val),
              ),
              if (_deliveryMethod == 'Home Delivery') ...[
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(labelText: 'Full Name'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your full name' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _mobileController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Mobile Number'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Please enter your mobile number' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _houseController,
                        decoration: const InputDecoration(labelText: 'House/Flat No.'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Please enter house/flat number' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _areaController,
                        decoration: const InputDecoration(labelText: 'Area/Street'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Please enter area or street' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cityController,
                        decoration: const InputDecoration(labelText: 'City'),
                        validator: _cityValidator,
                      ),
                      if (_showCityError || (_deliveryMethod == 'Home Delivery' && !isValidCity && _cityController.text.trim().isNotEmpty))
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Home delivery is currently available only in Chhatrapati Sambhajinagar.',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _pinController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'PIN Code'),
                        validator: (value) => value == null || value.trim().isEmpty ? 'Please enter PIN code' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _distanceOption,
                        decoration: const InputDecoration(labelText: 'Distance'),
                        items: const [
                          DropdownMenuItem(value: 'Nearby area', child: Text('Nearby area')),
                          DropdownMenuItem(value: '3–5 km', child: Text('3–5 km')),
                          DropdownMenuItem(value: '5–10 km', child: Text('5–10 km')),
                          DropdownMenuItem(value: '10+ km', child: Text('10+ km')),
                        ],
                        onChanged: (value) => setState(() => _distanceOption = value ?? 'Nearby area'),
                      ),
                    ],
                  ),
                ),
              ],
              if (_deliveryMethod == 'Self Pickup') ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup Address',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2A1F),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('Jayraj Fruit Seller'),
                      Text('City Centre, Chhatrapati Sambhajinagar'),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              const Text(
                'Payment method',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2A1F),
                ),
              ),
              const SizedBox(height: 12),
              _buildSelectableOption(
                title: 'Online Payment',
                groupValue: _paymentMethod,
                onChanged: (val) => setState(() => _paymentMethod = val),
              ),
              _buildSelectableOption(
                title: 'Cash on Delivery',
                groupValue: _paymentMethod,
                onChanged: (val) => setState(() => _paymentMethod = val),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  children: [
                    _SummaryRow(label: 'Items subtotal', value: '₹${itemsSubtotal.toStringAsFixed(0)}'),
                    _SummaryRow(label: 'Delivery charge', value: '₹${deliveryCharge.toStringAsFixed(0)}'),
                    const Divider(),
                    _SummaryRow(label: 'Final total', value: '₹${finalTotal.toStringAsFixed(0)}', isBold: true),
                    const SizedBox(height: 8),
                    _SummaryRow(label: 'Delivery method', value: _deliveryMethod),
                    _SummaryRow(label: 'Payment method', value: _paymentMethod),
                    if (_deliveryMethod == 'Home Delivery')
                      _SummaryRow(
                        label: 'Address',
                        value: '${_houseController.text}, ${_areaController.text}, ${_cityController.text}',
                      )
                    else
                      _SummaryRow(
                        label: 'Pickup address',
                        value: 'Jayraj Fruit Seller, City Centre, CSN',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FruitPrimaryButton(
                label: 'Place Order',
                onPressed: _placeOrder,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
                color: const Color(0xFF1F2A1F),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: const Color(0xFF1F2A1F),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({
    required this.orderTotal,
    required this.deliveryMethod,
    required this.paymentMethod,
    required this.orderItems,
    required this.deliveryAddress,
    super.key,
  });

  final double orderTotal;
  final String deliveryMethod;
  final String paymentMethod;
  final List<CartItem> orderItems;
  final String deliveryAddress;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Order placed successfully',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2A1F),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Order total: ₹${orderTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Color(0xFF5B6E5F),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SummaryRow(label: 'Delivery method', value: deliveryMethod),
                    _SummaryRow(label: 'Payment method', value: paymentMethod),
                    _SummaryRow(label: 'Address', value: deliveryAddress),
                    const SizedBox(height: 12),
                    const Text(
                      'Order details',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2A1F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...orderItems.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          '${item.fruitName} × ${(item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity)} kg - ₹${item.subtotal.toStringAsFixed(0)}',
                          style: const TextStyle(color: Color(0xFF5B6E5F)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              FruitPrimaryButton(
                label: 'Back to Home',
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (context) => const CustomerHomeScreen(),
                    ),
                    (route) => false,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SellerLoginScreen extends StatelessWidget {
  const SellerLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1F2A1F),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Seller Login',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2A1F),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Access your seller dashboard securely.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5B6E5F),
                  ),
                ),
                const SizedBox(height: 28),
                const FruitInputField(
                  label: 'Seller email',
                  hintText: 'seller@jayrajfruit.com',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 18),
                const FruitInputField(
                  label: 'Password',
                  hintText: 'Enter your seller password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                FruitPrimaryButton(
                  label: 'Login',
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (context) => const SellerDashboardScreen(),
                    ),
                    (route) => false,
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute<void>(
                        builder: (context) => const CustomerMobileLoginScreen(),
                      ),
                      (route) => false,
                    ),
                    icon: const Icon(Icons.swap_horiz_rounded),
                    label: const Text('Back to Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  final List<Map<String, String>> _recentOrders = const [
    {'customer': 'Neha', 'items': '2 Mangoes', 'status': 'Packed'},
    {'customer': 'Raju', 'items': '1 Apple', 'status': 'Out for delivery'},
    {'customer': 'Sonia', 'items': '3 Bananas', 'status': 'Delivered'},
  ];

  final List<Map<String, String>> _inventory = const [
    {'item': 'Mango', 'stock': '38 kg'},
    {'item': 'Apple', 'stock': '27 kg'},
    {'item': 'Banana', 'stock': '51 bunches'},
    {'item': 'Orange', 'stock': '21 kg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        backgroundColor: const Color(0xFFF39C12),
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(
                builder: (context) => const CustomerMobileLoginScreen(),
              ),
              (route) => false,
            ),
            child: const Text(
              'Back to Login',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2A1F),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(
                    child: DashboardStatCard(
                      label: 'Orders',
                      value: '128',
                      color: Color(0xFF2E8B57),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: DashboardStatCard(
                      label: 'Revenue',
                      value: '₹24k',
                      color: Color(0xFFF39C12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
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
                      'Today’s summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2A1F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Sales', style: TextStyle(color: Color(0xFF5B6E5F))),
                        Text('₹8,400', style: TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('New customers', style: TextStyle(color: Color(0xFF5B6E5F))),
                        Text('12', style: TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Recent orders',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2A1F),
                ),
              ),
              const SizedBox(height: 12),
              ..._recentOrders.map(
                (order) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order['customer'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2A1F),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order['items'] ?? '',
                              style: const TextStyle(color: Color(0xFF5B6E5F)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F7EC),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          order['status'] ?? '',
                          style: const TextStyle(
                            color: Color(0xFF2E8B57),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Inventory',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2A1F),
                ),
              ),
              const SizedBox(height: 12),
              ..._inventory.map(
                (item) => Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['item'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2A1F),
                        ),
                      ),
                      Text(
                        item['stock'] ?? '',
                        style: const TextStyle(
                          color: Color(0xFF5B6E5F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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

class FruitPrimaryButton extends StatelessWidget {
  const FruitPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2E8B57),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        child: Text(label),
      ),
    );
  }
}

class FruitInputField extends StatelessWidget {
  const FruitInputField({
    required this.label,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    super.key,
  });

  final String label;
  final String hintText;
  final IconData icon;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2A1F),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, color: const Color(0xFF2E8B57)),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
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
      ],
    );
  }
}

class DashboardStatCard extends StatelessWidget {
  const DashboardStatCard({
    required this.label,
    required this.value,
    required this.color,
    super.key,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF5B6E5F),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2A1F),
            ),
          ),
        ],
      ),
    );
  }
}
