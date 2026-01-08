import 'package:biznex/src/core/database/category_database/category_database.dart';
import 'package:biznex/src/server/app_response.dart';
import 'package:biznex/src/server/constants/api_endpoints.dart';
import 'package:biznex/src/server/constants/response_messages.dart';
import 'package:biznex/src/server/database_middleware.dart';
import 'package:biznex/src/server/docs.dart';
import 'package:hive/hive.dart';
import 'package:shelf/src/request.dart';

class CategoriesRouter {
  Request request;

  CategoriesRouter(this.request);

  DatabaseMiddleware get databaseMiddleware => DatabaseMiddleware(
        pincode: request.headers['pin']!,
        boxName: CategoryDatabase().boxName,
      );

  Future<AppResponse> getCategories() async {
    final box = await Hive.openBox(CategoryDatabase().boxName);
    return AppResponse(statusCode: 200, data: box.values.toList());
  }

  Future<AppResponse> getCategoriesPaginated(
      {int page = 1, int limit = 20}) async {
    final box = await Hive.openBox(CategoryDatabase().boxName);
    return AppResponse(statusCode: 200, data: box.values.toList());
  }

  static ApiRequest docs() => ApiRequest(
        name: 'Get Categories',
        path: ApiEndpoints.categories,
        method: 'GET',
        headers: {'Content-Type': 'application/json', 'pin': 'XXXX'},
        body: '{}',
        contentType: 'application/json',
        errorResponse: {'error': ResponseMessages.unauthorized},
        response: [
          {
            "name": "d",
            "id": "ff93cc80-19fa-11f0-80b6-5b844bb28dff",
            "parentId": null,
            "printerParams": null,
          }
        ],
      );
}
