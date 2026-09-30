import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:fruitseller/main.dart';
import 'package:fruitseller/widgets/fruit_product_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'customer_saved_address': '{"name":"Test","mobile":"9876543210","house":"101","street":"MG Road","city":"CSN","pin":"431001","latitude":19.8762,"longitude":75.3433}'
    });
  });

  testWidgets('startup splash navigates to mobile login screen', (tester) async {
    await tester.pumpWidget(const JayrajFruitSellerApp());

    expect(find.byType(AppSplashScreen), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.text('Customer login'), findsOneWidget);
    expect(find.text('Mobile number'), findsOneWidget);
  });

  testWidgets('full customer flow: mobile login -> OTP -> profile -> catalogue -> decimal quantity -> cart -> checkout', (tester) async {
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
    expect(find.widgetWithText(FruitProductCard, 'Pomegranate'), findsOneWidget);
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

    // Step 4: Payment Method screen
    expect(find.text('Payment Method'), findsOneWidget);
    expect(find.text('Online Payment'), findsOneWidget);
    expect(find.text('Cash on Delivery (COD)'), findsOneWidget);
    expect(find.text('PhonePe'), findsOneWidget);
    expect(find.text('Google Pay (GPay)'), findsOneWidget);
    expect(find.text('UPI QR Code'), findsOneWidget);

    // Test UPI QR option selection (displays demo QR card)
    await tester.tap(find.byKey(const Key('online_sub_upi_qr')));
    await tester.pumpAndSettle();
    expect(find.text('DEMO UPI QR CODE'), findsOneWidget);

    // Test PhonePe selection
    await tester.tap(find.byKey(const Key('online_sub_phonepe')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('continue_to_address_button')));
    await tester.pumpAndSettle();

    // Step 5: Delivery Address screen
    expect(find.text('Delivery Address'), findsWidgets);

    // Fill form fields if form is active
    final addrNameField = find.widgetWithText(TextFormField, 'Full Name');
    if (addrNameField.evaluate().isNotEmpty) {
      await tester.enterText(addrNameField, 'Jayraj Customer');
      await tester.enterText(find.widgetWithText(TextFormField, 'Mobile Number'), '9876543210');
      await tester.enterText(find.widgetWithText(TextFormField, 'House / Flat No.'), '101');
      await tester.enterText(find.widgetWithText(TextFormField, 'Area / Street'), 'MG Road');
      await tester.enterText(find.widgetWithText(TextFormField, 'City'), 'Chhatrapati Sambhajinagar');
      await tester.enterText(find.widgetWithText(TextFormField, 'PIN Code'), '431001');
    }

    await tester.tap(find.byKey(const Key('place_order_button')));
    await tester.pumpAndSettle();

    // Step 6: Delivery Unavailable Dialog (since seller coordinates are missing)
    expect(find.text('Delivery Unavailable'), findsOneWidget);
    expect(find.textContaining('Seller location not configured yet'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  });

  testWidgets('excess quantity validation prevents adding to cart', (tester) async {
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

    final confirmBtn = tester.widget<OutlinedButton>(find.byKey(const Key('add_to_cart_confirm_button')));
    expect(confirmBtn.onPressed, isNull);
  });
}
