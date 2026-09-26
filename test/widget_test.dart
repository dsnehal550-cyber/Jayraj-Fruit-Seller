// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fruitseller/main.dart';

void main() {
  testWidgets('entry screen shows customer and seller choices', (tester) async {
    await tester.pumpWidget(const JayrajFruitSellerApp());

    expect(find.text('Jayraj Fruit Seller'), findsOneWidget);
    expect(find.text('Customer'), findsWidgets);
    expect(find.text('Seller'), findsWidgets);
  });

  testWidgets('customer path navigates to login and home', (tester) async {
    await tester.pumpWidget(const JayrajFruitSellerApp());

    await tester.tap(find.text('Customer'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Customer Login/Register'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Customer Login'), findsOneWidget);

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Customer Home'), findsOneWidget);
  });

  testWidgets('seller path navigates to seller login only and can switch role', (tester) async {
    await tester.pumpWidget(const JayrajFruitSellerApp());

    await tester.tap(find.text('Seller'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Seller Login'), findsOneWidget);
    expect(find.text('Register'), findsNothing);

    await tester.tap(find.text('Switch Role'));
    await tester.pumpAndSettle();

    expect(find.text('Choose your role'), findsOneWidget);
    expect(find.text('Customer'), findsWidgets);
    expect(find.text('Seller'), findsWidgets);
  });

  testWidgets('customer can add fruit to cart and confirm a self pickup order', (tester) async {
    await tester.pumpWidget(const JayrajFruitSellerApp());

    await tester.tap(find.text('Customer'));
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Customer Home'), findsOneWidget);

    await tester.tap(find.byKey(const Key('add_to_cart_Mango')));
    await tester.pumpAndSettle();

    final cartButton = find.byWidgetPredicate(
      (widget) =>
          widget is IconButton &&
          widget.onPressed != null &&
          widget.icon is Icon &&
          (widget.icon as Icon).icon == Icons.shopping_cart_outlined,
    );

    expect(cartButton, findsOneWidget);

    final cartAction = tester.widget<IconButton>(cartButton);
    cartAction.onPressed?.call();
    await tester.pumpAndSettle();

    expect(find.text('My Cart'), findsOneWidget);
    expect(find.text('Mango'), findsWidgets);
    expect(find.text('Cart Total'), findsOneWidget);

    await tester.tap(find.text('Checkout'));
    await tester.pumpAndSettle();

    final selfPickupRadio = find.byWidgetPredicate(
      (widget) =>
          widget is RadioListTile<String> &&
          widget.value == 'Self Pickup',
    );

    expect(selfPickupRadio, findsOneWidget);
    await tester.tap(selfPickupRadio);
    await tester.pumpAndSettle();

    final cashOnDeliveryRadio = find.byWidgetPredicate(
      (widget) =>
          widget is RadioListTile<String> &&
          widget.value == 'Cash on Delivery',
    );

    expect(cashOnDeliveryRadio, findsOneWidget);
    await tester.tap(cashOnDeliveryRadio);
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Place Order'),
      100,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Place Order'));
    await tester.pumpAndSettle();

    expect(find.text('Order placed successfully'), findsOneWidget);
  });
}
