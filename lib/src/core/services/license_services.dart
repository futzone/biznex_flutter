import 'dart:developer';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/services/device_id_service.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class LicenseServices {
  final String _key =
      "oakqGiacopoTeujlblLHfuH1iCu9BruH5qvmGbvRUYsxfZ88LCBvNSJYJu4hxuHMNs8JkILPgFYtainx7MlwRr5FAQQz7JcLQ3h8SRlxICJzEQJQdPWgAYkqTvqZfr3QWQ";

  Future<String?> getDeviceId() async {
    DeviceIdService deviceIdService = DeviceIdService();
    final id = await deviceIdService.getDeviceId();
    return id;
  }

  Future<bool> verifyLicense(String inputKey) async {
    try {
      final jwt = JWT.verify(inputKey, SecretKey(_key));
      final id = await getDeviceId();

      return jwt.payload['id'] == id;
    } catch (error) {
      log(error.toString());
      return false;
    }
  }

  Future<int> getJwtDaysLeft() async {
    try {
      final token = await AppStateDatabase().getApp();
      final decoded = JWT.decode(token.licenseKey).payload;
      if (decoded.containsKey("exp")) {
        int exp = decoded["exp"];
        DateTime expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
        Duration diff = expiryDate.difference(DateTime.now());
        return diff.inDays;
      }
    } catch (e) {
      print("JWT decode error: $e");
    }
    return -1;
  }
}
