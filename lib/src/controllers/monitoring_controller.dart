import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/database/employee_database/employee_database.dart';
import 'package:biznex/src/core/database/order_database/order_percent_database.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';

import '../core/database/order_database/order_database.dart';
import '../core/services/printer_monitoring_services.dart';

class EM {
  Employee employee;
  double totalSumm;
  int ordersCount;
  double percentSumm;

  EM({
    required this.employee,
    required this.ordersCount,
    required this.percentSumm,
    required this.totalSumm,
  });
}

class MonitoringController {
  final WidgetRef ref;
  final BuildContext context;
  final AppModel state;

  MonitoringController({
    required this.state,
    required this.context,
    required this.ref,
  });

  final OrderDatabase orderDatabase = OrderDatabase();
  final OrderPercentDatabase percentDatabase = OrderPercentDatabase();
  final EmployeeDatabase employeeDatabase = EmployeeDatabase();
  final ProductDatabase productDatabase = ProductDatabase();

  Future<List<Order>> _getDayOrders(DateTime day) async {
    List<Order> ordersList = [];
    final allOrders = await orderDatabase.getOrders();

    final dayOrders = allOrders.where((item) {
      final createdDate = DateTime.parse(item.createdDate);
      return createdDate.year == day.year && createdDate.month == day.month && createdDate.day == day.day;
    });

    ordersList = [...dayOrders];

    return ordersList;
  }

  Future<Map<String, OrderItem>> _onCalculateProductMonitoring(List<Order> ordersList) async {
    final products = await productDatabase.get();
    Map<String, OrderItem> reportsMap = {};
    for (final product in products) {
      final amount = ordersList.fold(0.0, (total, item) {
        final productSubs = item.products.where((el) => el.product.id == product.id).toList();
        return total += (productSubs.fold((0.0), (a, el) => a += el.amount));
      });

      OrderItem? oldValue = reportsMap[product.id];
      if (oldValue == null) {
        oldValue = OrderItem(product: product, amount: amount, placeId: '');
      } else {
        oldValue = OrderItem(product: product, amount: (oldValue.amount + amount), placeId: '');
      }

      reportsMap[product.id] = oldValue;
    }

    return reportsMap;
  }

  Future<Map<String, EM>> _onCalculateEmployeeMonitoring(List<Order> ordersList) async {
    final employees = await employeeDatabase.get();
    final percentMonitoring = await percentDatabase.get();
    final allPercents = percentMonitoring.fold(0.0, (a, el) => a += el.percent);
    Map<String, EM> employeesMonitoring = {};
    for (final item in employees) {
      final orders = ordersList.where((el) => el.employee.id == item.id).toList();
      final percentOrders = orders.where((el) => !el.place.percentNull).toList();
      EM employeeMonitoring = EM(
        ordersCount: orders.length,
        percentSumm: percentOrders.fold(0.0, (a, el) => a += (el.price * (allPercents / 100))),
        totalSumm: orders.fold(0.0, (a, el) => a += el.price),
        employee: item,
      );

      employeesMonitoring[item.id] = employeeMonitoring;
    }

    return employeesMonitoring;
  }

  Future<void> onPrintDayMonitoring(DateTime day) async {
    showAppLoadingDialog(context);
    final dayOrders = await _getDayOrders(day);
    if (dayOrders.isEmpty) {
      AppRouter.close(context);
      ShowToast.info(context, AppLocales.ordersNotFound.tr());
      return;
    }

    final employeesMonitoring = await _onCalculateEmployeeMonitoring(dayOrders);
    final productsMonitoring = await _onCalculateProductMonitoring(dayOrders);
    final ordersCount = dayOrders.length;
    final ordersTotalSumm = dayOrders.fold(0.0, (a, item) => a += item.price);
    final ordersTotalProductSumm = dayOrders.fold(0.0, (a, item) {
      final orderProfit = item.products.fold(0.0, (b, pr) {
        return b += pr.amount * (pr.product.price - (pr.product.price / ((100 + pr.product.percent) / 100)));
      });

      return a += orderProfit;
    });

    final percents = await percentDatabase.get();
    final orderPrecent = percents.fold(0.0, (a, pr) => a += pr.percent);
    final orderPercentSumm = orderPrecent <= 0
        ? 0.0
        : dayOrders.fold(0.0, (a, order) {
      return a += (order.place.percentNull ? 0.0 : ((order.price * (1 - (100 / (100 + orderPrecent))))));
    });

    PrinterMonitoringServices pms = PrinterMonitoringServices(
      model: state,
      dateTime: day,
      employeesMonitoring: employeesMonitoring,
      ordersCount: ordersCount,
      orderPercentSumm: orderPercentSumm,
      ordersTotalProductSumm: ordersTotalProductSumm,
      ordersTotalSumm: ordersTotalSumm,
      productsMonitoring: productsMonitoring,
    );

    pms.printOrderCheck();

    AppRouter.close(context);
  }
}
