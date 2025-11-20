import 'dart:developer';
import 'dart:math' hide log;

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/services/device_id_service.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:pocketbase/pocketbase.dart';

class AppSubscriptionController {
  final BuildContext context;
  static const String _pending = "pending";
  static const String _confirmed = "confirmed";
  final Random _random = Random();

  AppSubscriptionController(this.context);

  static final String _password =
      "aLJHYGfWlzJE0Pzu5zyKkvxAlc0OAQo6dl8pXnjsdgGL7vjfKz";

  final DeviceIdService deviceIdService = DeviceIdService();
  final pb = PocketBase('https://noco.biznex.uz');

  Future<String> codeIsCorrect(int code) async {
    final deviceId = await deviceIdService.getDeviceId();

    final filter =
        '(code = $code && status = "$_pending") || (client_id = "$deviceId" && status = "$_pending")';

    try {
      final result = await pb.collection('subscriptions').getList(
        filter: filter,
        perPage: 1,
        headers: {"password": _password},
      );

      if (result.items.isEmpty) {
        return "free";
      }

      final item = result.items.first;

      if (item.data['client_id'] == deviceId) {
        return "already";
      }

      return "renew";
    } catch (_) {
      return "free";
    }
  }

  Future<int?> createSubscription() async {
    int code;
    String status = '';

    do {
      code = _random.nextInt(9000) + 1000;
      status = await codeIsCorrect(code);
    } while (status == "renew");

    try {
      final deviceId = await deviceIdService.getDeviceId();

      if (status == "already") {
        try {
          final old = await pb.collection('subscriptions').getList(
            perPage: 1,
            filter: 'client_id = "$deviceId" && status = "$_pending"',
            headers: {"password": _password},
          );

          if (old.items.isNotEmpty) {
            final id = old.items.first.id;

            await pb.collection('subscriptions').delete(
              id,
              body: {'client_id': deviceId},
            );
          }
        } catch (_) {}
      }

      final body = {
        "client_id": deviceId,
        "code": code,
        "token": "",
        "status": _pending,
        "password": _password,
      };

      final record = await pb.collection('subscriptions').create(body: body);

      log("Created: ${record.id}");
      return code;
    } on ClientException catch (error) {
      log(error.response.toString(), error: error);
      ShowToast.error(context, error.response['message'].toString());
      return null;
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

  Future listenChanges({required void Function(String token) onChanged}) async {
    final clientId = await deviceIdService.getDeviceId();

    await pb
        .collection('subscriptions')
        .subscribe("*", headers: {"password": _password}, (e) {
      if (e.record != null &&
          e.record?.data['client_id'] == clientId &&
          e.record?.data['status'] == _confirmed) {
        onChanged(e.record?.data['token'] ?? '');
      }
    });
  }
}
