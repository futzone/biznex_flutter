import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/database/isar_database/isar_extension.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/database/order_database/order_percent_database.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/order_models/order.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/core/model/order_models/percent_model.dart';
import 'package:biznex/src/core/model/other_models/customer_model.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/core/model/transaction_model/transaction_model.dart';
import 'package:biznex/src/core/services/printer_services.dart';
import 'package:biznex/src/providers/employee_orders_provider.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/providers/orders_provider.dart';
import 'package:biznex/src/providers/products_provider.dart';
import 'package:biznex/src/ui/pages/order_pages/table_choose_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:isar/isar.dart';
import '../providers/recipe_providers.dart';
import 'package:biznex/src/core/database/audit_log_database/logger_service.dart';

class OrderController {
  final Employee employee;
  final Place place;
  final AppModel model;

  OrderController({
    required this.model,
    required this.place,
    required this.employee,
  });

  static final OrderDatabase _database = OrderDatabase();
  static final Isar _isar = IsarDatabase.instance.isar;
  static final ProductDatabase _productDatabase = ProductDatabase();

  Future<List<OrderItem>> _sanitizeItems(List<OrderItem> items) async {
    final List<OrderItem> sanitized = [];
    for (final item in items) {
      final dbProduct = await _productDatabase.getProductById(item.product.id);
      if (dbProduct != null) {
        sanitized.add(item.copyWith(product: dbProduct));
      } else {
        sanitized.add(item);
      }
    }
    return sanitized;
  }

  static Future<void> onDeleteOrder(String id, BuildContext context) async {
    final order = await _database.getOrderIsar(id);
    if (order != null) {
      _isar.writeTxn(() async {
        await _isar.orderIsars.delete(order.isarId);
      });

      for (final item in order.products) {
        final tempProduct = await _productDatabase.getProductById(
          item.product?.id ?? '',
        );

        if (tempProduct == null) continue;
        tempProduct.amount = tempProduct.amount + item.amount;
        await _productDatabase.update(key: tempProduct.id, data: tempProduct);
      }

      await LoggerService.save(
        logType: LogType.order,
        actionType: ActionType.delete,
        itemId: id,
        oldValue: jsonEncode(Order.fromIsar(order).toJson()),
      );
    }
  }

  static Future<void> onUpdateOrder(Order order, BuildContext context) async {
    final isarOrder = await _database.getOrderIsar(order.id);
    if (isarOrder != null) {
      OrderIsar orderIsar = order.toIsar();
      orderIsar.updatedDate = DateTime.now().toIso8601String();
      orderIsar.isarId = isarOrder.isarId;

      _isar.writeTxn(() async {
        await _isar.orderIsars.put(orderIsar);
      });
    }
  }

  Future<void> openOrder(
    BuildContext context,
    WidgetRef ref,
    List<OrderItem> products, {
    String? note,
    Customer? customer,
    DateTime? scheduledDate,
    String? message,
  }) async {
    if (!context.mounted) return;
    if (!context.mounted) return;
    showAppLoadingDialog(context);

    // Sanitize products
    products = await _sanitizeItems(products);

    double totalPrice = products.fold(0.0, (oldValue, element) {
      return oldValue + (element.amount * element.product.price);
    });

    Order order = Order(
      paymentTypes: [],
      place: place,
      employee: employee,
      price: totalPrice,
      products: products,
      createdDate: DateTime.now().toIso8601String(),
      updatedDate: DateTime.now().toIso8601String(),
      customer: customer,
      note: note,
      scheduledDate: scheduledDate?.toIso8601String(),
      orderNumber: DateTime.now().millisecondsSinceEpoch.toString(),
    );

    await _database.setPlaceOrder(
      data: order,
      placeId: place.id,
      message: message,
    );

    try {
      ref.invalidate(ordersProvider(place.id));
      ref.invalidate(ordersProvider);
      await ref.refresh(ordersProvider(place.id).future).then((order) {
        if (order != null) {
          ref.read(orderSetProvider.notifier).clearPlaceItems(place.id);
          Future.delayed(Duration(milliseconds: 100));
          ref
              .read(orderSetProvider.notifier)
              .addMultiple(order.products, context, order: order);
        } else {
          // ref.read(orderSetProvider.notifier).clear();
        }
      });
    } catch (_) {}
    ShowToast.success(context, AppLocales.orderCreatedSuccessfully.tr());

    await LoggerService.save(
      logType: LogType.order,
      actionType: ActionType.create,
      itemId: order.id,
      newValue: jsonEncode(order.toJson()),
    );

    // PrinterMultipleServices printerMultipleServices = PrinterMultipleServices();
    // printerMultipleServices.printForBack(order, products);
    if (!context.mounted) return;
    AppRouter.close(context);
  }

  Future<void> addItems(
    BuildContext context,
    WidgetRef ref,
    List<OrderItem> newItemsList,
    Order oldOrderState, {
    String? note,
    String? message,
    Customer? customer,
    DateTime? scheduledDate,
  }) async {
    if (!context.mounted) return;
    try {
      showAppLoadingDialog(context);

      // Sanitize items
      newItemsList = await _sanitizeItems(newItemsList);

      Order? currentState = await _database.getPlaceOrder(place.id);
      if (currentState == null) {
        if (context.mounted) AppRouter.close(context);
        return;
      }

      if (hasNegative(ref,
          newList: newItemsList, savedList: currentState.products)) {
        if (context.mounted) AppRouter.close(context);
        ShowToast.error(context, AppLocales.doNotDecreaseText.tr());
        return;
      }

      double totalPrice = newItemsList.fold(0.0, (oldValue, element) {
        return oldValue + (element.amount * element.product.price);
      });

      Order updatedOrder = currentState.copyWith(
        products: List<OrderItem>.from(newItemsList),
        price: totalPrice,
        customer: customer ?? currentState.customer,
        note: note ?? currentState.note,
        scheduledDate:
            scheduledDate?.toIso8601String() ?? currentState.scheduledDate,
        updatedDate: DateTime.now().toIso8601String(),
      );

      await _database.updatePlaceOrder(
          data: updatedOrder, placeId: place.id, message: message);

      await LoggerService.save(
        logType: LogType.order,
        actionType: ActionType.update,
        itemId: updatedOrder.id,
        oldValue: jsonEncode(currentState.toJson()),
        newValue: jsonEncode(updatedOrder.toJson()),
      );
    } catch (_) {}

    if (!context.mounted) return;
    try {
      ref.invalidate(ordersProvider(place.id));
      ref.invalidate(ordersProvider);
    } catch (_) {}
    AppRouter.close(context);
  }

  static Future<Order?> getCurrentOrder(String placeId) async {
    OrderDatabase database = OrderDatabase();
    final state = await database.getPlaceOrder(placeId);
    return state;
  }

  Future<void> closeOrder(
    BuildContext context,
    WidgetRef ref, {
    String? note,
    Customer? customer,
    DateTime? scheduledDate,
    String? paymentType,
    bool useCheck = true,
    String? address,
    String? phone,
    Order? existingOrder,
  }) async {
    if (!context.mounted) return;
    showAppLoadingDialog(context);

    Order? currentOrderData =
        existingOrder ?? await _database.getPlaceOrder(place.id);
    Order orderToProcess;

    if (currentOrderData == null) {
      final orderItemsFromProvider = ref.read(orderSetProvider);
      var productsForNewOrder =
          orderItemsFromProvider.where((e) => e.placeId == place.id).toList();

      // Sanitize products
      productsForNewOrder = await _sanitizeItems(productsForNewOrder);

      double totalPrice = productsForNewOrder.fold(0.0, (oldValue, element) {
        return oldValue + (element.amount * element.product.price);
      });

      orderToProcess = Order(
        note: note,
        paymentTypes: [],
        place: place,
        employee: employee,
        price: totalPrice,
        customer: customer,
        products: productsForNewOrder,
        createdDate: DateTime.now().toIso8601String(),
        updatedDate: DateTime.now().toIso8601String(),
        orderNumber: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    } else {
      orderToProcess = currentOrderData;
      // Sanitize products in existing order
      final sanitizedProducts = await _sanitizeItems(orderToProcess.products);
      orderToProcess = orderToProcess.copyWith(products: sanitizedProducts);
    }

    Order finalOrder = orderToProcess;

    final percents = await OrderPercentDatabase().get();
    if (!place.percentNull) {
      final totalPercent =
          percents.map((e) => e.percent).fold(0.0, (a, b) => a + b);
      finalOrder = finalOrder.copyWith(
        price: finalOrder.price +
            (finalOrder.price * (finalOrder.place.percent ?? 0) * 0.01) +
            ((finalOrder.price + (finalOrder.place.price ?? 0.0)) *
                (totalPercent / 100)),
      );
    }

    if (place.price != null) {
      finalOrder = finalOrder.copyWith(price: finalOrder.price + place.price!);
    }

    // Apply feePercent if it exists
    if (finalOrder.feePercent != null && finalOrder.feePercent! > 0) {
      finalOrder = finalOrder.copyWith(
        price: finalOrder.price * (1 + (finalOrder.feePercent! * 0.01)),
      );
    }

    if (customer != null) finalOrder = finalOrder.copyWith(customer: customer);
    if (note != null) finalOrder = finalOrder.copyWith(note: note);
    if (scheduledDate != null) {
      finalOrder = finalOrder.copyWith(
        scheduledDate: scheduledDate.toIso8601String(),
      );
    }

    finalOrder = finalOrder.copyWith(
      place: place,
      status: Order.completed,
      updatedDate: DateTime.now().toIso8601String(),
    );

    if (finalOrder.paymentTypes.isEmpty) {
      finalOrder = finalOrder.copyWith(
        paymentTypes: [
          Percent(name: Transaction.cash, percent: finalOrder.price),
        ],
      );
    }

    await _database.saveOrder(finalOrder);

    await _database.closeOrder(placeId: place.id);

    try {
      ref.invalidate(ordersProvider(place.id));
      ref.invalidate(ordersProvider);
      ref.invalidate(productsProvider);
      ref.invalidate(employeeOrdersProvider);
      ref.invalidate(ingredientTransactionsProvider);
      ref.invalidate(ingredientsProvider);
      ref.invalidate(todayOrdersProvider);
      ref.invalidate(dayOrdersProvider);
      ref.invalidate(orderLengthProvider);
      final notifier = ref.read(orderSetProvider.notifier);
      notifier.clearPlaceItemsCloser(place.id);
      ShowToast.success(context, AppLocales.orderClosedSuccessfully.tr());

      await LoggerService.save(
        logType: LogType.order,
        actionType: ActionType.close,
        itemId: finalOrder.id,
        newValue: jsonEncode(finalOrder.toJson()),
        oldValue: currentOrderData?.toJson().toString(),
      );
    } catch (_) {}

    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    try {
      if (!Platform.isWindows) {
        AppRouter.openPage(context, TableChooseScreen());
      }
    } catch (error, st) {
      log("fuck off: ", error: error, stackTrace: st);
    }
  }

  Future<void> onUpdateAmounts(Order order, ref) async {
    ProductDatabase productDatabase = ProductDatabase();
    for (final item in order.products) {
      Product product = item.product;
      if (product.unlimited) continue;

      if (product.amount == 1) continue;

      Product updatedProduct =
          product.copyWith(amount: product.amount - item.amount);
      await productDatabase.update(key: product.id, data: updatedProduct);
    }

    ref.invalidate(productsProvider);
    ref.refresh(productsProvider);
  }

  List<OrderItem> onGetChanges(
      List<OrderItem> newItemsList, Order oldOrderState) {
    final List<OrderItem> changes = [];
    final Map<String, OrderItem> oldItemsMap = {
      for (var item in oldOrderState.products) item.product.id: item
    };
    final Map<String, OrderItem> newItemsMap = {
      for (var item in newItemsList) item.product.id: item
    };

    for (final newItem in newItemsList) {
      final oldItem = oldItemsMap[newItem.product.id];
      if (oldItem == null) {
        changes.add(newItem.copyWith());
      } else {
        if (newItem.amount != oldItem.amount) {
          changes
              .add(newItem.copyWith(amount: newItem.amount - oldItem.amount));
        }
      }
    }

    for (final oldItem in oldOrderState.products) {
      if (!newItemsMap.containsKey(oldItem.product.id)) {
        changes.add(oldItem.copyWith(amount: -oldItem.amount));
      }
    }
    return changes;
  }

  Future<void> printCheck(String orderId) async {
    await _database.printOrderRecipe(orderId);
  }

  Future<void> saveOrderPayments(
    BuildContext context,
    WidgetRef ref,
    List<Percent> paymentTypes,
    Order order,
  ) async {
    if (!context.mounted) return;
    showAppLoadingDialog(context);

    Order newOrder = order.copyWith(
      updatedDate: DateTime.now().toIso8601String(),
      paymentTypes: paymentTypes,
    );

    await _database.updatePlaceOrder(
      data: newOrder,
      placeId: place.id,
      message: null,
    );

    await LoggerService.save(
      logType: LogType.order,
      actionType: ActionType.update,
      itemId: newOrder.id,
      oldValue: jsonEncode(order.toJson()),
      newValue: jsonEncode(newOrder.toJson()),
    );

    if (!context.mounted) return;

    log(newOrder.toJson().toString());
    AppRouter.close(context);
  }

  static bool hasNegative(
    WidgetRef ref, {
    required List<OrderItem> newList,
    required List<OrderItem> savedList,
  }) {
    final employee = ref.watch(currentEmployeeProvider);
    if (employee.roleName.toLowerCase() == 'admin') return false;
    if (savedList.isEmpty) return false;
    if (newList.isEmpty) return true;

    for (final item in savedList) {
      final newItem =
          newList.where((e) => e.product.id == item.product.id).firstOrNull;

      if (newItem == null) return true;

      if (newItem.amount < item.amount) return true;
    }

    return false;
  }

  static bool hasNegativeItem(
    WidgetRef ref, {
    required OrderItem item,
    required List<OrderItem> savedList,
  }) {
    final employee = ref.watch(currentEmployeeProvider);
    if (employee.roleName.toLowerCase() == 'admin') return false;

    if (savedList.isEmpty) return false;

    final savedItem = savedList.where((el) => el.product.id == item.product.id);
    if (savedItem.isEmpty) return true;
    if ((savedItem.firstOrNull?.amount ?? 0) > item.amount) return true;

    return false;
  }
}
