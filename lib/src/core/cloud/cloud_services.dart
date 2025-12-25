import 'package:biznex/src/core/cloud/cloud_token_db.dart';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:dio/dio.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class BiznexCloudServices {
  final AppStateDatabase _stateDatabase = AppStateDatabase();
  final CloudTokenDB _tokenDB = CloudTokenDB();

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
}
