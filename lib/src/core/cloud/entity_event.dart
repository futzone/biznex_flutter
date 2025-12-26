// ignore_for_file: constant_identifier_names

enum Entity {
  ORDER,
  PRODUCT,
  CATEGORY,
  EMPLOYEE,
  TRANSACTION,
  PAYMENT,
}

abstract class EntityEvent {
  String getName();

  static EntityEvent byName(String name) {
    for (EntityEvent item in [
      ...EmployeeEvent.values,
      ...CategoryEvent.values,
      ...ProductEvent.values,
      ...OrderEvent.values,
      ...PaymentEvent.values,
      ...TransactionEvent.values,
    ]) {
      if (item.getName() == name) return item;
    }

    return Unknown.UNKNOWN;
  }
}

enum Unknown implements EntityEvent {
  UNKNOWN;

  @override
  String getName() => name;
}

enum EmployeeEvent implements EntityEvent {
  EMPLOYEE_CREATED,
  EMPLOYEE_UPDATED,
  EMPLOYEE_DELETED;

  @override
  String getName() => name;
}

enum CategoryEvent implements EntityEvent {
  CATEGORY_CREATED,
  CATEGORY_UPDATED,
  CATEGORY_DELETED;

  @override
  String getName() => name;
}

enum ProductEvent implements EntityEvent {
  PRODUCT_CREATED,
  PRODUCT_UPDATED,
  PRODUCT_DELETED;

  @override
  String getName() => name;
}

enum OrderEvent implements EntityEvent {
  ORDER_CREATED,
  ORDER_UPDATED,
  ORDER_CANCELLED;

  @override
  String getName() => name;
}

enum PaymentEvent implements EntityEvent {
  PAYMENT_CREATED,
  PAYMENT_VOIDED;

  @override
  String getName() => name;
}

enum TransactionEvent implements EntityEvent {
  TRANSACTION_CREATED;

  @override
  String getName() => name;
}
