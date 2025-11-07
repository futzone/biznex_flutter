import '../../providers/employee_orders_provider.dart';
import '../model/order_models/order_filter_model.dart';
import '../model/order_models/order_model.dart';

List<Order> filterAndSortAllOrders(Map<String, dynamic> data) {
  final List<Order> orders = List<Order>.from(data['orders']);
  final OrderFilterModel filter = data['filter'];

  final list = orders.where((el) {
    if (filter.employee != null && el.employee.id != filter.employee) {
      return false;
    }
    if (filter.status != null && el.status != filter.status) {
      return false;
    }
    if (filter.dateTime != null && !isTodayOrder(filter.dateTime!, el)) {
      return false;
    }
    if (filter.product != null && !haveInProducts(el, filter.product!)) {
      return false;
    }
    if (filter.place != null && !haveInPlaces(el, filter.place!)) {
      return false;
    }
    if (filter.query != null &&
        !el.orderNumber
            .toString()
            .toLowerCase()
            .contains(filter.query!.toLowerCase())) {
      return false;
    }
    return true;
  }).toList();

  list.sort((a, b) {
    final dateA = DateTime.parse(a.updatedDate);
    final dateB = DateTime.parse(b.updatedDate);
    return dateB.compareTo(dateA);
  });

  return list;
}