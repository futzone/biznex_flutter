import 'dart:io';

import 'package:biznex/biznex.dart';

final networkInterfaceProvider = FutureProvider((ref) async {
  final interface = await NetworkInterface.list();
  final dataList = [];
  for (final item in interface) {
    for (final k in item.addresses) {
      dataList.add("${item.name}: ${k.address}");
    }
  }

  return dataList;
});
