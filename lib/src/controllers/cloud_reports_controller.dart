import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/database/employee_database/employee_database.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/database/order_database/order_percent_database.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/core/database/transactions_database/transactions_database.dart';
import 'package:biznex/src/core/model/cloud_models/client.dart';
import 'package:biznex/src/core/model/cloud_models/monitoring.dart';
import 'package:biznex/src/core/network/endpoints.dart';
import 'package:biznex/src/core/network/network_base.dart';
import 'package:biznex/src/core/network/network_services.dart';
import 'package:biznex/src/core/services/license_services.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';

import '../core/model/cloud_models/reports.dart';

/// State bilan bog'lanish uchun ref
///  Contextni boshqarish uchun context
///  Ekranda progres, masalan 98% deb chiqishi uchun progress notifier
class CloudReportsController {
  final WidgetRef ref;
  final BuildContext context;
  final ValueNotifier<double> progress;

  ///Hammasi required field
  CloudReportsController({
    required this.ref,
    required this.context,
    required this.progress,
  });

  /// Boshqa database va service lar uchun chaqiruv
  ///
  final OrderDatabase _orderDatabase = OrderDatabase();
  final OrderPercentDatabase _orderPercentDatabase = OrderPercentDatabase();
  final EmployeeDatabase _employeeDatabase = EmployeeDatabase();
  final ProductDatabase _productDatabase = ProductDatabase();
  final TransactionsDatabase _transactionsDatabase = TransactionsDatabase();
  final LicenseServices _licenseServices = LicenseServices();
  final Network _network = Network();

  /// Bu yerda hammasini jamlaymiz
  /// Masalan: Report yuborish, monitoringni yuborish, saqlab qo'yilgan actionlarni yuborish
  Future<void> startSendReports() async {
    /// Necha foizligini ko'rsatadi
    showAppProgressDialog(context, progress);

    /// Avval internetga ulanishni tekshiramiz
    /// Agar ulangan bo'lsa ishlaveramiz
    /// Ulanmagan bo'lsa toast chiqarib, ishni to'xtatamiz
    if (!(await _network.isConnected())) {
      AppRouter.close(context);
      ShowToast.error(context, AppLocales.internetConnectionError.tr());
      return;
    }

    /// Device id API bilan ishlashda doim required
    final deviceId = await _licenseServices.getDeviceId() ?? '';

    ///Barcha hisobotlar api
    /// Orders
    /// Profit
    /// Employees
    /// Total value va boshqalar
    await _sendReports(deviceId);

    ///Loadingni yopish
    AppRouter.close(context);

    ///Oxirida message chiqaramiz
    ShowToast.success(context, AppLocales.reportsSendSuccessfully.tr());
  }

  Future<void> _sendReports(String deviceId) async {
    final oldHave = await _network.get(ApiEndpoints.reportOneGet(deviceId));
    final reports = await _calculateReports();

    progress.value = 45.0;

    if (oldHave != null && oldHave is Map) {
      CloudReportModel cloudReportModel = CloudReportModel(
        clientId: deviceId,
        createdAt: oldHave['created_at'],
        updatedAt: DateTime.now().toIso8601String(),
        data: reports,
      );

      await _network.put(ApiEndpoints.reportOne(deviceId), body: cloudReportModel.toJson()).then((value) async {
        if (!value) {
          return;
        }

        progress.value = 48.0;
        final clientState = ref.watch(clientStateProvider).value;
        if (clientState == null) return;
        final NetworkServices networkServices = NetworkServices();
        Client client = clientState;
        client.updatedAt = DateTime.now().toIso8601String();
        await networkServices.updateClient(client).then((_) {
          ref.invalidate(clientStateProvider);
        });
      });

      return;
    }

    CloudReportModel cloudReportModel = CloudReportModel(
      clientId: deviceId,
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
      data: reports,
    );

    await _network.post(ApiEndpoints.report, body: cloudReportModel.toJson()).then((value) async {
      if (!value) {
        return;
      }
      progress.value = 48.0;
      final clientState = ref.watch(clientStateProvider).value;
      if (clientState == null) return;
      final NetworkServices networkServices = NetworkServices();
      Client client = clientState;
      client.updatedAt = DateTime.now().toIso8601String();
      await networkServices.updateClient(client).then((_) {
        ref.invalidate(clientStateProvider);
      });
    });
  }

  Future<Map<String, CloudReportItem>> _calculateReports() async {
    try {
      final now = DateTime.now();
      final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
      final orders = await _orderDatabase.getOrders();
      final percents = await _orderPercentDatabase.get();
      final products = await _productDatabase.getAll();
      final employees = await _employeeDatabase.get();
      final transactions = await _transactionsDatabase.get();
      final percent = percents.fold(0.0, (perc, item) => perc += item.percent);
      progress.value = 5.0;

      Map<String, CloudReportItem> reports = {};
      double totalOrdersSumm_ = 0.0;
      double totalProfit_ = 0.0;
      double totalProfitPercents_ = 0.0;
      double totalProfitProducts_ = 0.0;
      int employeeCount_ = employees.length;
      int orderCount_ = orders.length;
      int productCount_ = products.length;
      int transactionCount_ = transactions.length;

      for (final order in orders) {
        final productOldPrice = order.products.fold(0.0, (value, product) {
          final kPrice = (product.amount * (product.product.price * (1 - (100 / (100 + product.product.percent)))));

          return value += kPrice;
        });

        totalOrdersSumm_ += order.price;
        totalProfitProducts_ += productOldPrice;
        if (!order.place.percentNull) {
          totalProfitPercents_ += (order.price * (1 - (100 / (100 + percent))));
        }

        totalProfit_ = totalProfitProducts_ + totalProfitPercents_;
      }

      progress.value = 7.0;

      reports['all'] = CloudReportItem(
        day: 'all',
        totalOrdersSumm: totalOrdersSumm_,
        totalProfit: totalProfit_,
        totalProfitPercents: totalProfitPercents_,
        totalProfitProducts: totalProfitProducts_,
        transactionCount: transactionCount_,
        productCount: productCount_,
        employeeCount: employeeCount_,
        orderCount: orderCount_,
      );

      String day;
      double totalOrdersSumm = 0.0;
      double totalProfit = 0.0;
      double totalProfitPercents = 0.0;
      double totalProfitProducts = 0.0;
      int employeeCount = 0;
      int orderCount = 0;
      int productCount = 0;
      int transactionCount = 0;

      for (DateTime date = oneMonthAgo; !date.isAfter(now); date = date.add(Duration(days: 1))) {
        progress.value += 1;
        final dayOrders = orders.where((order) {
          final orderDate = DateTime.parse(order.createdDate);
          return orderDate.year == date.year && date.month == orderDate.month && date.day == orderDate.day;
        }).toList();
        day = date.toIso8601String();
        orderCount = dayOrders.length;
        for (final order in dayOrders) {
          final productOldPrice = order.products.fold(0.0, (value, product) {
            final kPrice = (product.amount * (product.product.price * (1 - (100 / (100 + product.product.percent)))));

            return value += kPrice;
          });

          totalOrdersSumm += order.price;
          totalProfitProducts += productOldPrice;
          if (!order.place.percentNull) {
            totalProfitPercents += (order.price * (1 - (100 / (100 + percent))));
          }

          totalProfit = totalProfitProducts + totalProfitPercents;
        }

        final dayTransactions = transactions.where((el) {
          final orderDate = DateTime.parse(el.createdDate);
          return orderDate.year == date.year && date.month == orderDate.month && date.day == orderDate.day;
        }).toList();

        transactionCount = dayTransactions.length;

        reports[day] = CloudReportItem(
          day: day,
          totalOrdersSumm: totalOrdersSumm,
          totalProfit: totalProfit,
          totalProfitPercents: totalProfitPercents,
          totalProfitProducts: totalProfitProducts,
          transactionCount: transactionCount,
          productCount: productCount,
          employeeCount: employeeCount,
          orderCount: orderCount,
        );
      }

      return reports;
    } catch (error) {
      return {};
    }
  }

  Future<Map<String, CloudMonitoringItem>> _calculateMonitoring() async {
    final orders = await _orderDatabase.getOrders();
    final employees = await _employeeDatabase.get();
    final products = await _productDatabase.getAll();
    Map<String, CloudMonitoringItem> monitoringData = {};
    return monitoringData;
  }
}
