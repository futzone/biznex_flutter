import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/server/app_response.dart';
import 'package:biznex/src/server/constants/api_endpoints.dart';
import 'package:biznex/src/server/constants/response_messages.dart';
import 'package:biznex/src/server/database_middleware.dart';
import 'package:biznex/src/server/docs.dart';
import 'package:shelf/src/request.dart';

class ProductsRouter {
  Request request;

  ProductsRouter(this.request);

  DatabaseMiddleware get databaseMiddleware => DatabaseMiddleware(
        pincode: request.headers['pin']!,
        boxName: ProductDatabase().boxName,
      );

  Future<AppResponse> getProducts() async {
    final employee = await databaseMiddleware.employeeState();
    if (employee == null) return AppResponse(statusCode: 403, error: ResponseMessages.unauthorized);
    final box = await databaseMiddleware.openBox();
    return AppResponse(statusCode: 200, data: box.values.toList());
  }

  static ApiRequest docs() => ApiRequest(
        name: 'Get Products',
        path: ApiEndpoints.products,
        method: 'GET',
        headers: {'Content-Type': 'application/json', 'pin': 'XXXX'},
        body: '{}',
        contentType: 'application/json',
        errorResponse: {'error': ResponseMessages.unauthorized},
        response: [
          {
            "name": "d",
            "barcode": "3",
            "tagnumber": "3",
            "cratedDate": "2025-04-15T18:10:42.042649",
            "updatedDate": "2025-04-15T18:10:42.039652",
            "informations": [],
            "description": "32",
            "images": [],
            "measure": null,
            "color": null,
            "colorCode": null,
            "size": null,
            "price": 2.2,
            "amount": 0.0,
            "percent": 10.0,
            "id": "089bf690-19fb-11f0-80b6-5b844bb28dff",
            "productId": null,
            "variants": null,
            "category": {
              "name": "d",
              "id": "ff93cc80-19fa-11f0-80b6-5b844bb28dff",
              "parentId": null,
              "printerParams": {},
            }
          }
        ],
      );
}
