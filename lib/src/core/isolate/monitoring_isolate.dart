import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';

import 'package:biznex/src/core/model/transaction_model/transaction_model.dart';
import 'package:biznex/src/core/model/monitoring/employee_monitoring_model.dart';

Future<Map<String, dynamic>> calculateMonitoringIsolate(
    Map<String, dynamic> data) async {
  final ordersList = (data['orders'] as List).cast<Order>();
  final employees = (data['employees'] as List).cast<Employee>();
  final percentMonitoring = (data['percents'] as List).cast<dynamic>();
  // dynamic above because percent model might not be strictly typed in passed list or it's a list of something else.
  // In controller it was: `final percentMonitoring = await percentDatabase.get();`
  // Let's assume it passes List<Percent>.

  final allPercents = percentMonitoring.fold(0.0, (a, el) => a += el.percent);

  // 1. Employee Monitoring
  Map<String, EM> employeesMonitoring = {};
  for (final item in employees) {
    final orders = ordersList.where((el) => el.employee.id == item.id).toList();
    final percentOrders = orders.where((el) => !el.place.percentNull).toList();

    EM employeeMonitoring = EM(
      ordersCount: orders.length,
      percentSumm: percentOrders.fold(
              0.0, (a, el) => a += (el.price * (allPercents / 100))) +
          orders.fold(
              0.0,
              (a, el) => a += (el.price -
                  (el.price / (1 + ((el.feePercent ?? 0) * 0.01))))),
      totalSumm: orders.fold(0.0, (a, el) => a += el.price),
      employee: item,
    );

    employeesMonitoring[item.id] = employeeMonitoring;
  }

  // Admin logic
  final adminOrders = ordersList
      .where((el) => el.employee.roleName.toLowerCase() == 'admin')
      .toList();
  final adminPercentOrders =
      adminOrders.where((el) => !el.place.percentNull).toList();
  EM adminMonitoring = EM(
    ordersCount: adminOrders.length,
    percentSumm: adminPercentOrders.fold(
            0.0, (a, el) => a += (el.price * (allPercents / 100))) +
        adminOrders.fold(
            0.0,
            (a, el) => a +=
                (el.price - (el.price / (1 + ((el.feePercent ?? 0) * 0.01))))),
    totalSumm: adminOrders.fold(0.0, (a, el) => a += el.price),
    employee:
        Employee(fullname: "Admin", roleId: "", roleName: "Admin", id: "admin"),
  );
  employeesMonitoring["admin"] = adminMonitoring;

  // 2. Product Monitoring
  // We need products list to map ids to products.
  // The original logic iterated over ALL products in database.
  // This is inefficient. Better to iterate over orders and collect products.
  // We can't cast to Product easily if it's JSON, but here we expect objects if we pass objects.
  // `compute` can pass objects if they are sending basic types or simple objects.
  // Ideally, we pass JSON or ensure classes are simple.
  // `Order`, `Employee` are Hive/Isar objects? If they are Isar objects, they can't be passed between isolates easily if they are attached.
  // The controller `_getDayOrders` returns `Order.fromIsar(order)`. This creates detached objects. Good.

  // Actually, iterating over 1000s of products for every calculation is slow.
  // But we must follow original logic to ensure consistency or improve it.
  // Original logic: iterate all products, then for each, iterate all orders. O(P * O). That's bad.
  // Better: Iterating orders, accumulate by product ID. Then map to product details.

  Map<String, OrderItem> reportsMap = {};
  // Optimization: Map<ProductId, OrderItem>
  for (final order in ordersList) {
    for (final productItem in order.products) {
      if (reportsMap.containsKey(productItem.product.id)) {
        final old = reportsMap[productItem.product.id]!;
        reportsMap[productItem.product.id] = OrderItem(
            product: old.product,
            amount: old.amount + productItem.amount,
            placeId: '');
      } else {
        reportsMap[productItem.product.id] = OrderItem(
            product: productItem.product,
            amount: productItem.amount,
            placeId: '');
      }
    }
  }

  // 3. Payment Monitoring
  Map<String, double> paymentMonitoring = {};
  for (final order in ordersList) {
    for (final type in Transaction.values) {
      final paymentType = order.paymentTypes
          .where((element) => element.name == type)
          .firstOrNull;

      if (paymentType != null) {
        paymentMonitoring[type] =
            (paymentMonitoring[type] ?? 0.0) + paymentType.percent;
      }
    }
  }

  // 4. Totals
  final ordersTotalSumm = ordersList.fold(0.0, (a, item) => a += item.price);
  final placesTotalSumm = ordersList.fold(0.0, (a, b) {
    if (b.place.price != null && b.place.price != 0.0) {
      return a += (b.place.price ?? 0.0);
    }
    return a;
  });

  final ordersTotalProductSumm = ordersList.fold(0.0, (a, item) {
    final orderProfit = item.products.fold(0.0, (b, pr) {
      return b += pr.amount *
          (pr.product.price -
              (pr.product.price / ((100 + pr.product.percent) / 100)));
    });
    return a += orderProfit;
  });

  final orderPercentSumm = (allPercents <= 0
          ? 0.0
          : ordersList.fold(0.0, (a, order) {
              return a += (order.place.percentNull
                  ? 0.0
                  : ((order.price * (1 - (100 / (100 + allPercents))))));
            })) +
      ordersList.fold(
          0.0,
          (a, el) => a +=
              (el.price - (el.price / (1 + ((el.feePercent ?? 0) * 0.01)))));

  return {
    'employeesMonitoring': employeesMonitoring,
    'productsMonitoring': reportsMap,
    'paymentMonitoring': paymentMonitoring,
    'ordersTotalSumm': ordersTotalSumm,
    'placesTotalSumm': placesTotalSumm,
    'ordersTotalProductSumm': ordersTotalProductSumm,
    'orderPercentSumm': orderPercentSumm,
    'ordersCount': ordersList.length,
  };
}
