import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/server/app_response.dart';
import 'package:biznex/src/server/constants/api_endpoints.dart';
import 'package:biznex/src/server/constants/response_messages.dart';
import 'package:biznex/src/server/docs.dart';
import 'package:shelf/src/request.dart';

class StatsRouter {
  Request request;

  StatsRouter(this.request);

  // Future<AppResponse> getStats() async {
  //   final authState = await _authState(request);
  //   if (!authState) return AppResponse(statusCode: 403, error: ResponseMessages.unauthorized);
  //
  //
  // }

  Future<AppResponse> getState() async {
    final authState = await _authState(request);
    if (!authState) return AppResponse(statusCode: 403, error: ResponseMessages.unauthorized);
    final appDb = AppStateDatabase();
    final appState = await appDb.getApp();

    final responseMap = {
      "title": appState.shopName,
      "address": appState.shopAddress,
    };

    return AppResponse(statusCode: 200, data: responseMap);
  }

  Future<bool> _authState(Request request) async {
    final password = request.headers['pin'];
    if (password == null || password.length <= 3) {
      return false;
    }

    final appDb = AppStateDatabase();
    final appState = await appDb.getApp();

    return appState.pincode == password;
  }

  static ApiRequest docs() => ApiRequest(
        name: 'Get Organization State',
        path: ApiEndpoints.state,
        method: 'GET',
        headers: {'Content-Type': 'application/json', 'pin': 'XXXX', 'token': 'auth_token_here'},
        body: '{}',
        contentType: 'application/json',
        errorResponse: {'error': ResponseMessages.unauthorized},
        response: {},
      );
}
