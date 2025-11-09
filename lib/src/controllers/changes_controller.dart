import 'dart:convert';
import 'dart:developer';
import 'package:biznex/src/core/database/employee_database/employee_database.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/database/order_database/order_percent_database.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/core/database/transactions_database/transactions_database.dart';
import 'package:biznex/src/core/extensions/for_dynamic.dart';
import 'package:biznex/src/core/model/app_changes_model.dart';
import 'package:biznex/src/core/model/cloud_models/order.dart';
import 'package:biznex/src/core/model/cloud_models/percent.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/core/model/transaction_model/transaction_model.dart';
import 'package:biznex/src/core/network/endpoints.dart';
import 'package:biznex/src/core/network/network_base.dart';
import 'package:biznex/src/core/network/network_services.dart';
import 'package:biznex/src/core/services/license_services.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:uuid/uuid.dart';

class ChangesController {
  Change change;

  ChangesController(this.change);

  final Network network = Network();
  final LicenseServices licenseServices = LicenseServices();

  Future<String> _getDeviceId() async {
    return await licenseServices.getDeviceId() ?? '';
  }

  Future<bool> saveStatus() async {
    if (!(await network.isConnected())) return false;

    log("save status working");
    if (change.database == ProductDatabase().boxName) {
      return await _ifProductChanges();
    }

    if (change.database == EmployeeDatabase().boxName) {
      return await _ifEmployeeChanges();
    }

    if (change.database == TransactionsDatabase().boxName) {
      return await _ifTransactionChanges();
    }

    if (change.database == OrderPercentDatabase().boxName) {
      return await _ifPercentChanges();
    }

    var boxName = 'orders';

    if (change.database == boxName) {
      return await _ifOrderChanges();
    }

    return await _ifClientChanges();
  }

  Future<bool> _ifClientChanges() async {
    if (change.method == 'login') {
      String employeeName = change.itemId.capitalize;
      if (employeeName.toLowerCase() != 'admin') {
        Employee? employee = await EmployeeDatabase().getOne(change.itemId);
        if (employee != null) {
          employeeName = "${employee.fullname} (${employee.roleName})";
        }
      }

      final requestBody = {
        "id": Uuid().v4(),
        "client_id": await _getDeviceId(),
        "order_id": change.database == 'orders' ? change.itemId : null,
        "employee_id": change.database == EmployeeDatabase().boxName ? change.itemId : null,
        "product_id": change.database == ProductDatabase().boxName ? change.itemId : null,
        "type": change.method == 'delete' ? 'danger' : 'warning',
        "info": "$employeeName##login_to_app",
        "created_at": change.createdDate.notNullOrEmpty(DateTime.now().toIso8601String()),
      };

      final response = await network.post(ApiEndpoints.action, body: requestBody);

      return response;
    }

    if (change.database == "app" && change.method == "update" && change.itemId == "pincode") {
      final requestBody = {
        "id": Uuid().v4(),
        "client_id": await _getDeviceId(),
        "order_id": null,
        "employee_id": null,
        "product_id": null,
        "type": 'danger',
        "info": 'admin_changes_pincode##${change.data}',
        "created_at": change.createdDate.notNullOrEmpty(DateTime.now().toIso8601String()),
      };

      final response = await network.post(ApiEndpoints.action, body: requestBody);

      return response;
    }

    return false;
  }

  Future<bool> _ifPercentChanges() async {
    if (change.method == "create") {
      OrderPercentDatabase percentDatabase = OrderPercentDatabase();
      var percent = await percentDatabase.getPercentById(change.itemId);
      if (percent == null) return true;
      CloudPercent cloudPercent = CloudPercent(
        id: percent.id,
        name: percent.name,
        percent: percent.percent,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        clientId: await _getDeviceId(),
      );

      final response = await network.post(
        ApiEndpoints.percent,
        body: cloudPercent.toJson(),
      );

      return response;
    }

    if (change.method == "delete") {
      OrderPercentDatabase percentDatabase = OrderPercentDatabase();
      var percent = await percentDatabase.getPercentById(change.itemId);
      if (percent == null) return true;
      CloudPercent cloudPercent = CloudPercent(
        id: percent.id,
        name: percent.name,
        percent: percent.percent,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
        clientId: await _getDeviceId(),
      );

      final response = await network.delete(
        ApiEndpoints.percentOne(cloudPercent.id),
        body: cloudPercent.toJson(),
      );

      return response;
    }

    return false;
  }

  Future<bool> _ifProductChanges() async {
    if (change.method == "create") {
      ProductDatabase productDatabase = ProductDatabase();
      var product = await productDatabase.getProductById(change.itemId);
      if (product == null) return true;

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

      final response = await network.post(
        ApiEndpoints.product,
        body: cloudProduct.toJson(),
      );

      return response;
    }

    if (change.method == "update") {
      ProductDatabase productDatabase = ProductDatabase();
      var product = await productDatabase.getProductById(change.itemId);
      if (product == null) return true;
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

      final response = await network.put(
        ApiEndpoints.productOne(cloudProduct.clientId),
        body: cloudProduct.toJson(),
      );

      return response;
    }

    if (change.method == "delete") {
      ProductDatabase productDatabase = ProductDatabase();
      var product = await productDatabase.getProductById(change.itemId);
      if (product == null) return true;
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
      final response = await network.delete(
        ApiEndpoints.productOne(cloudProduct.clientId),
        body: cloudProduct.toJson(),
      );
      return response;
    }
    return false;
  }

  Future<bool> _ifEmployeeChanges() async {
    if (change.method == "create") {
      EmployeeDatabase employeeDatabase = EmployeeDatabase();
      var employee = await employeeDatabase.getOne(change.itemId);
      if (employee == null) return true;

      CloudEmployee cloudEmployee = CloudEmployee(
        id: employee.id,
        roleName: employee.roleName,
        createdAt: employee.createdDate,
        updatedAt: DateTime.now().toIso8601String(),
        clientId: await _getDeviceId(),
        password: employee.pincode,
        name: employee.fullname,
      );

      final response = await network.post(
        ApiEndpoints.employee,
        body: cloudEmployee.toJson(),
      );

      return response;
    }

    if (change.method == "update") {
      EmployeeDatabase employeeDatabase = EmployeeDatabase();
      var employee = await employeeDatabase.getOne(change.itemId);
      if (employee == null) return true;

      CloudEmployee cloudEmployee = CloudEmployee(
        id: employee.id,
        roleName: employee.roleName,
        createdAt: employee.createdDate,
        updatedAt: DateTime.now().toIso8601String(),
        clientId: await _getDeviceId(),
        password: employee.pincode,
        name: employee.fullname,
      );

      final response = await network.put(
        ApiEndpoints.employeeOne(cloudEmployee.clientId),
        body: cloudEmployee.toJson(),
      );

      return response;
    }

    if (change.method == "delete") {
      EmployeeDatabase employeeDatabase = EmployeeDatabase();
      var employee = await employeeDatabase.getOne(change.itemId);
      if (employee == null) return true;

      CloudEmployee cloudEmployee = CloudEmployee(
        id: employee.id,
        roleName: employee.roleName,
        createdAt: employee.createdDate,
        updatedAt: DateTime.now().toIso8601String(),
        clientId: await _getDeviceId(),
        password: employee.pincode,
        name: employee.fullname,
      );

      final response = await network.delete(
        ApiEndpoints.employeeOne(cloudEmployee.clientId),
        body: cloudEmployee.toJson(),
      );

      return response;
    }
    return false;
  }

  Future<bool> _ifTransactionChanges() async {
    if (change.method == "create") {
      TransactionsDatabase transactionDatabase = TransactionsDatabase();
      var transaction = await transactionDatabase.getTransactionById(change.itemId);
      if (transaction == null) return true;

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

      final response = await network.post(
        ApiEndpoints.transaction,
        body: cloudTransaction.toJson(),
      );

      return response;
    }

    if (change.method == "update") {
      TransactionsDatabase transactionDatabase = TransactionsDatabase();
      var transaction = await transactionDatabase.getTransactionById(change.itemId);
      if (transaction == null) return true;

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

      final response = await network.put(
        ApiEndpoints.transactionOne(cloudTransaction.clientId),
        body: cloudTransaction.toJson(),
      );

      return response;
    }

    if (change.method == "delete") {
      TransactionsDatabase transactionDatabase = TransactionsDatabase();
      var transaction = await transactionDatabase.getTransactionById(change.itemId);
      if (transaction == null) return true;

      CloudTransaction cloudTransaction = CloudTransaction(
        id: transaction.id,
        orderId: transaction.order?.id ?? '',
        employeeId: transaction.employee?.id ?? '',
        note: transaction.note,
        createdAt: transaction.createdDate,
        updatedAt: DateTime.now().toIso8601String(),
        clientId: await _getDeviceId(),
        amount: transaction.value,
      );

      final response = await network.delete(
        ApiEndpoints.transactionOne(cloudTransaction.clientId),
        body: cloudTransaction.toJson(),
      );

      return response;
    }
    return false;
  }

  Future<bool> _ifOrderChanges() async {
    if (change.method == "create") {
      OrderDatabase orderDatabase = OrderDatabase();

      var order = await orderDatabase.getOrderById(change.itemId);
      if (order == null) return true;

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

      final response = await network.post(
        ApiEndpoints.order,
        body: cloudOrder.toJson(),
      );

      return response;
    }

    return false;
  }
}

String _getPlaceName(Place place) {
  if (place.father != null && place.father!.name.isNotEmpty) {
    return "${place.father?.name}, ${place.name}";
  }
  return place.name;
}
