import 'package:biznex/biznex.dart';
import 'dart:io';

class NetworkServices {
  static Future<void> printAllIps() async {
    final interfaces = await NetworkInterface.list();

    for (var interface in interfaces) {
      if (interface.name == "Беспроводная сеть" || interface.name == "Ethernet") {

      }
      print('Interface: ${interface.name}');
      for (var addr in interface.addresses) {
        print('  IP: ${addr.address}');
      }
    }
  }

  static Future<dynamic> getDeviceIP() async {
    final result = await Process.run('ipconfig', []);
    final output = result.stdout.toString();

    final regex = RegExp(r'IPv4 Address[^\:]*: ([\d\.]+)');
    final match = regex.firstMatch(output);

    if (match != null) {
      return match.group(1);
    } else {
      return {"data": output};
    }
  }
}

final ipProvider = FutureProvider((ref) async {
  await NetworkServices.printAllIps();
  return await NetworkServices.getDeviceIP();
});
