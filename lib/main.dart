import 'package:flutter/material.dart';

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
      home: const EntryScreen(),
    );
  }
}

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => _EntryScreenState();
}

class _EntryScreenState extends State<EntryScreen> {
  String? selectedRole;

  void _continue() {
    if (selectedRole == 'customer') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const CustomerAuthScreen(),
        ),
      );
      return;
    }

    if (selectedRole == 'seller') {
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (context) => const SellerLoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const BrandHeader(),
                        const SizedBox(height: 28),
                        const Text(
                          'Choose your role',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1F2A1F),
                          ),
                        ),
                        const SizedBox(height: 18),
                        RoleOptionCard(
                          title: 'Customer',
                          subtitle: 'Shop fresh fruits and home delivery',
                          icon: Icons.shopping_bag_rounded,
                          accentColor: const Color(0xFF2E8B57),
                          isSelected: selectedRole == 'customer',
                          onTap: () => setState(() => selectedRole = 'customer'),
                        ),
                        const SizedBox(height: 16),
                        RoleOptionCard(
                          title: 'Seller',
                          subtitle: 'Manage stock, orders, and sales',
                          icon: Icons.storefront_rounded,
                          accentColor: const Color(0xFFF39C12),
                          isSelected: selectedRole == 'seller',
                          onTap: () => setState(() => selectedRole = 'seller'),
                        ),
                        const SizedBox(height: 24),
                        FruitPrimaryButton(
                          label: 'Continue',
                          onPressed: selectedRole == null ? null : _continue,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF90C68A).withValues(alpha: 0.32),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          child: const Icon(
            Icons.eco_rounded,
            size: 72,
            color: Color(0xFF2E8B57),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Classic & Fresh',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
            color: Color(0xFF245B3C),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Jayraj Fruit Seller',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2A1F),
          ),
        ),
      ],
    );
  }
}

class CustomerAuthScreen extends StatelessWidget {
  const CustomerAuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F2),
      body: SafeArea(
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
                'Customer Login/Register',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2A1F),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Choose how you want to continue.',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF5B6E5F),
                ),
              ),
              const SizedBox(height: 30),
              FruitPrimaryButton(
                label: 'Login',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const CustomerLoginScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              FruitPrimaryButton(
                label: 'Register',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const CustomerRegisterScreen(),
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

class CustomerLoginScreen extends StatelessWidget {
  const CustomerLoginScreen({super.key});

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
                  'Customer Login',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2A1F),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Welcome back! Continue shopping fresh.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5B6E5F),
                  ),
                ),
                const SizedBox(height: 28),
                const FruitInputField(
                  label: 'Email',
                  hintText: 'you@example.com',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 18),
                const FruitInputField(
                  label: 'Password',
                  hintText: 'Enter your password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                FruitPrimaryButton(
                  label: 'Login',
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (context) => const CustomerHomeScreen(),
                    ),
                    (route) => false,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Need an account?',
                      style: TextStyle(color: Color(0xFF5B6E5F)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) => const CustomerRegisterScreen(),
                        ),
                      ),
                      child: const Text('Register'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomerRegisterScreen extends StatelessWidget {
  const CustomerRegisterScreen({super.key});

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
                  'Customer Register',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2A1F),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create an account and start shopping.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF5B6E5F),
                  ),
                ),
                const SizedBox(height: 28),
                const FruitInputField(
                  label: 'Full name',
                  hintText: 'Your name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 18),
                const FruitInputField(
                  label: 'Email',
                  hintText: 'you@example.com',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 18),
                const FruitInputField(
                  label: 'Password',
                  hintText: 'Create a strong password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                ),
                const SizedBox(height: 18),
                const FruitInputField(
                  label: 'Confirm password',
                  hintText: 'Repeat your password',
                  icon: Icons.lock_reset_outlined,
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                FruitPrimaryButton(
                  label: 'Register',
                  onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(
                      builder: (context) => const CustomerHomeScreen(),
                    ),
                    (route) => false,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: Color(0xFF5B6E5F)),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
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
  final List<FruitItem> _catalog = const [
    FruitItem(
      name: 'Mango',
      pricePerKg: 120,
      unit: 'per kg',
      accentColor: Color(0xFFF8C63A),
      icon: Icons.food_bank_rounded,
    ),
    FruitItem(
      name: 'Apple',
      pricePerKg: 180,
      unit: 'per kg',
      accentColor: Color(0xFFD65A5A),
      icon: Icons.apple_rounded,
    ),
    FruitItem(
      name: 'Banana',
      pricePerKg: 80,
      unit: 'per kg',
      accentColor: Color(0xFFB6C94C),
      icon: Icons.emoji_food_beverage_rounded,
    ),
    FruitItem(
      name: 'Orange',
      pricePerKg: 140,
      unit: 'per kg',
      accentColor: Color(0xFFFF8C42),
      icon: Icons.circle_rounded,
    ),
  ];

  final List<CartItem> _cart = [];

  void _addToCart(FruitItem fruit) {
    setState(() {
      final index = _cart.indexWhere((item) => item.name == fruit.name);
      if (index == -1) {
        _cart.add(CartItem(name: fruit.name, pricePerKg: fruit.pricePerKg, quantity: 1));
      } else {
        _cart[index].quantity += 1;
      }
    });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jayraj Fruit Seller'),
        backgroundColor: const Color(0xFF2E8B57),
        foregroundColor: Colors.white,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                onPressed: _openCart,
                icon: const Icon(Icons.shopping_cart_outlined),
              ),
              if (_cart.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${_cart.fold<int>(0, (sum, item) => sum + item.quantity)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
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
              const SizedBox(height: 20),
              const Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FruitCategoryChip(label: 'Fresh Fruits'),
                  FruitCategoryChip(label: 'Vegetables'),
                  FruitCategoryChip(label: 'Best Offers'),
                  FruitCategoryChip(label: 'Offers Today'),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Popular fruits',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2A1F),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _catalog.length,
                  itemBuilder: (context, index) {
                    final fruit = _catalog[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: FruitProductCard(
                        fruit: fruit,
                        onAddToCart: () => _addToCart(fruit),
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

class FruitItem {
  const FruitItem({
    required this.name,
    required this.pricePerKg,
    required this.unit,
    required this.accentColor,
    required this.icon,
  });

  final String name;
  final double pricePerKg;
  final String unit;
  final Color accentColor;
  final IconData icon;
}

class FruitProductCard extends StatelessWidget {
  const FruitProductCard({
    required this.fruit,
    required this.onAddToCart,
    super.key,
  });

  final FruitItem fruit;
  final VoidCallback onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
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
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: fruit.accentColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(fruit.icon, color: fruit.accentColor, size: 30),
          ),
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
                  '₹${fruit.pricePerKg.toStringAsFixed(0)} ${fruit.unit}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5B6E5F),
                  ),
                ),
              ],
            ),
          ),
          FilledButton.icon(
            key: ValueKey('add_to_cart_${fruit.name}'),
            onPressed: onAddToCart,
            icon: const Icon(Icons.add_shopping_cart_rounded),
            label: const Text('Add to Cart'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF2E8B57),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class CartItem {
  CartItem({
    required this.name,
    required this.pricePerKg,
    required this.quantity,
  });

  final String name;
  final double pricePerKg;
  int quantity;

  double get subtotal => pricePerKg * quantity;
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
  late List<CartItem> _cart = List<CartItem>.from(widget.cart);

  double get subtotal => _cart.fold(0.0, (sum, item) => sum + item.subtotal);

  void _updateCart() {
    widget.onCartChanged(_cart);
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
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.name,
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
                                          if (item.quantity > 1) {
                                            item.quantity -= 1;
                                          } else {
                                            _cart.removeAt(index);
                                          }
                                        });
                                        _updateCart();
                                      },
                                      icon: const Icon(Icons.remove_circle_outline),
                                    ),
                                    Text(
                                      '${item.quantity}',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        setState(() => item.quantity += 1);
                                        _updateCart();
                                      },
                                      icon: const Icon(Icons.add_circle_outline),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
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
              RadioListTile<String>(
                title: const Text('Home Delivery'),
                value: 'Home Delivery',
                groupValue: _deliveryMethod,
                onChanged: (value) => setState(() => _deliveryMethod = value ?? 'Home Delivery'),
              ),
              RadioListTile<String>(
                title: const Text('Self Pickup'),
                value: 'Self Pickup',
                groupValue: _deliveryMethod,
                onChanged: (value) => setState(() => _deliveryMethod = value ?? 'Self Pickup'),
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
                        value: _distanceOption,
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
              RadioListTile<String>(
                title: const Text('Online Payment'),
                value: 'Online Payment',
                groupValue: _paymentMethod,
                onChanged: (value) => setState(() => _paymentMethod = value ?? 'Online Payment'),
              ),
              RadioListTile<String>(
                title: const Text('Cash on Delivery'),
                value: 'Cash on Delivery',
                groupValue: _paymentMethod,
                onChanged: (value) => setState(() => _paymentMethod = value ?? 'Cash on Delivery'),
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
                          '${item.name} × ${item.quantity} - ₹${item.subtotal.toStringAsFixed(0)}',
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
                        builder: (context) => const EntryScreen(),
                      ),
                      (route) => false,
                    ),
                    icon: const Icon(Icons.swap_horiz_rounded),
                    label: const Text('Switch Role'),
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
                builder: (context) => const EntryScreen(),
              ),
              (route) => false,
            ),
            child: const Text(
              'Switch Role',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Padding(
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
            Row(
              children: const [
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
          ],
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

class RoleOptionCard extends StatelessWidget {
  const RoleOptionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.12) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? accentColor : Colors.transparent,
            width: 2,
          ),
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
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(icon, color: accentColor, size: 30),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2A1F),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF5B6E5F),
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: accentColor,
                size: 28,
              ),
          ],
        ),
      ),
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

class FruitCategoryChip extends StatelessWidget {
  const FruitCategoryChip({
    required this.label,
    super.key,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F7EC),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF2E8B57),
        ),
      ),
    );
  }
}
