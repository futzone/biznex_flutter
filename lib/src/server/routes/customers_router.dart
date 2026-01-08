import 'package:biznex/src/core/database/customer_database/customer_database.dart';
import 'package:biznex/src/core/model/other_models/customer_model.dart';
import 'package:biznex/src/server/app_response.dart';
import 'package:biznex/src/server/constants/api_endpoints.dart';
import 'package:biznex/src/server/constants/response_messages.dart';
import 'package:biznex/src/server/database_middleware.dart';
import 'package:biznex/src/server/docs.dart';
import 'package:hive/hive.dart';
import 'package:shelf/src/request.dart';

class CustomersRouter {
  Request request;

  CustomersRouter(this.request);

  DatabaseMiddleware get databaseMiddleware => DatabaseMiddleware(
        pincode: request.headers['pin']!,
        boxName: CustomerDatabase().boxName,
      );

  Future<AppResponse> getCustomersPaginated(
      {int page = 1, int limit = 20}) async {
    final CustomerDatabase customerDatabase = CustomerDatabase();

    final allCustomers =
        (await Hive.openBox(customerDatabase.boxName)).values.toList();
    final total = allCustomers.length;

    final startIndex = (page - 1) * limit;
    if (startIndex >= total) {
      return AppResponse(statusCode: 200, data: []);
    }

    final endIndex =
        (startIndex + limit) > total ? total : (startIndex + limit);
    final paginatedValues = allCustomers.sublist(startIndex, endIndex);

    final responseList = [];
    for (final item in paginatedValues) {
      final customer = Customer.fromJson(item);
      responseList.add(customer.toJson());
    }

    return AppResponse(statusCode: 200, data: responseList);
  }

  static ApiRequest docs() => ApiRequest(
        name: 'Get Customers Paginated',
        path: '${ApiEndpoints.customers}?page=1&limit=20',
        method: 'GET',
        headers: {'Content-Type': 'application/json', 'pin': 'XXXX'},
        body: '{}',
        contentType: 'application/json',
        errorResponse: {'error': ResponseMessages.unauthorized},
        response: [
          {
            "id": "customer_id",
            "name": "Customer Name",
            "phone": "998901234567"
          }
        ],
      );
}
