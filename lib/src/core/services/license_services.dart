import 'dart:developer';
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
}
