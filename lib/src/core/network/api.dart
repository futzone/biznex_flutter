import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';

class ApiBase {
  Future<Response?> post({
    required String path,
    required String baseUrl,
    dynamic params,
    dynamic data,
    bool useFile = false,
    bool useHeaders = true,
  }) async {
    try {
      Dio dio = Dio(
        BaseOptions(baseUrl: baseUrl),
      );

      final response = await dio.post(path, queryParameters: params, data: jsonEncode(data));
      return response;
    } on DioException catch (error, stackTrace) {
      // log("Error on $path:\n${error.response?.data}", error: error, stackTrace: stackTrace);
      return error.response;
    }
  }

  Future<Response?> put({
    required String path,
    dynamic params,
    dynamic data,
    required String baseUrl,
  }) async {
    try {
      Dio dio = Dio(BaseOptions(baseUrl: baseUrl));

      final response = await dio.put(path, queryParameters: params, data: data);
      return response;
    } on DioException catch (error, stackTrace) {
      // log("Error on $path:\n${error.response?.data}", error: error, stackTrace: stackTrace);
      return error.response;
    }
  }

  Future<Response?> delete({required String path, required String baseUrl, dynamic params, dynamic data}) async {
    try {
      Dio dio = Dio(BaseOptions(baseUrl: baseUrl));

      final response = await dio.delete(path, queryParameters: params, data: data);
      return response;
    } on DioException catch (error, stackTrace) {
      // log("Error on $path:\n${error.response?.data}", error: error, stackTrace: stackTrace);
      return error.response;
    }
  }

  Future<Response?> get({required String baseUrl, required String path, dynamic params, dynamic data}) async {
    try {
      Dio dio = Dio(BaseOptions(baseUrl: baseUrl));
      final response = await dio.get(path, queryParameters: params, data: data);
      return response;
    } on DioException catch (error, stackTrace) {
      // log("Error on $path:\n${error.response?.data}", error: error, stackTrace: stackTrace);
      return error.response;
    }
  }

  Future<Response?> patch({required String path, required String baseUrl, dynamic params, dynamic data}) async {
    try {
      Dio dio = Dio(BaseOptions(baseUrl: baseUrl));
      final response = await dio.patch(path, queryParameters: params, data: data);
      return response;
    } on DioException catch (error, stackTrace) {
      // log("Error on $path:", error: error, stackTrace: stackTrace);
      return error.response;
    }
  }
}
