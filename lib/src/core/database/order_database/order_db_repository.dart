import 'dart:developer';

import 'package:biznex/src/core/network/api.dart';
import 'package:biznex/src/core/network/response.dart';
import '../app_database/app_state_database.dart';

abstract class OrderDatabaseRepository {
  bool isClientApp = false;
  String? baseUrl;

  Future<String?> connectionStatus() async {
    final url = await AppStateDatabase().getApp();
    if (url.apiUrl == null || (url.apiUrl ?? '').isEmpty) return null;

    return url.apiUrl;
    //
    // final response = await ApiBase().get(baseUrl: "http://${url.apiUrl}:8080", path: "/api/v1/docs");
    // if (response.success) {
    //   isClientApp = true;
    //   baseUrl = url.apiUrl;
    //
    // }
    // return null;
  }

  ApiBase apiBase = ApiBase();

  Future<dynamic> getRemote({required String path}) async {
    if (path == 'percents') log("base url: $baseUrl");
    if (baseUrl == null) return null;
    final response = await apiBase.get(baseUrl: "http://$baseUrl:8080", path: '/api/v2/$path');
    if (path == 'percents') log("percents: ${response?.statusCode} | ${response?.data}");
    if (response.success) return response?.data;
    // log("${response?.data}\n${response?.statusCode}");
    return null;
  }

  Future<dynamic> postRemote({required String path, dynamic data}) async {
    if (baseUrl == null) return null;
    final response = await apiBase.post(baseUrl: "http://$baseUrl:8080", path: '/api/v2/$path', data: data);
    if (response.success) return response?.data;
    return response?.data.toString();
  }

  Future<dynamic> putRemote({required String path, dynamic data}) async {
    if (baseUrl == null) return null;
    final response = await apiBase.put(baseUrl: "http://$baseUrl:8080", path: '/api/v2/$path', data: data);
    if (response.success) return response?.data;
    return null;
  }

  Future<dynamic> patchRemote({required String path, dynamic data}) async {
    if (baseUrl == null) return null;
    final response = await apiBase.patch(baseUrl: "http://$baseUrl:8080", path: '/api/v2/$path', data: data);
    if (response.success) return response?.data;
    return null;
  }

  Future<dynamic> deleteRemote({required String path, dynamic data}) async {
    if (baseUrl == null) return null;
    final response = await apiBase.delete(baseUrl: "http://$baseUrl:8080", path: '/api/v2/$path', data: data);
    if (response.success) return response?.data;
    return null;
  }
}
