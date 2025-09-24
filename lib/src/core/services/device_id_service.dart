import 'dart:developer';
import 'dart:io';
import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

import 'package:uuid/uuid.dart';

class DeviceIdService {
  Future<String> getDeviceId() async {
    final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String? identifier;

    try {
      if (Platform.isWindows) {
        final WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
        identifier =
            '${windowsInfo.computerName}-${windowsInfo.deviceId.replaceAll("{", "").replaceAll("}", '')}-${windowsInfo.numberOfCores}-${windowsInfo.productName.replaceAll(' ', '')}-${windowsInfo.productName}-${windowsInfo.productId}';
      } else if (Platform.isMacOS) {
        final MacOsDeviceInfo macOsInfo = await deviceInfo.macOsInfo;

        identifier = macOsInfo.systemGUID;
      } else if (Platform.isLinux) {
        final LinuxDeviceInfo linuxInfo = await deviceInfo.linuxInfo;

        identifier = linuxInfo.machineId;
      } else {
        identifier = 'unsupported_platform';
      }
    } catch (e) {
      identifier = 'error_getting_id';
    }

    final storeId = await _getDeviceId();
    identifier = "$storeId${identifier ?? Uuid().v4()}";

    var bytes = utf8.encode(identifier);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<String> _getDeviceId() async {
    final box = await Hive.openBox("store");
    final deviceId = await box.get("deviceId");
    if (deviceId == null || deviceId is! String) {
      final id = Uuid().v4().toString();
      await box.put("deviceId", id);
      return id;
    }

    return deviceId;
  }
}
