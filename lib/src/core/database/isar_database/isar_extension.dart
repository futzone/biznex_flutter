import 'dart:convert';
import '../../../../biznex.dart';
import '../../model/category_model/category_model.dart';
import '../../model/employee_models/employee_model.dart';
import '../../model/order_models/order.dart';
import '../../model/order_models/order_model.dart';
import '../../model/other_models/customer_model.dart';
import '../../model/place_models/place_model.dart';
import '../../model/product_models/product_model.dart';
import '../../model/product_params_models/product_info.dart';

extension CustomerToIsar on Customer {
  CustomerIsar toIsar() => CustomerIsar()
    ..id = id
    ..name = name
    ..updated = updated
    ..created = created
    ..address = address
    ..note = note
    ..phone = phone;
}

extension EmployeeToIsar on Employee {
  EmployeeIsar toIsar() => EmployeeIsar()
    ..id = id
    ..fullname = fullname
    ..createdDate = createdDate
    ..phone = phone
    ..description = description
    ..roleId = roleId
    ..roleName = roleName
    ..pincode = pincode;
}

extension ProductInfoToIsar on ProductInfo {
  ProductInfoIsar toIsar() => ProductInfoIsar()
    ..id = id
    ..name = name
    ..data = data;
}

extension CategoryToIsar on Category {
  CategoryIsar toIsar() {
    final c = CategoryIsar()
      ..id = id
      ..name = name
      ..index = index
      ..parentId = parentId
      ..printerParams = jsonEncode(printerParams ?? {})
      ..icon = icon;
    c.subcategories = subcategories?.map((s) => s.toIsar()).toList();
    return c;
  }
}

extension ProductToIsar on Product {
  ProductIsar toIsar() {
    final p = ProductIsar()
      ..id = id
      ..unlimited = unlimited
      ..name = name
      ..cratedDate = cratedDate
      ..updatedDate = updatedDate
      ..description = description
      ..images = images?.toList()
      ..measure = measure
      ..color = color
      ..size = size
      ..price = price
      ..amount = amount
      ..percent = percent
      ..productId = productId
      ..category = category?.toIsar();

    return p;
  }
}

extension OrderItemToIsar on OrderItem {
  OrderItemIsar toIsar() => OrderItemIsar()
    ..product = product.toIsar()
    ..amount = amount
    ..placeId = placeId;
}

extension PlaceToIsarSafe on Place {
  PlaceIsar toIsar({Set<String>? visited}) {
    visited ??= {};

    if (visited.contains(id)) {
      return PlaceIsar()
        ..id = id
        ..percent = percent
        ..name = name
        ..price = price
        ..percentNull = percentNull;
    }

    visited.add(id);

    final p = PlaceIsar()
      ..id = id
      ..name = name
      ..image = image
      ..price = price
      ..percent = percent
      ..percentNull = percentNull;

    p.children = children?.map((c) => c.toIsar(visited: visited)).toList();
    p.father = father?.toIsar(visited: visited);

    return p;
  }
}

extension OrderToIsar on Order {
  OrderIsar toIsar() {
    final o = OrderIsar()
      ..id = id
      ..createdDate = createdDate
      ..updatedDate = updatedDate
      ..scheduledDate = scheduledDate
      ..customer = customer?.toIsar()
      ..employee = employee.toIsar()
      ..status = status
      ..realPrice = realPrice
      ..price = price
      ..note = note
      ..place = place.toIsar()
      ..orderNumber = orderNumber;
    o.products = products.map((p) => p.toIsar()).toList();
    o.paymentTypes = paymentTypes.map((pt) {
      PercentIsar percentIsar = PercentIsar()
        ..name = pt.name
        ..amount = pt.percent;
      return percentIsar;
    }).toList();
    return o;
  }
}
