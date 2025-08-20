import 'dart:math';
import 'package:uuid/uuid.dart';

class ProductUtils {
  static String get newBarcode => generateBarcode();

  static String get newTagnumber => generateTagnumber();

  static String generateBarcode({int length = 12}) {
    Random random = Random();
    return List.generate(length, (_) => random.nextInt(10)).join();
  }

  static String generateTagnumber({int length = 5}) {
    var uuid = Uuid();
    String barcodeData = uuid.v4().substring(0, length);
    return barcodeData.toUpperCase();
  }

  static String get generateID {
    var uuid = Uuid();
    return uuid.v1();
  }
}
