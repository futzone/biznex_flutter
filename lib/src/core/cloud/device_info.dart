import 'dart:io';
import 'package:biznex/main.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class DeviceCloudService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  Future<Map<String, dynamic>> getDeviceInfo() async {
    if (Platform.isWindows) {
      WindowsDeviceInfo windowsInfo = await _deviceInfo.windowsInfo;

      String deviceName = windowsInfo.computerName;

      String machineId = windowsInfo.deviceId;

      String osInfo =
          "${windowsInfo.productName} ${windowsInfo.displayVersion}";

      String diskSerial = await getDiskSerial();
      String macAddress = await getMacAddress();

      var bytes = utf8.encode("$machineId-$diskSerial-$macAddress");
      String deviceFingerprint = sha256.convert(bytes).toString();

      return {
        "deviceFingerprint": deviceFingerprint,
        "machineId": machineId,
        "diskSerial": diskSerial,
        "macAddress": macAddress,
        "deviceName": deviceName,
        "appVersion": appVersion,
        "osInfo": osInfo
      };
    }
    return {};
  }

  Future<String> getDiskSerial() async {
    ProcessResult result =
        await Process.run('wmic', ['diskdrive', 'get', 'serialnumber']);
    String diskSerial = result.stdout.toString().split('\n')[1].trim();
    return diskSerial;
  }

  Future<String> getMacAddress() async {
    ProcessResult result = await Process.run('getmac', ['/fo', 'csv', '/nh']);

    if (result.exitCode == 0) {
      String output = result.stdout.toString();

      RegExp regExp = RegExp(r"([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})");
      Match? match = regExp.firstMatch(output);

      return match?.group(0) ?? "";
    }
    return "";
  }
}
