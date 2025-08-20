import 'dart:developer';
import 'dart:io';
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

    log(identifier.toString());

    var bytes = utf8.encode(identifier ?? Uuid().v4().toString());
    var digest = sha256.convert(bytes);
    log((digest.toString() == "97355c72a3081d2de64e828b4a7decae2b7293afe79f4472d3598ccfc3c5c31c").toString());
    return digest.toString();
  }
}
