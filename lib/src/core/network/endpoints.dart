class ApiEndpoints {
  static const String baseUrl = "https://owner.biznex.uz";
  // static const String baseUrl = "http://127.0.0.1:8000";
  static const String client = "/clients/client";

  static String clientOne(id) => "/clients/$id";

  static String clientsAll(page, pageSize) => "/clients/list/$page/$pageSize";

  static String productOne(id) => "/products/clients/$id";
  static String product = "/products/product";
  static String action = "/actions/action";
  static const String employee = "/employees/employee";

  static String employeeOne(id) => "/employees/clients/$id";
  static String transaction = "/transactions/transaction";
  static String percent = "/percents/percent";
  static String order = "/orders/order";
  static String report = "/report/report";
  static String monitoring = "/monitoring/monitoring";

  static String transactionOne(id) => "/transactions/clients/$id";

  static String percentOne(id) => "/percents/clients/$id";

  static String reportOne(String s) => "/report/clients/$s";

  static String reportOneGet(String s) => "/report/report/$s";

  static String monitoringOne(String clientId) =>
      "/monitoring/clients/$clientId";

  static String monitoringOneGet(
          {required String clientId, required String id}) =>
      "/monitoring/monitoring/$clientId/$id";

  static String ingredients = "/ingredients/ingredient";

  static String ingredientsList(id, int page, int pageSize) =>
      "/ingredients/list/$id/$page/$pageSize";

  static String updatedIngredientsList(id, int page, int pageSize) =>
      "/ingredients/list-updated/$id/$page/$pageSize";

  static String ingredientsOne(id) => "/ingredients/ingredient/$id";
  static String ingredientsClear(id) => "/ingredients/ingredient/clear/$id";
}
