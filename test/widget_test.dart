import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fruitseller/main.dart';
import 'package:fruitseller/models/cart_item.dart';
import 'package:fruitseller/models/customer_address.dart';
import 'package:fruitseller/screens/address_form_screen.dart';
import 'package:fruitseller/screens/cart_checkout_flow.dart';
import 'package:fruitseller/services/location_service.dart';
import 'package:fruitseller/widgets/fruit_product_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'customer_saved_address': '{"name":"Test","mobile":"9876543210","house":"101","street":"MG Road","city":"Chatrapati Sambhaji Nagar","pin":"431001","latitude":19.8762,"longitude":75.3433}',
    });
  });

  testWidgets('startup splash navigates to mobile login screen', (
    tester,
  ) async {
    await tester.pumpWidget(const JayrajFruitSellerApp());

    expect(find.byType(AppSplashScreen), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Customer login'), findsOneWidget);
    expect(find.text('Mobile number'), findsOneWidget);
  });

  testWidgets('customer profile uses and saves the only supported city', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CustomerProfileSetupScreen(mobileNumber: '9876543210'),
      ),
    );

    final cityDropdown = tester.widget<DropdownButton<String>>(
      find.byType(DropdownButton<String>),
    );
    expect(cityDropdown.value, defaultCustomerCity);
    expect(cityDropdown.items!.map((item) => item.value).toList(), [
      defaultCustomerCity,
    ]);

    await tester.enterText(find.byType(TextField).at(0), 'Test Customer');
    await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
    await tester.tap(find.text('Continue to Home'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final savedProfile = jsonDecode(
      prefs.getString('customer_profile')!,
    ) as Map<String, dynamic>;
    expect(savedProfile['city'], defaultCustomerCity);
  });

  testWidgets('delivery address uses and saves the only supported city', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () {
                Navigator.of(context).push<CustomerAddress>(
                  MaterialPageRoute<CustomerAddress>(
                    builder: (_) => AddressFormScreen(
                      locationProvider: () async =>
                          (latitude: 19.8762, longitude: 75.3433),
                    ),
                  ),
                );
              },
              child: const Text('Open address'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open address'));
    await tester.pumpAndSettle();

    final cityDropdown = tester.widget<DropdownButton<String>>(
      find.byType(DropdownButton<String>),
    );
    expect(cityDropdown.value, defaultCustomerCity);
    expect(cityDropdown.items!.map((item) => item.value).toList(), [
      defaultCustomerCity,
    ]);

    await tester.ensureVisible(find.text('Select delivery location'));
    await tester.tap(find.text('Select delivery location'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Location selected'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test Customer');
    await tester.enterText(fields.at(1), '9876543210');
    await tester.enterText(fields.at(2), '101');
    await tester.enterText(fields.at(3), 'MG Road');
    await tester.enterText(fields.at(5), '431001');
    tester.binding.focusManager.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Find entered address on map'));
    await tester.tap(find.text('Find entered address on map'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Could not find this address on the map'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save Address'));
    await tester.tap(find.text('Save Address'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final savedAddress = jsonDecode(
      prefs.getString('customer_saved_address')!,
    ) as Map<String, dynamic>;
    expect(savedAddress['city'], defaultCustomerCity);
    expect(savedAddress['latitude'], 19.8762);
    expect(savedAddress['longitude'], 75.3433);
  });

  testWidgets('editing an address preserves its selected coordinates', (
    tester,
  ) async {
    final address = CustomerAddress(
      name: 'Test Customer',
      mobile: '9876543210',
      house: '101',
      street: 'MG Road',
      city: defaultCustomerCity,
      pin: '431001',
      latitude: 19.8762,
      longitude: 75.3433,
    );
    await tester.pumpWidget(
      MaterialApp(home: AddressFormScreen(initialAddress: address)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(3), 'Updated Road');
    await tester.ensureVisible(find.text('Save Address'));
    await tester.tap(find.text('Save Address'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final savedAddress = jsonDecode(
      prefs.getString('customer_saved_address')!,
    ) as Map<String, dynamic>;
    expect(savedAddress['street'], 'Updated Road');
    expect(savedAddress['latitude'], 19.8762);
    expect(savedAddress['longitude'], 75.3433);
  });

  testWidgets('manual address requires selecting a valid location', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MaterialApp(
        home: AddressFormScreen(
          locationProvider: () async {
            throw const LocationException(
              'Location permission was denied. Allow location access to select a delivery location.',
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Select delivery location'));
    await tester.tap(find.text('Select delivery location'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Location permission was denied'),
      findsOneWidget,
    );
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Test Customer');
    await tester.enterText(fields.at(1), '9876543210');
    await tester.enterText(fields.at(2), '101');
    await tester.enterText(fields.at(3), 'MG Road');
    await tester.enterText(fields.at(5), '431001');
    tester.binding.focusManager.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save Address'));
    await tester.tap(find.text('Save Address'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Select a valid delivery location'),
      findsOneWidget,
    );
    expect(
      (await SharedPreferences.getInstance()).getString(
        'customer_saved_address',
      ),
      isNull,
    );
  });

  test('legacy customer city data is normalized to the supported city', () {
    expect(
      CustomerAddress.fromJson({'city': 'Old saved city'}).city,
      defaultCustomerCity,
    );
    expect(
      CustomerProfile.fromJson({'city': 'Old saved city'}).city,
      defaultCustomerCity,
    );
  });

  testWidgets(
    'full customer flow: mobile login -> OTP -> profile -> catalogue -> decimal quantity -> cart -> checkout',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(const JayrajFruitSellerApp());
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // 1. Mobile Login
      final phoneField = find.byType(TextField).first;
      await tester.enterText(phoneField, '9876543210');
      await tester.tap(find.text('Get OTP'));
      await tester.pumpAndSettle();

      expect(find.text('Demo OTP: 123456'), findsOneWidget);

      // 2. Enter OTP
      final otpField = find.byType(TextField).at(1);
      await tester.enterText(otpField, '123456');
      await tester.tap(find.text('Verify OTP'));
      await tester.pumpAndSettle();

      // 3. Profile Setup
      expect(find.text('Complete your profile'), findsOneWidget);
      final nameField = find.byType(TextField).at(0);
      final emailField = find.byType(TextField).at(1);

      await tester.enterText(nameField, 'Jayraj Customer');
      await tester.enterText(emailField, 'jayraj@example.com');
      await tester.tap(find.text('Continue to Home'));
      await tester.pumpAndSettle();

      // 4. Customer Home & Catalogue
      expect(find.text('Customer Home'), findsOneWidget);
      expect(find.text('Fruit Catalogue'), findsOneWidget);
      expect(find.text('Mango'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);

      // 5. Search filtering
      final searchField = find.byType(TextField).first;
      await tester.enterText(searchField, 'Mango');
      await tester.pumpAndSettle();
      expect(find.widgetWithText(FruitProductCard, 'Mango'), findsOneWidget);
      expect(find.widgetWithText(FruitProductCard, 'Apple'), findsNothing);

      // Clear search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      // 6. Category filtering (Offers Today)
      await tester.tap(find.text('Offers Today'));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(FruitProductCard, 'Pomegranate'),
        findsOneWidget,
      );
      expect(find.widgetWithText(FruitProductCard, 'Mango'), findsNothing);

      // Reset category to All
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      // 7. Out of stock behavior
      expect(find.widgetWithText(FruitProductCard, 'Orange'), findsOneWidget);
      expect(find.text('Out of Stock'), findsWidgets);

      // 8. Open Fruit Details Page for Mango
      await tester.tap(find.widgetWithText(FruitProductCard, 'Mango'));
      await tester.pumpAndSettle();

      // Initially quantity input & total are hidden, only ADD button is shown
      expect(find.byKey(const Key('add_button')), findsOneWidget);
      expect(find.text('Enter Quantity (in kg)'), findsNothing);

      // Tap ADD button to reveal quantity input and BUY NOW button
      await tester.tap(find.byKey(const Key('add_button')));
      await tester.pumpAndSettle();

      expect(find.text('Enter Quantity (in kg)'), findsOneWidget);
      expect(find.text('Total Price:'), findsOneWidget);
      expect(find.text('₹120'), findsWidgets); // Default 1 kg total

      // 9. Manual decimal quantity input (e.g., 2.5 kg)
      final qtyInput = find.byKey(const Key('fruit_quantity_input'));
      await tester.enterText(qtyInput, '2.5');
      await tester.pumpAndSettle();

      // Total should update to 2.5 * 120 = ₹300
      expect(find.text('₹300'), findsOneWidget);

      // 10. Direct BUY NOW Flow
      await tester.tap(find.byKey(const Key('buy_now_button')));
      await tester.pumpAndSettle();

      // Step 3: Order Confirmation page
      expect(find.text('Order Confirmation'), findsOneWidget);
      expect(find.text('Mango'), findsWidgets);
      expect(find.text('Quantity: 2.5 kg'), findsOneWidget);
      expect(find.text('₹300'), findsWidgets);

      await tester.tap(find.byKey(const Key('confirm_order_button')));
      await tester.pumpAndSettle();

      // Step 4: Delivery Address now precedes Payment.
      expect(find.text('Delivery Address'), findsWidgets);
      expect(find.text('Payment Method'), findsNothing);

      await tester.tap(find.byKey(const Key('place_order_button')));
      await tester.pumpAndSettle();

      // Payment is blocked because the real seller location is not configured.
      expect(find.text('Delivery Unavailable'), findsOneWidget);
      expect(
        find.textContaining('Seller location not configured yet'),
        findsOneWidget,
      );
      expect(find.text('Payment Method'), findsNothing);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    },
  );

  testWidgets('customer can enter and save a manual delivery address', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                key: const Key('open_address_form'),
                onPressed: () {
                  Navigator.of(context).push<CustomerAddress>(
                    MaterialPageRoute<CustomerAddress>(
                      builder: (context) => AddressFormScreen(
                        locationProvider: () async =>
                            (latitude: 19.8762, longitude: 75.3433),
                      ),
                    ),
                  );
                },
                child: const Text('Open address form'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('open_address_form')));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Jayraj Customer');
    await tester.enterText(fields.at(1), '9876543210');
    await tester.enterText(fields.at(2), '101');
    await tester.enterText(fields.at(3), 'MG Road');
    await tester.enterText(fields.at(5), '431001');
    await tester.ensureVisible(find.text('Select delivery location'));
    await tester.tap(find.text('Select delivery location'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save Address'));
    await tester.pumpAndSettle();

    final prefs = await SharedPreferences.getInstance();
    final savedAddress = prefs.getString('customer_saved_address');
    expect(savedAddress, contains('MG Road'));
    expect(savedAddress, contains('9876543210'));
    expect(savedAddress, contains('"latitude":19.8762'));
    expect(savedAddress, contains('"longitude":75.3433'));
  });

  testWidgets(
    'cart checkout opens address before payment and retains cart on unavailable delivery',
    (tester) async {
      final cart = [
        CartItem(
          fruitId: 'mango',
          fruitName: 'Mango',
          quantity: 2.5,
          pricePerKg: 120,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: CheckoutScreen(cart: cart, onCartChanged: (_) {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Delivery Address'), findsOneWidget);
      expect(
        find.byKey(const Key('continue_to_payment_button')),
        findsOneWidget,
      );
      expect(find.text('Payment Method'), findsNothing);

      await tester.tap(find.byKey(const Key('continue_to_payment_button')));
      await tester.pumpAndSettle();

      expect(find.text('Delivery Unavailable'), findsOneWidget);
      expect(find.text('Payment Method'), findsNothing);
      expect(cart, hasLength(1));
      expect(cart.single.quantity, 2.5);
    },
  );

  testWidgets(
    'cart payment preserves all options and does not fake online success',
    (tester) async {
      var placed = false;
      final cart = [
        CartItem(
          fruitId: 'mango',
          fruitName: 'Mango',
          quantity: 1,
          pricePerKg: 120,
        ),
      ];
      final address = CustomerAddress(
        name: 'Test Customer',
        mobile: '9876543210',
        house: '101',
        street: 'MG Road',
        city: defaultCustomerCity,
        pin: '431001',
        latitude: 19.8762,
        longitude: 75.3433,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: CartPaymentMethodScreen(
            cart: cart,
            address: address,
            onPlaceOrder: (_, _) async {
              placed = true;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('PhonePe'), findsOneWidget);
      expect(find.text('Google Pay'), findsOneWidget);
      expect(find.text('UPI QR'), findsOneWidget);
      expect(find.text('Cash on Delivery (COD)'), findsOneWidget);

      await tester.tap(find.text('PhonePe'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('place_order_button')));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Online payment verification is not configured. No order was placed.',
        ),
        findsOneWidget,
      );
      expect(placed, isFalse);
    },
  );

  testWidgets('excess quantity validation prevents adding to cart', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(const JayrajFruitSellerApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Login directly
    final phoneField = find.byType(TextField).first;
    await tester.enterText(phoneField, '9876543210');
    await tester.tap(find.text('Get OTP'));
    await tester.pumpAndSettle();

    final otpField = find.byType(TextField).at(1);
    await tester.enterText(otpField, '123456');
    await tester.tap(find.text('Verify OTP'));
    await tester.pumpAndSettle();

    final nameField = find.byType(TextField).at(0);
    final emailField = find.byType(TextField).at(1);
    await tester.enterText(nameField, 'Test User');
    await tester.enterText(emailField, 'test@example.com');
    await tester.tap(find.text('Continue to Home'));
    await tester.pumpAndSettle();

    // Open Apple (Stock: 25.5 kg)
    await tester.tap(find.widgetWithText(FruitProductCard, 'Apple'));
    await tester.pumpAndSettle();

    // Tap ADD button to reveal quantity input
    await tester.tap(find.byKey(const Key('add_button')));
    await tester.pumpAndSettle();

    final qtyInput = find.byKey(const Key('fruit_quantity_input'));
    await tester.enterText(qtyInput, '100');
    await tester.pumpAndSettle();

    expect(find.textContaining('exceeds available stock'), findsOneWidget);

    final confirmBtn = tester.widget<OutlinedButton>(
      find.byKey(const Key('add_to_cart_confirm_button')),
    );
    expect(confirmBtn.onPressed, isNull);
  });
}
