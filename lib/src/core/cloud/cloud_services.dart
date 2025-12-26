import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/cloud/cloud_response.dart';
import 'package:biznex/src/core/cloud/cloud_token_db.dart';
import 'package:biznex/src/core/cloud/device_info.dart';
import 'package:biznex/src/core/network/response.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:dio/dio.dart';
import 'cloud_event.dart';
import 'dart:developer';
import 'dart:convert';

class BiznexCloudServices {
  final AppStateDatabase _stateDatabase = AppStateDatabase();
  final CloudTokenDB _tokenDB = CloudTokenDB();
  final DeviceCloudService _deviceCloudService = DeviceCloudService();

  Future<bool> hasConnection() async {
    final bool isConnected = await InternetConnection().hasInternetAccess;
    final state = await _stateDatabase.getApp();
    return isConnected && !state.offline;
  }

  static final String baseUrl = "https://dev.api.biznex.uz";
  static final String login = "/api/v1/pos/auth/login";
  static final String refresh = "/api/v1/pos/auth/refresh";
  static final String logout = "/api/v1/pos/auth/logout";
  static final String batchIngest = "/api/v1/pos/events/ingest";
  static final String recoveryData = "/api/v1/pos/sync/bootstrap";
  static final String checkWatermark = "/api/v1/pos/sync/watermark";

  static String deltaSync(int limit, dynamic watermark) =>
      "/api/v1/pos/sync/delta?since=$watermark&limit=$limit";

  final Dio dio = Dio(BaseOptions(baseUrl: baseUrl));

  Future<CloudResponse> signIn(String password, String username) async {
    final requestBody = await _deviceCloudService.getDeviceInfo();
    requestBody['username'] = username;
    requestBody['password'] = password;

    try {
      final response = await dio.post(login, data: requestBody);

      if (response.success) {
        final tokenObject = CloudToken(
          refresh: response.data['refreshToken'],
          token: response.data['accessToken'],
          expires: response.data['expiresIn'],
          branchId: response.data['branchId'],
        );

        await _tokenDB.saveToken(tokenObject);

        return CloudResponse(success: true);
      }

      return CloudResponse(
        success: false,
        message: response.data['error'],
      );
    } on DioException catch (error) {
      log('Error on sign in client: ', error: error);
      return CloudResponse(
        success: false,
        message: error.response?.data['error'],
      );
    }
  }

  Future<CloudToken?> getTokenData() async {
    final tokenData = await _tokenDB.getToken();
    if (tokenData == null) return null;
    try {
      bool isExpired = JwtDecoder.isExpired(tokenData.token);
      if (!isExpired) return tokenData;

      if (JwtDecoder.isExpired(tokenData.refresh)) return null;

      final response = await dio.post(
        refresh,
        data: {'refreshToken': tokenData.refresh},
      );

      if (!response.success) return null;
      final tokenObject = CloudToken(
        refresh: response.data['refreshToken'],
        token: response.data['accessToken'],
        expires: response.data['expiresIn'],
        branchId: tokenData.branchId,
      );

      await _tokenDB.saveToken(tokenObject);

      return tokenObject;
    } catch (error) {
      log("error on refresh token:", error: error);
      return null;
    }
  }

  Future<CloudResponse> ingestEvent(CloudEventIngestion model) async {
    final token = await getTokenData();
    if (token == null) return CloudResponse(success: false, unauthorized: true);

    final requestBody = model.toJson();

    final sizeUnder = checkRequestSize(requestBody, 1023);

    if (sizeUnder) return CloudResponse(success: false, sizeUnder: true);

    try {
      final response = await dio.post(
        batchIngest,
        data: requestBody,
        options: Options(headers: {"Authorization": "Bearer ${token.token}"}),
      );

      if (response.success) return CloudResponse();
      return CloudResponse(
        success: false,
        unauthorized: response.statusCode == 401,
        message: response.data['error'],
      );
    } on DioException catch (error) {
      return CloudResponse(
        success: false,
        unauthorized: error.response?.statusCode == 401,
        message: error.response?.data['error'],
      );
    }
  }

  bool checkRequestSize(dynamic data, int size) {
    final jsonString = jsonEncode(data);
    final sizeInBytes = utf8.encode(jsonString).length;

    return sizeInBytes > (1024 * size);
  }
}
