import 'dart:developer';

import 'package:biznex/src/core/services/device_id_service.dart';
import 'package:pocketbase/pocketbase.dart';

class AppSubscriptionDatabase {
  static final String _password =
      "aLJHYGfWlzJE0Pzu5zyKkvxAlc0OAQo6dl8pXnjsdgGL7vjfKz";
  final DeviceIdService deviceIdService = DeviceIdService();
  final pb = PocketBase('https://noco.biznex.uz');

  Future<void> createSubscription() async {
    try {
      final body = <String, dynamic>{
        "client_id": "test",
        "code": 123,
        "token": "",
        "status": "pending",
        "password": _password
      };

      final record = await pb.collection('subscriptions').create(body: body);
      log("Created: ${record.id}");

      return record.data['message'];
    } on ClientException catch (error) {
      return error.response['message'];
    }
  }

  Future<void> confirmSubscription(String id, String token) async {
    try {
      final body = <String, dynamic>{
        "status": "confirmed",
        "token": token,
        "password": _password
      };

      final record =
          await pb.collection('subscriptions').update(id, body: body);
      log("Updated: ${record.toJson()}");
    } on ClientException catch (error) {
      return error.response['message'];
    }
  }

  listenChanges () async {
    final clientId = await deviceIdService.getDeviceId();

    pb.collection('subscriptions').subscribe("*", (e) {

      if (clientId == "test") {
        log("Update for this client: ${e.record?.data}");
      }
    });

  }
}
