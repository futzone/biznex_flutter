import 'package:biznex/biznex.dart';
import 'package:flutter/foundation.dart';

import '../core/isolate/product_order_filter.dart';
import '../core/model/employee_models/employee_model.dart';
import '../core/model/order_models/order_model.dart';

class ProductOrderFilter {
  DateTime day;
  List<Order> orders;
  Employee employee;

  ProductOrderFilter({
    required this.day,
    required this.orders,
    required this.employee,
  });
}

Future<Map<String, dynamic>> _calculateProductOrderAsync(
    ProductOrderFilter filter) async {
  final ordersJson = filter.orders.map((e) => e.toJson()).toList();
  final result = await compute(calculateProductOrderIsolate, {
    'day': filter.day.toIso8601String(),
    'orders': ordersJson,
    'currentEmployee': filter.employee.toJson(),
  });

  return result;
}

final productOrdersProvider =
    FutureProvider.family((ref, ProductOrderFilter filter) async {
  final result = await _calculateProductOrderAsync(filter);
  return result;
});
