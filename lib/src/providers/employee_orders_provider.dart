import 'dart:developer';
  import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/model/order_models/order_filter_model.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/providers/order_cache_provider.dart';


bool isTodayOrder(DateTime dateFilter, Order order) {
  final orderDate = DateTime.parse(order.createdDate);
  return (orderDate.year == dateFilter.year) &&
      (orderDate.month == dateFilter.month) &&
      (orderDate.day == dateFilter.day);
}

bool haveInProducts(Order order, String productId) {
  return order.products.any((element) => element.product.id == productId);
}

bool haveInPlaces(Order order, String placeId) {
  return order.products.any((element) => element.placeId == placeId);
}

final FutureProvider<List<Order>> employeeOrdersProvider =
    FutureProvider((ref) async {
  final employee = ref.watch(currentEmployeeProvider);
  await ref.read(orderCacheProvider.notifier).init();

  final allOrders = ref.watch(orderCacheProvider);

  List<Order> list = [
    ...allOrders.where((el) => el.employee.id == employee.id)
  ];

  // list.sort((a, b) {
  //   final dateA = DateTime.parse(a.updatedDate);
  //   final dateB = DateTime.parse(b.updatedDate);
  //   return dateB.compareTo(dateA);
  // });

  return list;
});

final ordersFilterProvider =
    FutureProvider.family<List<Order>, OrderFilterModel>((ref, filter) async {
      log("${filter.page} ${filter.limit}");
  OrderDatabase orderDatabase = OrderDatabase();
  final list = await orderDatabase.getOrders(filter: filter);

  return list;
});
