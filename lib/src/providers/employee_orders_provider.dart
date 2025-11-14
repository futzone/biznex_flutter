import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/model/order_models/order.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:flutter/foundation.dart';
import '../core/isolate/employee_order_filter.dart';

bool isTodayOrder(DateTime dateFilter, Order order) {
  final orderDate = DateTime.parse(order.createdDate);
  return (orderDate.year == dateFilter.year) &&
      (orderDate.month == dateFilter.month) &&
      (orderDate.day == dateFilter.day);
}

bool haveInProducts(Order order, String productId) {
  return order.products.any((element) => element.product.id == productId);
}

bool haveInPlaces(Order order, String placeId) {
  return order.products.any((element) => element.placeId == placeId);
}

final employeeOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final employee = ref.watch(currentEmployeeProvider);
  final orderDatabase = OrderDatabase();
  final allOrders = await orderDatabase.getOrders();

  final result = await compute(filterAndSortOrders, {
    'orders': allOrders,
    'employeeId': employee.id,
  });

  return result;
});

final orderLengthProvider = FutureProvider((ref) async {
  final orderDatabase = IsarDatabase.instance.isar;
  final allOrders = await orderDatabase.orderIsars.count();
  return allOrders;
});

final todayOrdersProvider = FutureProvider((ref) async {
  final orderDatabase = OrderDatabase();
  final allOrders = await orderDatabase.getDayOrders(DateTime.now());
  return allOrders;
});

final dayOrdersProvider = FutureProvider.family((ref, DateTime day) async {
  final orderDatabase = OrderDatabase();
  final allOrders = await orderDatabase.getDayOrders(day);
  return allOrders;
});
