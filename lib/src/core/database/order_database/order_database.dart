import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:biznex/main.dart';
import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/database/changes_database/changes_database.dart';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/database/isar_database/isar_extension.dart';
import 'package:biznex/src/core/database/transactions_database/transactions_database.dart';
import 'package:biznex/src/core/model/order_models/order.dart';
import 'package:biznex/src/core/model/order_models/order_filter_model.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

import '../../../../biznex.dart';
import '../../../controllers/warehouse_monitoring_controller.dart';
import '../../model/app_changes_model.dart';
import '../../model/product_models/product_model.dart';
import '../../model/transaction_model/transaction_model.dart';
import '../../services/printer_multiple_services.dart';
import '../../services/printer_services.dart';
import '../product_database/product_database.dart';
import 'order_db_repository.dart';

class OrderDatabase extends OrderDatabaseRepository {
  ChangesDatabase changesDatabase = ChangesDatabase();
  Isar isar = IsarDatabase.instance.isar;

  String boxName = "orders";

  ///Old version methods
  ///It is methods need for: migrate db from old version
  String _getBoxName(id) => "orders_$id";

  Future<Box> _openBox(String boxName) async {
    final box = await Hive.openBox(boxName);
    return box;
  }

  Future<void> migrateFromHiveDatabase() async {
    final box = await _openBox(_getBoxName('all'));
    if (box.isEmpty) return;
    for (final value in box.values) {
      final Order order = Order.fromJson(value);
      await saveOrder(order);
    }

    await box.clear();
    await box.deleteFromDisk();
    log("migrating completed");
  }

  String get generateID {
    var uuid = Uuid();
    return uuid.v1();
  }

  Future<List<Order>> getEmployeeOrders(String id) async {
    List<Order> ordersList = [];

    final response = await getRemote(path: 'employee-orders/$id');
     if (response != null) {
       for (final item in jsonDecode(response)) {
        ordersList.add(Order.fromJson(item));
      }
    }

    return ordersList;
  }

  Future<List<Order>> getOrders() async {
    List<Order> ordersList = [];
    if ((await connectionStatus()) != null) {
      final response = await getRemote(path: 'orders');
      if (response != null) {
        for (final item in jsonDecode(response)) {
          ordersList.add(Order.fromJson(item));
        }
      }

      return ordersList;
    }

    final orders = await isar.orderIsars.where().findAll();
    for (final item in orders) {
      ordersList.add(Order.fromIsar(item));
    }

    return ordersList;
  }

  Future<List<OrderIsar>> getDayOrders(DateTime day) {
    return isar.orderIsars
        .filter()
        .createdDateStartsWith(day.toIso8601String().split("T").first)
        .sortByCreatedDateDesc()
        .findAll();
  }

  Future<List<OrderIsar>> getRangeOrders(DateTime start, DateTime end) {
    return isar.orderIsars
        .filter()
        .createdDateBetween(start.toIso8601String(), end.toIso8601String())
        .sortByCreatedDateDesc()
        .findAll();
  }

  Future<void> deleteOrder(String id) async {
    await isar.writeTxn(() async {
      final orderIsar =
          await isar.orderIsars.filter().idEqualTo(id).findFirst();
      if (orderIsar != null) {
        await isar.orderIsars.delete(orderIsar.isarId);
      }
    });
  }

  Future<void> saveOrder(Order order) async {
    if ((await connectionStatus()) != null) {
      await postRemote(path: 'orders', data: jsonEncode(order.toJson()));
      return;
    }

    final placeOrder = await getPlaceOrderIsar(order.place.id);
    if (placeOrder == null) {
      order.id = generateID;
      log("Saving place price: ${order.place.price}");
      await isar.writeTxn(() async {
        OrderIsar orderIsar = order.toIsar();
        orderIsar.closed = true;
        orderIsar.status = Order.completed;
        log("Saving place price (isar): ${orderIsar.place.price}");
        await isar.orderIsars.put(orderIsar);
      });
    } else {
      log("2 Saving place price: ${order.place.price}");
      order.id = placeOrder.id;
      await isar.writeTxn(() async {
        OrderIsar orderIsar = order.toIsar();
        orderIsar.closed = true;
        orderIsar.status = Order.completed;
        orderIsar.isarId = placeOrder.isarId;
        await isar.orderIsars.put(orderIsar);
        log("2 Saving place price (isar): ${orderIsar.place.price}");
      });
    }

    await _onUpdateAmounts(order);

    try {
      Transaction transaction = Transaction(
        value: order.price,
        order: order,
        employee: order.employee,
        paymentType: order.paymentTypes.isEmpty
            ? 'cash'
            : order.paymentTypes.map((e) => e.name).toList().join(", "),
        note: AppLocales.byOrder.tr(),
      );
      await TransactionsDatabase().set(data: transaction);
    } catch (error) {
      log("Error on creating transaction:", error: error);
    }

    try {
      await WarehouseMonitoringController.updateIngredientDetails(
        products: order.products,
      );
    } catch (error) {
      log("Error on save AAA: $error");
      return;
    }

    try {
      await changesDatabase.set(
        data: Change(
          database: 'orders',
          method: 'create',
          itemId: order.id,
        ),
      );
    } catch (_) {}

    try {
      final model = await AppStateDatabase().getApp();
      PrinterServices printerServices =
          PrinterServices(order: order, model: model);
      printerServices.printOrderCheck();
    } catch (e) {
      log("$e");
    }
  }

  Future<OrderIsar?> getPlaceOrderIsar(String placeId) async {
    final orderIsar =
        await isar.orderIsars.filter().closedEqualTo(false).place((pl) {
      return pl.idEqualTo(placeId);
    }).findFirst();

    return orderIsar;
  }

  Future<Order?> getPlaceOrder(String placeId) async {
    if ((await connectionStatus()) != null) {
      final response = await getRemote(path: 'order/$placeId');
      if (response != null) {
        final order = Order.fromJson(jsonDecode(response));
        return order;
      }
    }

    if (!Platform.isWindows) return null;

    final orderIsar = await isar.orderIsars
        .filter()
        .statusEqualTo(Order.opened)
        .closedEqualTo(false)
        .place((pl) {
      return pl.idEqualTo(placeId);
    }).findFirst();

    if (orderIsar == null) return null;

    return Order.fromIsar(orderIsar);
  }

  Future<void> deletePlaceOrder(String placeId) async {
    if ((await connectionStatus()) != null) {
      await deleteRemote(path: 'order/$placeId');
      return;
    }

    final orderIsar =
        await isar.orderIsars.filter().closedEqualTo(false).place((pl) {
      return pl.idEqualTo(placeId);
    }).findFirst();
    await isar.writeTxn(() async {
      if (orderIsar != null) {
        await isar.orderIsars.delete(orderIsar.isarId);
      }
    });
  }

  Future<void> setPlaceOrder(
      {required data,
      required String placeId,
      required String? message,
      bool disablePrint = false}) async {
    if (data is! Order) return;

    final connStatus = (await connectionStatus());
    if (connStatus != null) {
      final dataMap = data.toJson();
      dataMap['disablePrint'] = disablePrint;
      dataMap['message'] = message;

      await postRemote(path: 'order/$placeId', data: jsonEncode(dataMap));
      return;
    }

    Order productInfo = data;
    productInfo.id = generateID;

    await isar.writeTxn(() async {
      await isar.orderIsars.put(productInfo.toIsar());
    });

    try {
      if (disablePrint) return;

      PrinterMultipleServices printerMultipleServices =
          PrinterMultipleServices();
      await printerMultipleServices.printForBack(
        message: message,
        productInfo,
        productInfo.products,
      );
    } catch (_) {
      ///
    }
  }

  Future<void> updatePlaceOrder({
    required data,
    required String placeId,
    required String? message,
  }) async {
    if (data is! Order) return;

    if ((await connectionStatus()) != null) {
      final dataMap = data.toJson();
      dataMap['message'] = message;

      await putRemote(path: 'order/$placeId', data: jsonEncode(dataMap));
      return;
    }

    final orderIsar =
        await isar.orderIsars.filter().closedEqualTo(false).place((pl) {
      return pl.idEqualTo(placeId);
    }).findFirst();

    Order order = data;
    OrderIsar newIsar = order.toIsar();

    await isar.writeTxn(() async {
      if (orderIsar != null) {
        // for(final item in orderIsar.products) {
        // newIsar.products.
        // }

        newIsar.isarId = orderIsar.isarId;
        await isar.orderIsars.put(newIsar);
      }
      await isar.orderIsars.put(newIsar);
    });

    try {
      if (orderIsar == null) return;
      PrinterMultipleServices printerMultipleServices =
          PrinterMultipleServices();
      final List<OrderItem> changes =
          _onGetChanges(order.products, Order.fromIsar(orderIsar));

      log('changes: ${changes.length}');

      await printerMultipleServices.printForBack(
        order,
        changes,
        message: message,
      );
    } catch (_) {
      ///
    }
  }

  Future<void> closeOrder({required String placeId}) async {
    if ((await connectionStatus()) != null) {
      await patchRemote(path: 'order/$placeId');
      return;
    }

    final order = await getPlaceOrder(placeId);
    log("Save order: ${order?.id}");
    if (order != null) {
      await _onUpdateAmounts(order);
      await saveOrder(order);
    }
  }

  Future<void> _onUpdateAmounts(Order order) async {
    try {
      ProductDatabase productDatabase = ProductDatabase();
      for (final item in order.products) {
        log('${item.product.unlimited}');
        if (item.product.unlimited) continue;

        Product product = item.product;
        if (product.amount <= item.amount) {
          product.amount = 0;
        } else {
          product.amount = product.amount - item.amount;
        }
        await productDatabase.update(key: product.id, data: product);
      }

      log("Update amounts completed for: ${order.id}");
    } catch (_) {
      log("Error on update amounts: ", error: _);

      ///
    }
  }

  Future<Order?> getOrderById(String id) async {
    final orderIsar = await isar.orderIsars.filter().idEqualTo(id).findFirst();
    if (orderIsar == null) return null;
    return Order.fromIsar(orderIsar);
  }

  getBoxName(String s) => 'orders';

  Future<void> printOrderRecipe(String orderId  ) async {
    await getRemote(path: 'order-recipe/$orderId');
  }
}

List<OrderItem> _onGetChanges(
    List<OrderItem> newItemsList, Order oldOrderState) {
  final List<OrderItem> changes = [];

  final oldItemsMap = {
    for (var item in oldOrderState.products) item.product.id: item
  };
  final newItemsMap = {for (var item in newItemsList) item.product.id: item};

  for (final newItem in newItemsList) {
    final oldItem = oldItemsMap[newItem.product.id];
    if (oldItem == null) {
      changes.add(newItem.copyWith());
    } else if (newItem.amount != oldItem.amount) {
      changes.add(newItem.copyWith(amount: newItem.amount - oldItem.amount));
    }
  }

  for (final oldItem in oldOrderState.products) {
    if (!newItemsMap.containsKey(oldItem.product.id)) {
      changes.add(oldItem.copyWith(amount: -oldItem.amount));
    }
  }

  return changes;
}
