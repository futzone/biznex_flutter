import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/providers/orders_provider.dart';
import 'package:biznex/src/providers/products_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import '../core/database/order_database/order_database.dart';
import '../core/model/order_models/order_model.dart';
import 'employee_orders_provider.dart';

final orderSetProvider =
    StateNotifierProvider<OrderSetNotifier, List<OrderItem>>((ref) {
  return OrderSetNotifier(ref);
});

class OrderSetNotifier extends StateNotifier<List<OrderItem>> {
  final Ref ref;
  final OrderDatabase _orderDatabase = OrderDatabase();
  final AppStateDatabase _stateDatabase = AppStateDatabase();
  AppModel? model;

  OrderSetNotifier(this.ref) : super([]);

  Future<void> loadOrderForPlace(String placeId) async {
    if (state.any((item) => item.placeId == placeId)) {
      return;
    }

    final order = await _orderDatabase.getPlaceOrder(placeId);
    model = await _stateDatabase.getApp();

    if (order != null && order.products.isNotEmpty) {
      addMultiple(order.products, null);
    }
  }

  void addItem(OrderItem item, context) {
    final index = state.indexWhere(
        (e) => e.product.id == item.product.id && e.placeId == item.placeId);
    if (index != -1) {
      final updatedItemObject = state[index];
      if (updatedItemObject.product.amount >= updatedItemObject.amount + 1) {
        final updatedItem =
            state[index].copyWith(amount: state[index].amount + 1);
        state = [...state]..[index] = updatedItem;
      }
    } else {
      if (item.product.amount == 0) {
        ShowToast.error(context, AppLocales.productStockError.tr());
      }
      if (item.product.amount >= 1) state = [...state, item];
    }

    try {
      ref.invalidate(productsProvider);
      ref.refresh(productsProvider);
    } catch (_) {}
  }

  void removeItem(OrderItem item, AppModel model, context) {
    final current = ref.watch(currentEmployeeProvider);
    if (current.roleName.toLowerCase() != 'admin' && _itemIsSaved(item, null)) {
      return;
    }

    final index = state.indexWhere(
        (e) => e.product.id == item.product.id && e.placeId == item.placeId);
    if (index != -1) {
      final current = state[index];
      if (current.amount > 1) {
        final updatedItem = current.copyWith(amount: current.amount - 1);
        state = [...state]..[index] = updatedItem;
      } else {
        deleteItem(item, context, null);
      }
    }
  }

  void deleteItem(OrderItem item, context, Order? kOrder) async {
    final order = kOrder ?? ref.watch(ordersProvider(item.placeId)).value;

    final currentEmployee = ref.watch(currentEmployeeProvider);
    if (currentEmployee.roleName.toLowerCase() != 'admin') {
      final savedAmount = _getSavedAmount(item, order);
      if (savedAmount > 0) {
        ShowToast.error(context, AppLocales.doNotDecreaseText.tr());
        return;
      }
    }

    if (order == null && kOrder == null) {
      // Logic for when we truly don't have an order context (e.g. creating new order before place assignment?)
      // But typically we should have the placeId.
      // Existing logic for "if (kOrder == null)" at line 104 seems to handle non-saved state removal from local state.
      // If we passed permission check (savedAmount == 0), we can proceed.
    }

    // Checking if item exists in the actual order object (saved in DB)
    if (order != null &&
        order.products.isNotEmpty &&
        order.products
            .any((element) => element.product.id == item.product.id)) {
      // This block seems to be removing from local state if it WAS in order?
      // But if we are here, we passed the permission check implies savedAmount == 0.
      // So effectively it's not "in" the order as a saved non-zero item?
      // Or maybe it was saved with 0 amount? Unlikely.
      // If savedAmount > 0, we returned.

      // So we can proceed to remove from local state.
    }

    final index = state.indexWhere(
        (e) => e.product.id == item.product.id && e.placeId == item.placeId);
    if (index != -1) {
      state = [
        ...state.where((e) =>
            !(e.product.id == item.product.id && e.placeId == item.placeId))
      ];

      // FIX: Persist deletion if items remain (if empty, _onDeleteCache handles it)
      if (state.where((e) => e.placeId == item.placeId).isNotEmpty) {
        Order? dbOrder;
        // Try to get by ID first if we have context
        if (kOrder != null && kOrder.id.isNotEmpty) {
          dbOrder = await _orderDatabase.getOrderById(kOrder.id);
        }

        // Fallback to place ID if not found
        dbOrder ??= await _orderDatabase.getPlaceOrder(item.placeId);

        if (dbOrder != null) {
          final newProducts =
              state.where((e) => e.placeId == item.placeId).toList();
          final updatedOrder = dbOrder.copyWith(
            products: newProducts,
            updatedDate: DateTime.now().toIso8601String(),
          );
          await _orderDatabase.updatePlaceOrder(
              data: updatedOrder, placeId: item.placeId, message: null);
        }
      }
    }

    await _onDeleteCache(item.placeId, ref);
    return;
  }

  void updateItem(OrderItem item, BuildContext context, {Order? order}) {
    log("update item for: ${item.product.name}");

    final currentEmployee = ref.watch(currentEmployeeProvider);
    if (currentEmployee.roleName.toLowerCase() != 'admin') {
      final savedAmount = _getSavedAmount(item, order);
      if (item.amount < savedAmount) {
        ShowToast.error(
          context,
          "${AppLocales.doNotDecreaseText.tr()}: ${item.product.name}",
        );
        return;
      }
    }

    final index = state.indexWhere(
        (e) => e.product.id == item.product.id && e.placeId == item.placeId);
    if (index != -1) {
      state = [...state]..[index] = item;
    } else {
      state = [...state, item];
    }

    try {
      ref.invalidate(productsProvider);
      ref.refresh(productsProvider);
    } catch (_) {}
  }

  List<OrderItem> getItemsByPlace(String placeId) {
    return state.where((e) => e.placeId == placeId).toList();
  }

  String? getThisProduct(String? placeId, String productId) {
    if (placeId == null) return null;

    return state
        .where((e) => e.placeId == placeId && e.product.id == productId)
        .firstOrNull
        ?.amount
        .toMeasure;
  }

  bool haveProduct(String placeId, String productId) {
    return state
        .where((e) => e.placeId == placeId && e.product.id == productId)
        .isNotEmpty;
  }

  OrderItem? haveThisProduct(String placeId, String productId) {
    return state
        .where((e) => e.placeId == placeId && e.product.id == productId)
        .firstOrNull;
  }

  void clearPlaceItems(String placeId) {
    final current = ref.watch(currentEmployeeProvider);
    if (current.roleName.toLowerCase() != 'admin') return;
    state = state.where((e) => e.placeId != placeId).toList();
  }

  void clearPlaceItemsCloser(String placeId) {
    // if (current.roleName.toLowerCase() != 'admin') return;
    state = state.where((e) => e.placeId != placeId).toList();
  }

  void addMultiple(List<OrderItem> items, BuildContext? context,
      {Order? order}) {
    final current = state;

    final currentEmployee = ref.watch(currentEmployeeProvider);
    if (currentEmployee.roleName.toLowerCase() != 'admin' && context != null) {
      log("status: for save");
      bool status = false;
      for (final item in items) {
        // Here we are comparing item (new state?) vs... wait.
        // addMultiple is usually used to set state or add items.
        // If adding items, we should check if we are decreasing anything?
        // Usually addMultiple adds NEW items or resets state from DB.

        // If it is resetting from DB (loading order), we shouldn't block.
        // Logic in original code checked `_itemIsSaved`.
        // I will trust the original logic here unless I see a reason to change it,
        // as the request focuses on "amount, price input fields, buttons" which use updateItem/deleteItem.
        // But for consistency:

        final savedAmount = _getSavedAmount(item, order);
        if (item.amount < savedAmount) {
          status = true;
          ShowToast.error(
            context,
            "${AppLocales.doNotDecreaseText.tr()}: ${item.product.name}",
          );
        }
      }

      if (status) return;
    }

    final currentKeys =
        current.map((e) => '${e.product.id}-${e.placeId}').toSet();
    final unique = items
        .where((e) => !currentKeys.contains('${e.product.id}-${e.placeId}'))
        .toList();
    state = [...current, ...unique];

    try {
      ref.invalidate(productsProvider);
      ref.refresh(productsProvider);
    } catch (_) {}
  }

  void clear() {
    final current = ref.watch(currentEmployeeProvider);
    if (current.roleName.toLowerCase() != 'admin') return;
    state = [];
  }

  Future<void> _onDeleteCache(String placeId, ref) async {
    final list = state.where((e) => e.placeId == placeId).toList();
    if (list.isEmpty) {
      OrderDatabase orderDatabase = OrderDatabase();
      final notifier = ref.read(orderSetProvider.notifier);
      notifier.clearPlaceItems(placeId);
      ref.invalidate(ordersProvider(placeId));
      ref.invalidate(ordersProvider);
      ref.invalidate(employeeOrdersProvider);
      await orderDatabase.deletePlaceOrder(placeId);
      try {
        ref.invalidate(productsProvider);
      } catch (_) {}
    }
  }

  bool _itemIsSaved(OrderItem item, Order? order) {
    final currentAmount = item.amount;
    final savedAmount = _getSavedAmount(item, order);
    return currentAmount == savedAmount;
  }

  double _getSavedAmount(OrderItem item, Order? order) {
    return (order?.products ?? [])
        .firstWhere(
          (e) => e.product.id == item.product.id,
          orElse: () => item.copyWith(amount: 0),
        )
        .amount;
  }
}
