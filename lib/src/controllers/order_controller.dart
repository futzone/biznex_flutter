import 'dart:developer';
import 'dart:io';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/database/order_database/order_percent_database.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/core/model/order_models/percent_model.dart';
import 'package:biznex/src/core/model/other_models/customer_model.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/core/model/transaction_model/transaction_model.dart';
import 'package:biznex/src/core/services/printer_services.dart';
import 'package:biznex/src/providers/employee_orders_provider.dart';
import 'package:biznex/src/providers/orders_provider.dart';
import 'package:biznex/src/providers/products_provider.dart';
import 'package:biznex/src/ui/pages/order_pages/table_choose_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import '../providers/recipe_providers.dart';

class OrderController {
  final Employee employee;
  final Place place;
  final AppModel model;

  OrderController({
    required this.model,
    required this.place,
    required this.employee,
  });

  final OrderDatabase _database = OrderDatabase();

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
    showAppLoadingDialog(context);

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

      Order? currentState = await _database.getPlaceOrder(place.id);
      if (currentState == null) {
        if (context.mounted) AppRouter.close(context);
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
  }) async {
    if (!context.mounted) return;
    showAppLoadingDialog(context);

    Order? currentOrderData = await _database.getPlaceOrder(place.id);
    Order orderToProcess;

    if (currentOrderData == null) {
      final orderItemsFromProvider = ref.read(orderSetProvider);
      final productsForNewOrder =
          orderItemsFromProvider.where((e) => e.placeId == place.id).toList();

      double totalPrice = productsForNewOrder.fold(0.0, (oldValue, element) {
        return oldValue + (element.amount * element.product.price);
      });

      orderToProcess = Order(
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
    }

    Order finalOrder = orderToProcess;

    final percents = await OrderPercentDatabase().get();
    if (!place.percentNull) {
      final totalPercent =
          percents.map((e) => e.percent).fold(0.0, (a, b) => a + b);
      finalOrder = finalOrder.copyWith(
          price: finalOrder.price +
              ((finalOrder.price + (finalOrder.place.price ?? 0.0)) *
                  (totalPercent / 100)));
    }

    if (place.price != null) {
      finalOrder = finalOrder.copyWith(price: finalOrder.price + place.price!);
    }

    if (customer != null) finalOrder = finalOrder.copyWith(customer: customer);
    if (note != null) finalOrder = finalOrder.copyWith(note: note);
    if (scheduledDate != null) {
      finalOrder =
          finalOrder.copyWith(scheduledDate: scheduledDate.toIso8601String());
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

  Future<void> printCheck(
    BuildContext context,
    WidgetRef ref, {
    String? note,
    Customer? customer,
    DateTime? scheduledDate,
    String? paymentType,
    bool useCheck = true,
    String? phone,
    String? address,
  }) async {
    if (!context.mounted) return;
    showAppLoadingDialog(context);

    Order? currentOrderData = await _database.getPlaceOrder(place.id);
    Order orderToProcess;

    if (currentOrderData == null) {
      final orderItemsFromProvider = ref.read(orderSetProvider);
      final productsForNewOrder =
          orderItemsFromProvider.where((e) => e.placeId == place.id).toList();

      double totalPrice = productsForNewOrder.fold(0.0, (oldValue, element) {
        return oldValue + (element.amount * element.product.price);
      });

      orderToProcess = Order(
        paymentTypes: [],
        place: place,
        employee: employee,
        price: totalPrice,
        products: productsForNewOrder,
        createdDate: DateTime.now().toIso8601String(),
        updatedDate: DateTime.now().toIso8601String(),
        orderNumber: DateTime.now().millisecondsSinceEpoch.toString(),
      );
    } else {
      orderToProcess = currentOrderData;
    }

    Order finalOrder = orderToProcess.copyWith();

    final percents = await OrderPercentDatabase().get();
    if (!place.percentNull) {
      log(place.toJson().toString());
      final totalPercent =
          percents.map((e) => e.percent).fold(0.0, (a, b) => a + b);
      finalOrder = finalOrder.copyWith(
          price: finalOrder.price + (finalOrder.price * (totalPercent / 100)));
    }

    if (customer != null) finalOrder = finalOrder.copyWith(customer: customer);
    if (note != null) finalOrder = finalOrder.copyWith(note: note);
    if (scheduledDate != null) {
      finalOrder =
          finalOrder.copyWith(scheduledDate: scheduledDate.toIso8601String());
    }

    finalOrder = finalOrder.copyWith(
        status: Order.completed, updatedDate: DateTime.now().toIso8601String());
    AppRouter.close(context);

    PrinterServices printerServices =
        PrinterServices(order: finalOrder, model: model);
    printerServices.printOrderCheck(phone: phone, address: address);
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

    if (!context.mounted) return;

    log(newOrder.toJson().toString());
    AppRouter.close(context);
  }
}
