// ignore_for_file: constant_identifier_names

enum Entity {
  ORDER,
  TRANSACTION,
  INGREDIENT_TRANSACTION,

  PRODUCT,
  CATEGORY,
  EMPLOYEE,
  ROLE,
  CUSTOMER,
  PLACE,
  INGREDIENT,
  RECIPE,
  SHOPPING,
  PERCENT,
  PAYMENT,
  SYSTEM
}

abstract class EntityEvent {
  String getName();

  static EntityEvent byName(String name) {
    final List<EntityEvent> allEvents = [
      ...OrderEvent.values,
      ...ProductEvent.values,
      ...CategoryEvent.values,
      ...EmployeeEvent.values,
      ...RoleEvent.values,
      ...CustomerEvent.values,
      ...PlaceEvent.values,
      ...IngredientEvent.values,
      ...RecipeEvent.values,
      ...ShoppingEvent.values,
      ...PercentEvent.values,
      ...TransactionEvent.values,
      ...IngredientTransactionEvent.values,
      ...PaymentEvent.values,
      ...SystemEvent.values,
    ];

    for (EntityEvent item in allEvents) {
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

enum OrderEvent implements EntityEvent {
  ORDER_CREATED,
  ORDER_UPDATED,
  ORDER_CLOSED;

  @override
  String getName() => name;
}

enum ProductEvent implements EntityEvent {
  PRODUCT_CREATED,
  PRODUCT_DELETED,
  PRODUCT_UPDATED;

  @override
  String getName() => name;
}

enum CategoryEvent implements EntityEvent {
  CATEGORY_CREATED,
  CATEGORY_DELETED,
  CATEGORY_UPDATED;

  @override
  String getName() => name;
}

enum EmployeeEvent implements EntityEvent {
  EMPLOYEE_CREATED,
  EMPLOYEE_DELETED,
  EMPLOYEE_UPDATED;

  @override
  String getName() => name;
}

enum RoleEvent implements EntityEvent {
  ROLE_CREATED,
  ROLE_UPDATED;

  @override
  String getName() => name;
}

enum CustomerEvent implements EntityEvent {
  CUSTOMER_CREATED,
  CUSTOMER_UPDATED;

  @override
  String getName() => name;
}

enum PlaceEvent implements EntityEvent {
  PLACE_CREATED,
  PLACE_UPDATED;

  @override
  String getName() => name;
}

enum IngredientEvent implements EntityEvent {
  INGREDIENT_CREATED,
  INGREDIENT_UPDATED;

  @override
  String getName() => name;
}

enum RecipeEvent implements EntityEvent {
  RECIPE_CREATED,
  RECIPE_UPDATED;

  @override
  String getName() => name;
}

enum ShoppingEvent implements EntityEvent {
  SHOPPING_CREATED,
  SHOPPING_UPDATED;

  @override
  String getName() => name;
}

enum PercentEvent implements EntityEvent {
  PERCENT_CREATED,
  PERCENT_UPDATED;

  @override
  String getName() => name;
}

enum TransactionEvent implements EntityEvent {
  TRANSACTION_CREATED,
  TRANSACTION_UPDATED,
  TRANSACTION_RECORDED;

  @override
  String getName() => name;
}

enum IngredientTransactionEvent implements EntityEvent {
  INGREDIENT_TRANSACTION_CREATED,
  INGREDIENT_TRANSACTION_UPDATED;

  @override
  String getName() => name;
}

enum PaymentEvent implements EntityEvent {
  PAYMENT_CREATED,
  PAYMENT_UPDATED,
  PAYMENT_CONFIRMED;

  @override
  String getName() => name;
}

enum SystemEvent implements EntityEvent {
  HEALTH_CHECK,
  TEST_EVENT;

  @override
  String getName() => name;
}
