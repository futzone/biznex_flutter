import 'dart:convert';

import 'package:biznex/src/core/database/employee_database/employee_database.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/core/database/transactions_database/transactions_database.dart';

import '../core/database/order_database/order_percent_database.dart';
import '../core/model/cloud_models/order.dart';
import '../core/model/cloud_models/percent.dart';
import '../core/model/employee_models/employee_model.dart';
import '../core/model/place_models/place_model.dart';
import '../core/model/product_models/product_model.dart';
import '../core/model/transaction_model/transaction_model.dart';
import '../core/network/endpoints.dart';
import '../core/network/network_base.dart';
import '../core/services/license_services.dart';

class CloudSynchronisingController {
  final Network network = Network();
  final OrderPercentDatabase percentDatabase = OrderPercentDatabase();
  final ProductDatabase productDatabase = ProductDatabase();
  final LicenseServices licenseServices = LicenseServices();
  final EmployeeDatabase employeeDatabase = EmployeeDatabase();
  final TransactionsDatabase transactionsDatabase = TransactionsDatabase();
  final OrderDatabase orderDatabase = OrderDatabase();

  Future<void> syncData() async {
    await _syncEmployee();
    await _syncPercents();
    await _syncProducts();
    await _syncOrders();
    await _syncTransactions();
  }

  Future<String> _getDeviceId() async {
    return await licenseServices.getDeviceId() ?? '';
  }

  Future _syncPercents() async {
    final percents = await percentDatabase.get();
    for (final percent in percents) {
      await Future.delayed(Duration(milliseconds: 300));
      try {
        CloudPercent cloudPercent = CloudPercent(
          id: percent.id,
          name: percent.name,
          percent: percent.percent,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
          clientId: await _getDeviceId(),
        );

        await network.post(
          ApiEndpoints.percent,
          body: cloudPercent.toJson(),
        );
      } catch (_) {
        continue;
      }
    }
  }

  Future _syncProducts() async {
    final products = await productDatabase.getAll();
    for (final product in products) {
      try {
        await Future.delayed(Duration(milliseconds: 300));
        CloudProduct cloudProduct = CloudProduct(
          id: product.id,
          name: product.name,
          price: product.price,
          createdAt: product.cratedDate ?? DateTime.now().toIso8601String(),
          updatedAt: product.updatedDate ?? DateTime.now().toIso8601String(),
          oldPrice: product.price / (1 + (product.percent / 100)),
          clientId: await _getDeviceId(),
          categoryName: product.category?.name ?? 'all',
          amount: product.amount,
        );

        await network.post(
          ApiEndpoints.product,
          body: cloudProduct.toJson(),
        );
      } catch (_) {
        continue;
      }
    }
  }

  Future _syncEmployee() async {
    final employees = await employeeDatabase.get();
    for (final employee in employees) {
      try {
        await Future.delayed(Duration(milliseconds: 300));
        CloudEmployee cloudEmployee = CloudEmployee(
          id: employee.id,
          roleName: employee.roleName,
          createdAt: employee.createdDate,
          updatedAt: DateTime.now().toIso8601String(),
          clientId: await _getDeviceId(),
          password: employee.pincode,
          name: employee.fullname,
        );

        await network.post(
          ApiEndpoints.employee,
          body: cloudEmployee.toJson(),
        );
      } catch (_) {
        continue;
      }
    }
  }

  Future _syncTransactions() async {
    final transactions = await transactionsDatabase.get();
    for (final transaction in transactions) {
      try {
        await Future.delayed(Duration(milliseconds: 300));
        CloudTransaction cloudTransaction = CloudTransaction(
          id: transaction.id,
          orderId: transaction.order?.id ?? '',
          employeeId: transaction.employee?.id ?? '',
          note: jsonEncode({
            "note": transaction.note,
            "type": transaction.paymentType,
          }),
          createdAt: transaction.createdDate,
          updatedAt: DateTime.now().toIso8601String(),
          clientId: await _getDeviceId(),
          amount: transaction.value,
        );

        await network.post(
          ApiEndpoints.transaction,
          body: cloudTransaction.toJson(),
        );
      } catch (_) {
        continue;
      }
    }
  }

  Future _syncOrders() async {
    final orders = await orderDatabase.getOrders();
    for (final order in orders) {
      try {
        await Future.delayed(Duration(milliseconds: 300));
        OrderPercentDatabase percentDatabase = OrderPercentDatabase();
        var percentList = await percentDatabase.get();

        TransactionsDatabase transactionsDatabase = TransactionsDatabase();
        final transaction = await transactionsDatabase.getOrderTransaction(order.id);

        CloudOrder cloudOrder = CloudOrder(
          id: order.id,
          clientId: await _getDeviceId(),
          items: [
            for (final item in order.products)
              CloudOrderItem(
                productId: item.product.id,
                amount: item.amount,
              ),
          ],
          status: order.status ?? '',
          paymentType: transaction?.paymentType ?? 'other',
          employeeId: order.employee.id.isEmpty ? await _getDeviceId() : order.employee.id,
          createdAt: order.createdDate,
          updatedAt: order.updatedDate,
          note: order.note ?? '',
          price: order.price,
          customer: order.customer?.name ?? '',
          place: _getPlaceName(order.place),
          percents: order.place.percentNull
              ? []
              : [
                  for (final percent in percentList)
                    CloudOrderPercent(
                      name: percent.name,
                      percent: percent.percent,
                    ),
                ],
        );

        await network.post(
          ApiEndpoints.order,
          body: cloudOrder.toJson(),
        );
      } catch (_) {
        continue;
      }
    }
  }

  String _getPlaceName(Place place) {
    if (place.father != null && place.father!.name.isNotEmpty) {
      return "${place.father?.name}, ${place.name}";
    }
    return place.name;
  }
}
