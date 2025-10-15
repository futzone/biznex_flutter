import 'package:biznex/biznex.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/providers/orders_provider.dart';
import 'package:biznex/src/providers/products_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import '../core/database/order_database/order_database.dart';
import 'employee_orders_provider.dart';

final orderSetProvider =
    StateNotifierProvider<OrderSetNotifier, List<OrderItem>>((ref) {
  return OrderSetNotifier(ref);
});

class OrderSetNotifier extends StateNotifier<List<OrderItem>> {
  final Ref ref;
  final OrderDatabase _orderDatabase = OrderDatabase();

  OrderSetNotifier(this.ref) : super([]);

  Future<void> loadOrderForPlace(String placeId) async {
    if (state.any((item) => item.placeId == placeId)) {
      return;
    }

    final order = await _orderDatabase.getPlaceOrder(placeId);

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

    ref.invalidate(productsProvider);
  }

  void removeItem(OrderItem item, AppModel model, context) {
    final current = ref.watch(currentEmployeeProvider);
    if (current.roleName.toLowerCase() != 'admin') return;

    final index = state.indexWhere(
        (e) => e.product.id == item.product.id && e.placeId == item.placeId);
    if (index != -1) {
      final current = state[index];
      if (current.amount > 1) {
        final updatedItem = current.copyWith(amount: current.amount - 1);
        state = [...state]..[index] = updatedItem;
      } else {
        deleteItem(item, context);
      }
    }
  }

  void deleteItem(OrderItem item, context) async {
    final current = ref.watch(currentEmployeeProvider);
    if (current.roleName.toLowerCase() != 'admin') return;

    final order = ref.watch(ordersProvider(item.placeId)).value;

    if (order != null &&
        order.products.isNotEmpty &&
        order.products
            .any((element) => element.product.id == item.product.id)) {
      final index = state.indexWhere(
          (e) => e.product.id == item.product.id && e.placeId == item.placeId);
      if (index != -1) {
        state = [
          ...state.where((e) =>
              !(e.product.id == item.product.id && e.placeId == item.placeId))
        ];
      }
      _onDeleteCache(item.placeId, ref);
      return;
    }

    final index = state.indexWhere(
        (e) => e.product.id == item.product.id && e.placeId == item.placeId);
    if (index != -1) {
      state = [
        ...state.where((e) =>
            !(e.product.id == item.product.id && e.placeId == item.placeId))
      ];
    }

    _onDeleteCache(item.placeId, ref);
    return;
  }

  void updateItem(OrderItem item, BuildContext context) {
    final currentEmployee = ref.watch(currentEmployeeProvider);
    if (currentEmployee.roleName.toLowerCase() != 'admin') {
      final have = haveThisProduct(item.placeId, item.product.id);
      if (have != null && have.amount > item.amount) {
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

  void addMultiple(List<OrderItem> items, BuildContext? context) {
    final current = state;

    final currentEmployee = ref.watch(currentEmployeeProvider);
    if (currentEmployee.roleName.toLowerCase() != 'admin' && context != null) {
      bool status = false;
      for (final item in items) {
        final have = haveThisProduct(item.placeId, item.product.id);
        if (have == null) continue;
        if (have.amount <= item.amount) continue;

        status = true;
        ShowToast.error(
          context,
          "${AppLocales.doNotDecreaseText.tr()}: ${item.product.name}",
        );

        return;
      }

      if (status) return;
    }

    final currentKeys =
        current.map((e) => '${e.product.id}-${e.placeId}').toSet();
    final unique = items
        .where((e) => !currentKeys.contains('${e.product.id}-${e.placeId}'))
        .toList();
    state = [...current, ...unique];
  }

  void clear() {
    final current = ref.watch(currentEmployeeProvider);
    if (current.roleName.toLowerCase() != 'admin') return;
    state = [];
  }

  void _onDeleteCache(String placeId, ref) {
    final list = state.where((e) => e.placeId == placeId).toList();
    if (list.isEmpty) {
      OrderDatabase orderDatabase = OrderDatabase();
      final notifier = ref.read(orderSetProvider.notifier);
      notifier.clearPlaceItems(placeId);
      ref.invalidate(ordersProvider(placeId));
      ref.invalidate(ordersProvider);
      ref.invalidate(employeeOrdersProvider);
      orderDatabase.deletePlaceOrder(placeId);
    }
  }
}
