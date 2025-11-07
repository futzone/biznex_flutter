import '../model/order_models/order_model.dart';

List<Order> filterAndSortOrders(Map<String, dynamic> data) {
  final List<Order> orders = List<Order>.from(data['orders']);
  final String employeeId = data['employeeId'];

  final list = orders.where((o) => o.employee.id == employeeId).toList();

  list.sort((a, b) {
    final dateA = DateTime.parse(a.updatedDate);
    final dateB = DateTime.parse(b.updatedDate);
    return dateB.compareTo(dateA);
  });

  return list;
}
