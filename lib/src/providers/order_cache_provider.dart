import 'package:biznex/src/core/model/order_models/order_model.dart';

import '../../biznex.dart';
import '../core/database/order_database/order_database.dart';

final orderCacheProvider =
    StateNotifierProvider<OrderCacheNotifier, List<Order>>((ref) {
  return OrderCacheNotifier(ref);
});

class OrderCacheNotifier extends StateNotifier<List<Order>> {
  final Ref ref;
  final OrderDatabase _orderDatabase = OrderDatabase();

  Future<void> init() async {
    if (state.isNotEmpty) return;
    final orders = await _orderDatabase.getOrders();
    state = [for (int i = 0; i < 100; i++) ...orders];
  }

  Future<void> invalidate() async {
    final orders = await _orderDatabase.getOrders();
    state = orders;
  }

  OrderCacheNotifier(this.ref) : super([]);
}
