import '../../../biznex.dart';
import '../model/category_model/category_model.dart';
import '../model/employee_models/employee_model.dart';
import '../model/order_models/order_model.dart';

bool _checkOwner(Employee orderEmployee, Employee employee) {
  if (employee.roleName.toLowerCase() == 'admin') {
    if (orderEmployee.roleName.toLowerCase() == 'admin') return true;
  }

  return (employee.id == orderEmployee.id);
}

Map<String, dynamic> calculateProductOrderIsolate(Map<String, dynamic> data) {
  final DateTime day = DateTime.parse(data['day']);
  final List orders = data['orders'];
  final currentEmployee = Employee.fromJson(data['currentEmployee']);

  final Map<String, dynamic> categoryMap = {};

  for (final orderJson in orders) {
    final order = Order.fromJson(orderJson);
    final created = DateTime.parse(order.createdDate);

    if (created.day == day.day &&
        created.month == day.month &&
        created.year == day.year &&
        _checkOwner(order.employee, currentEmployee)) {
      for (final item in order.products) {
        final category = item.product.category;
        final categoryId = category?.id ?? 'others';

        if (!categoryMap.containsKey(categoryId)) {
          categoryMap[categoryId] = {
            'category': category ??
                Category(
                  name: AppLocales.others.tr(),
                  index: 999,
                ),
            'products': {},
          };
        }

        final productsMap = categoryMap[categoryId]['products'];

        if (productsMap.containsKey(item.product.id)) {
          productsMap[item.product.id]['amount'] =
              productsMap[item.product.id]['amount'] + item.amount;
        } else {
          productsMap[item.product.id] = {
            'product': item.product,
            'amount': item.amount,
          };
        }
      }
    }
  }

  return categoryMap;
}

Map<String, dynamic> calculateCategoryOrderIsolate(Map<String, dynamic> data) {
  final DateTime day = DateTime.parse(data['day']);
  final List orders = data['orders'];

  final Map<String, dynamic> categoryMap = {};

  for (final orderJson in orders) {
    final order = Order.fromJson(orderJson);
    final created = DateTime.parse(order.createdDate);

    if (created.day == day.day &&
        created.month == day.month &&
        created.year == day.year) {
      for (final item in order.products) {
        final category = item.product.category;
        final categoryId = category?.id ?? 'others';

        if (!categoryMap.containsKey(categoryId)) {
          categoryMap[categoryId] = {
            'category': category ??
                Category(
                  name: AppLocales.others.tr(),
                  index: 999,
                ),
            'products': {},
          };
        }

        final productsMap = categoryMap[categoryId]['products'];

        if (productsMap.containsKey(item.product.id)) {
          productsMap[item.product.id]['amount'] =
              productsMap[item.product.id]['amount'] + item.amount;
        } else {
          productsMap[item.product.id] = {
            'product': item.product,
            'amount': item.amount,
          };
        }
      }
    }
  }

  return categoryMap;
}
