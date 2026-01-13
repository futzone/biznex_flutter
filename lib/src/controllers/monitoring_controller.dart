import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/database/employee_database/employee_database.dart';
import 'package:biznex/src/core/database/order_database/order_percent_database.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';

import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import '../core/database/order_database/order_database.dart';
import '../core/services/printer_monitoring_services.dart';

import 'package:flutter/foundation.dart';
import 'package:biznex/src/core/isolate/monitoring_isolate.dart';
import 'package:biznex/src/core/model/monitoring/employee_monitoring_model.dart';

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
    final allOrders = await orderDatabase.getDayOrders(day);
    ordersList = [for (final order in allOrders) Order.fromIsar(order)];
    return ordersList;
  }

  Future<List<Order>> _getRangeOrders(DateTimeRange range) async {
    List<Order> ordersList = [];
    final allOrders =
        await orderDatabase.getRangeOrders(range.start, range.end);
    ordersList = [for (final order in allOrders) Order.fromIsar(order)];
    return ordersList;
  }

  Future<void> onPrintDayMonitoring(DateTime day) async {
    showAppLoadingDialog(context);
    final dayOrders = await _getDayOrders(day);
    if (dayOrders.isEmpty) {
      AppRouter.close(context);
      ShowToast.info(context, AppLocales.ordersNotFound.tr());
      return;
    }
    await _printMonitoring(dayOrders, dateTime: day);
  }

  Future<void> onPrintRangeMonitoring(DateTimeRange range) async {
    showAppLoadingDialog(context);
    final rangeOrders = await _getRangeOrders(range);
    if (rangeOrders.isEmpty) {
      AppRouter.close(context);
      ShowToast.info(context, AppLocales.ordersNotFound.tr());
      return;
    }
    await _printMonitoring(rangeOrders, range: range);
  }

  Future<void> _printMonitoring(List<Order> orders,
      {DateTime? dateTime, DateTimeRange? range}) async {
    // Fetch all necessary data for isolate
    final employees = await employeeDatabase.get();
    final products = await productDatabase.get();
    final percents = await percentDatabase.get();

    // Prepare data map for isolate
    final data = {
      'orders': orders,
      'employees': employees,
      'products': products,
      'percents': percents,
    };

    // Run calculation in isolate
    final result = await compute(calculateMonitoringIsolate, data);

    PrinterMonitoringServices pms = PrinterMonitoringServices(
      model: state,
      dateTime: dateTime,
      range: range,
      employeesMonitoring: result['employeesMonitoring'] as Map<String, EM>,
      ordersCount: result['ordersCount'] as int,
      orderPercentSumm: result['orderPercentSumm'] as double,
      ordersTotalProductSumm: result['ordersTotalProductSumm'] as double,
      ordersTotalSumm: result['ordersTotalSumm'] as double,
      productsMonitoring:
          result['productsMonitoring'] as Map<String, OrderItem>,
      paymentMonitoring: result['paymentMonitoring'] as Map<String, double>,
      placesTotalSumm: result['placesTotalSumm'] as double,
    );

    pms.printOrderCheck();

    AppRouter.close(context);
  }
}
