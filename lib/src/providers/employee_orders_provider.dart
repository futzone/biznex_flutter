import 'dart:io';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/model/order_models/order.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/core/model/transaction_model/transaction_model.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
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
  if (Platform.isWindows) {
    final orderDatabase = IsarDatabase.instance.isar;
    final employeeOrders = await orderDatabase.orderIsars
        .where()
        .filter()
        .createdDateStartsWith(
            DateTime.now().toIso8601String().split("T").first)
        .employee((e) => e.idEqualTo(employee.id))
        .sortByCreatedDateDesc()
        .findAll();

    return employeeOrders.map((l) => Order.fromIsar(l)).toList();
  }

  OrderDatabase orderDatabase = OrderDatabase();
  final orders = await orderDatabase.getOrders();
  return [...orders.where((e) => e.employee.id == employee.id)];
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
  return allOrders.map((e) => Order.fromIsar(e)).toList();
});

final dayPaymentsProvider = FutureProvider.family((ref, DateTime day) async {
  final Isar isar = IsarDatabase.instance.isar;

  final prefix = day.toIso8601String().split("T").first;
  final orderData = await isar.orderIsars
      .where()
      .filter()
      .createdDateStartsWith(prefix)
      .findAll();
  Map<String, double> data = {};
  for (final order in orderData) {
    for (final type in Transaction.values) {
      final paymentType = order.paymentTypes
          .where((element) => element.name == type)
          .firstOrNull;

      if (paymentType != null) {
        data[type] = (data[type] ?? 0.0) + paymentType.amount;
      }
    }
  }

  return data;
});
