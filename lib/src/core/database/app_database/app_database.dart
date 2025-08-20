import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/database/changes_database/changes_database.dart';
import 'package:biznex/src/core/network/api.dart';
import 'package:biznex/src/core/network/response.dart';
import 'package:biznex/src/helper/services/api_services.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

export 'package:hive_flutter/hive_flutter.dart';

export 'package:hive/hive.dart';

abstract class AppDatabase {
  bool isClientApp = false;
  String? baseUrl;

  Future<void> set({required dynamic data});

  Future<void> update({required String key, required dynamic data});

  Future<dynamic> get();

  Future<dynamic> delete({required String key});

  Future<Box> openBox(String boxName) async {
    final box = await Hive.openBox(boxName);
    return box;
  }

  String get generateID {
    var uuid = Uuid();
    return uuid.v1();
  }

  ChangesDatabase get changesDatabase => ChangesDatabase();

  Future<String?> connectionStatus() async {
    final url = await AppStateDatabase().getApp();
    if (url.apiUrl == null || (url.apiUrl ?? '').isEmpty) return null;

    final response = await ApiBase().get(baseUrl: "http://${url.apiUrl}:8080", path: "/api/v1/docs");
    if (response.success) {
      isClientApp = true;
      baseUrl = url.apiUrl;
      return url.apiUrl;
    }
    return null;
  }

  ApiBase apiBase = ApiBase();

  Future<dynamic> getRemote({required String boxName}) async {
    if (baseUrl == null) return null;
    final response = await apiBase.get(baseUrl: "http://$baseUrl:8080", path: '/api/v2/$boxName');
    if (response.success) return response?.data;
    return null;
  }

  Future<dynamic> postRemote({required String boxName, dynamic data}) async {
    if (baseUrl == null) return null;
    final response = await apiBase.post(baseUrl: baseUrl!, path: '/api/v2/$boxName', data: data);
    if (response.success) return response?.data;
    return null;
  }

  Future<dynamic> putRemote({required String boxName, dynamic data}) async {
    if (baseUrl == null) return null;
    final response = await apiBase.put(baseUrl: baseUrl!, path: '/api/v2/$boxName', data: data);
    if (response.success) return response?.data;
    return null;
  }

  Future<dynamic> patchRemote({required String boxName, dynamic data}) async {
    if (baseUrl == null) return null;
    final response = await apiBase.patch(baseUrl: baseUrl!, path: '/api/v2/$boxName', data: data);
    if (response.success) return response?.data;
    return null;
  }

  Future<dynamic> deleteRemote({required String boxName, dynamic data}) async {
    if (baseUrl == null) return null;
    final response = await apiBase.delete(baseUrl: baseUrl!, path: '/api/v2/$boxName', data: data);
    if (response.success) return response?.data;
    return null;
  }
}
