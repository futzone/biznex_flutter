import 'dart:convert';
import 'dart:developer';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/extensions/for_dynamic.dart';
import 'package:biznex/src/core/model/cloud_models/client.dart';
import 'package:biznex/src/core/network/network_services.dart';
import 'package:biznex/src/core/network/password.dart';
import 'package:biznex/src/core/services/license_services.dart';

class CloudDataController {
  LicenseServices licenseServices = LicenseServices();
  PasswordDatabase passwordDatabase = PasswordDatabase();
  NetworkServices networkServices = NetworkServices();
  AppStateDatabase appStateDatabase = AppStateDatabase();

  Future createCloudAccount(String kPassword, String expireDate) async {
    if (kPassword.isEmpty || expireDate.isEmpty) return;

    final deviceID = await licenseServices.getDeviceId();
    final password = await passwordDatabase.getPassword();
    final appState = await appStateDatabase.getApp();

    Client client = Client(
      createdAt: DateTime.now().toIso8601String(),
      id: deviceID ?? '',
      name: jsonEncode({
        "name": appState.shopName.notNullOrEmpty("Biznex Client"),
        "channel": '',
        "token": '',
      }),
      password: password ?? '0000',
      updatedAt: DateTime.now().toIso8601String(),
      expiredDate: expireDate,
    );

    final bool isCreated = await networkServices.createClient(
      client,
      kPassword,
    );

    return isCreated;
  }
}
