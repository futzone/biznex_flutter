import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/model/order_models/order_filter_model.dart';
import 'package:biznex/src/core/model/order_models/order_model.dart';
import 'package:biznex/src/providers/employee_provider.dart';

bool isTodayOrder(DateTime dateFilter, Order order) {
  final orderDate = DateTime.parse(order.createdDate);
  return (orderDate.year == dateFilter.year) && (orderDate.month == dateFilter.month) && (orderDate.day == dateFilter.day);
}

bool haveInProducts(Order order, String productId) {
  return order.products.any((element) => element.product.id == productId);
}

bool haveInPlaces(Order order, String placeId) {
  return order.products.any((element) => element.placeId == placeId);
}

final FutureProvider<List<Order>> employeeOrdersProvider = FutureProvider((ref) async {
  final employee = ref.watch(currentEmployeeProvider);
  final OrderDatabase orderDatabase = OrderDatabase();
  final allOrders = await orderDatabase.getOrders();

  List<Order> list = [...allOrders.where((el) => el.employee.id == employee.id)];

  list.sort((a, b) {
    final dateA = DateTime.parse(a.updatedDate);
    final dateB = DateTime.parse(b.updatedDate);
    return dateB.compareTo(dateA);
  });

  return list;
});

final ordersFilterProvider = FutureProvider.family((ref, OrderFilterModel filter) async {
  final OrderDatabase orderDatabase = OrderDatabase();
  final allOrders = await orderDatabase.getOrders();

  List<Order> list = [
    ...allOrders.where((el) {
      if (filter.employee != null && el.employee.id != filter.employee) return false;
      if (filter.status != null && el.status != filter.status) return false;
      if (filter.dateTime != null && !isTodayOrder(filter.dateTime!, el)) return false;
      if (filter.product != null && !haveInProducts(el, filter.product!)) return false;
      if (filter.place != null && !haveInPlaces(el, filter.place!)) return false;
      if (filter.query != null && !el.orderNumber.toString().toLowerCase().contains(filter.query!.toLowerCase())) return false;
      return true;
    })
  ];

  list.sort((a, b) {
    final dateA = DateTime.parse(a.updatedDate);
    final dateB = DateTime.parse(b.updatedDate);
    return dateB.compareTo(dateA);
  });

  return list;
});
