import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/ui/pages/cloud_pages/cloud_page.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';



Future<void> saveQrAsPng() async {
  final boundary =
      qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

  final ui.Image image = await boundary.toImage(pixelRatio: 3.0);

  final ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

  final Uint8List pngBytes = byteData!.buffer.asUint8List();

  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/qr_code.png');

  await file.writeAsBytes(pngBytes);
}
