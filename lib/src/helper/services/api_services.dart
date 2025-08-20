import 'dart:convert';
import 'dart:developer';

import 'package:biznex/src/core/database/url_database/url_database.dart';
import 'package:biznex/src/server/app_response.dart';
import 'package:biznex/src/server/constants/api_endpoints.dart';
import 'package:biznex/src/server/services/authorization_services.dart';
import 'package:dio/dio.dart';

class HelperApiServices {
  Future<String?> getBaseUrl() async {
    final UrlDatabase urlDatabase = UrlDatabase();
    final url = await urlDatabase.get();
    if (url == null || url is! String) return null;
    return url;
  }

  String _token() {
    AuthorizationServices authorizationServices = AuthorizationServices();
    return authorizationServices.generateToken();
  }

  Future<Dio> _dio(String pin) async {
    final baseUrl = await getBaseUrl();
    log(baseUrl.toString());
    if (baseUrl == null) return Dio();
    return Dio(BaseOptions(
      baseUrl: "http://$baseUrl:8080",
      headers: {"pin": pin, "token": _token(), "Content-Type": "application/json"},
    ));
  }

  Future<AppResponse> getPlaces(String pin) async {
    try {
      final dio = await _dio(pin);
      final response = await dio.get(ApiEndpoints.places);
      if (response.statusCode != null && response.statusCode! > 199 && response.statusCode! < 300) {
        return AppResponse(statusCode: 200, data: jsonDecode(response.data));
      }

      return AppResponse(statusCode: response.statusCode ?? 400);
    } on DioException catch (error) {
      log(error.message.toString());
      log(error.error.toString());
      return AppResponse(
        statusCode: error.response?.statusCode ?? 400,
        error: error.response?.data == null ? 'error' : error.response?.data['error'],
      );
    }
  }

  Future<AppResponse> getMe(String pin) async {
    try {
      final dio = await _dio(pin);
      final response = await dio.get(ApiEndpoints.employee);
      if (response.statusCode != null && response.statusCode! > 199 && response.statusCode! < 300) {
        return AppResponse(statusCode: 200, data: response.data);
      }

      return AppResponse(statusCode: response.statusCode ?? 400);
    } on DioException catch (error) {
      log(error.message.toString());
      log(error.error.toString());
      return AppResponse(
        statusCode: error.response?.statusCode ?? 400,
        error: error.response?.data == null ? 'error' : error.response?.data.toString(),
      );
    }
  }


  Future<AppResponse> getProducts(String pin) async {
    try {
      final dio = await _dio(pin);
      final response = await dio.get(ApiEndpoints.products);
      if (response.statusCode != null && response.statusCode! > 199 && response.statusCode! < 300) {
        return AppResponse(statusCode: 200, data: jsonDecode(response.data));
      }

      return AppResponse(statusCode: response.statusCode ?? 400);
    } on DioException catch (error) {
      log(error.message.toString());
      log(error.error.toString());
      return AppResponse(
        statusCode: error.response?.statusCode ?? 400,
        error: error.response?.data == null ? 'error' : error.response?.data['error'],
      );
    }
  }

}
