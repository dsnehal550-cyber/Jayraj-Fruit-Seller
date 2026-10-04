import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/customer_order.dart';

class OrderStorageService {
  static const String _keyOrders = 'customer_orders_list';

  static Future<List<CustomerOrder>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyOrders);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    try {
      final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
      final orders = list
          .map((item) => CustomerOrder.fromJson(item as Map<String, dynamic>))
          .toList();
      // Sort newest first
      orders.sort((a, b) => b.orderDateTime.compareTo(a.orderDateTime));
      return orders;
    } catch (_) {
      return [];
    }
  }

  static Future<void> saveOrder(CustomerOrder order) async {
    await saveOrders([order]);
  }

  static Future<void> saveOrders(List<CustomerOrder> newOrders) async {
    if (newOrders.isEmpty) return;

    final orders = await getOrders();
    orders.insertAll(0, newOrders);

    final prefs = await SharedPreferences.getInstance();
    final jsonList = orders.map((o) => o.toJson()).toList();
    await prefs.setString(_keyOrders, jsonEncode(jsonList));
  }

  static Future<void> clearOrders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyOrders);
  }
}
