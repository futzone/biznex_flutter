
import '../../providers/employee_orders_provider.dart';
import '../model/order_models/order_filter_model.dart';
import '../model/order_models/order_model.dart';

List<Order> filterOrdersIsolate(Map<String, dynamic> args) {
  final List<Order> orders = args['orders'];
  final OrderFilterModel filter = args['filter'];

  final lowerQuery = filter.query?.toLowerCase();

  final filtered = orders.where((el) {
    if (filter.employee != null && el.employee.id != filter.employee) return false;
    if (filter.status != null && el.status != filter.status) return false;
    if (lowerQuery != null &&
        !el.orderNumber.toString().toLowerCase().contains(lowerQuery)) {
      return false;
    }
    if (filter.dateTime != null && !isTodayOrder(filter.dateTime!, el)) return false;
    if (filter.product != null && !haveInProducts(el, filter.product!)) return false;
    if (filter.place != null && !haveInPlaces(el, filter.place!)) return false;
    return true;
  }).toList();

  filtered.sort((a, b) =>
      DateTime.parse(b.updatedDate).compareTo(DateTime.parse(a.updatedDate)));

  return filtered;
}
