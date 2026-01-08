import 'dart:convert';
import 'dart:developer';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:dio/dio.dart';
import 'package:biznex/src/core/model/app_model.dart';

class RemoteDataService {
  final Dio _dio = Dio();
  final AppStateDatabase stateDatabase = AppStateDatabase();
  AppModel? appModel;

  Future<List<dynamic>> fetchData({
    required String endpoint,
    int page = 1,
    int limit = 20,
  }) async {
    appModel ??= await stateDatabase.getApp();
    String apiIp = appModel?.apiUrl ?? '';
    if (apiIp.isEmpty) {
      log('RemoteDataService: baseUrl is empty');
      return [];
    }
    if (!apiIp.startsWith('http')) {
      apiIp = 'http://$apiIp';
    }
    final String baseUrl = "$apiIp:8080";

    final String url =
        '$baseUrl$endpoint'; // Ensure endpoint starts with / or baseUrl ends with it.
    // Usually apiUrl might not have trailing slash. Endpoint starts with /api/...

    // Check if url needs correction
    String fullUrl = url;
    if (!baseUrl.endsWith('/') && !endpoint.startsWith('/')) {
      fullUrl = '$baseUrl/$endpoint';
    } else if (baseUrl.endsWith('/') && endpoint.startsWith('/')) {
      fullUrl = '$baseUrl${endpoint.substring(1)}';
    }

    try {
      final response = await _dio.get(
        fullUrl,
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {
            // 'Content-Type': 'application/json',
            // 'Accept': 'application/json',
          },
          sendTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 5),
        ),
      );

      log("Response Status: ${response.statusCode}");
      if (response.statusCode == 200) {
        final data = response.data;
        log("Response Data Type: ${data.runtimeType}");

        if (data is String) {
          try {
            return jsonDecode(data);
          } catch (_) {}
        }

        if (data is List) {
          log("Data is List. Length: ${data.length}");
          if (data.isNotEmpty) log("First item: ${data.first}");
          return data;
        } else if (data is Map && data.containsKey('data')) {
          final innerData = data['data'];
          log("Data is Map with 'data' key. Inner Type: ${innerData.runtimeType}");
          if (innerData is List) {
            log("Inner List Length: ${innerData.length}");
            if (innerData.isNotEmpty)
              log("First inner item: ${innerData.first}");
            return innerData;
          }
          return [];
        }
        return [];
      } else {
        log('RemoteDataService: Error ${response.statusCode} - ${response.statusMessage}');
        return [];
      }
    } catch (e, st) {
      log('RemoteDataService: Exception fetching $fullUrl',
          error: e, stackTrace: st);
      return [];
    }
  }
}
