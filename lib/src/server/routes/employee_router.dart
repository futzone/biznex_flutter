import 'package:biznex/src/core/database/employee_database/employee_database.dart';
import 'package:biznex/src/server/app_response.dart';
import 'package:biznex/src/server/constants/api_endpoints.dart';
import 'package:biznex/src/server/constants/response_messages.dart';
import 'package:biznex/src/server/database_middleware.dart';
import 'package:biznex/src/server/docs.dart';
import 'package:shelf/src/request.dart';

class EmployeeRouter {
  Request request;

  EmployeeRouter(this.request);

  DatabaseMiddleware get databaseMiddleware => DatabaseMiddleware(
        pincode: request.headers['pin']!,
        boxName: EmployeeDatabase().boxName,
      );

  Future<AppResponse> getCategories() async {
    final employee = await databaseMiddleware.employeeState();
    if (employee == null) return AppResponse(statusCode: 403, error: ResponseMessages.unauthorized);
    return AppResponse(statusCode: 200, data: employee.toJson());
  }

  static ApiRequest docs() => ApiRequest(
        name: 'Get Employee',
        path: ApiEndpoints.employee,
        method: 'GET',
        headers: {'Content-Type': 'application/json', 'pin': 'XXXX'},
        body: '{}',
        contentType: 'application/json',
        errorResponse: {'error': ResponseMessages.unauthorized},
        response: {},
      );
}
