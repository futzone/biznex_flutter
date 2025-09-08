import 'package:biznex/src/core/database/place_database/place_database.dart';
import 'package:biznex/src/providers/products_provider.dart';
import 'package:biznex/src/server/app_response.dart';
import 'package:biznex/src/server/constants/api_endpoints.dart';
import 'package:biznex/src/server/constants/response_messages.dart';
import 'package:biznex/src/server/database_middleware.dart';
import 'package:biznex/src/server/docs.dart';
import 'package:shelf/src/request.dart';

class PlacesRouter {
  Request request;

  PlacesRouter(this.request);

  DatabaseMiddleware get databaseMiddleware => DatabaseMiddleware(
        pincode: request.headers['pin']!,
        boxName: PlaceDatabase().boxName,
      );

  Future<AppResponse> getPlaces() async {
    final employee = await databaseMiddleware.employeeState();
    if (employee == null) return AppResponse(statusCode: 403, error: ResponseMessages.unauthorized);
    final box = await databaseMiddleware.openBox();
    return AppResponse(statusCode: 200, data: box.values.toList());
  }

  Future<AppResponse> getAuthorizationResponse () {
    return jwtAuth(() async {

      return AppResponse(statusCode: 200);
    });
  }

  static ApiRequest docs() => ApiRequest(
        name: 'Get Places',
        path: ApiEndpoints.places,
        method: 'GET',
        headers: {'Content-Type': 'application/json', 'pin': 'XXXX'},
        body: '{}',
        contentType: 'application/json',
        errorResponse: {'error': ResponseMessages.unauthorized},
        response: [
          {
            "name": "Place Name",
            "id": "8b880130-19fa-11f0-80b6-5b844bb28dff",
            "image": null,
            "children": [
              {
                "name": "table 1",
                "id": "950708f0-19fa-11f0-80b6-5b844bb28dff",
                "image": null,
                "father": null,
              }
            ],
            "father": null
          }
        ],
      );

  Future<AppResponse> jwtAuth(Future<dynamic> Function() param0) async  {
    // if((await productsProvider.future).read(node))
    return AppResponse(statusCode: 200);
  }
}
