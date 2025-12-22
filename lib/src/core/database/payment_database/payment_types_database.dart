import 'package:hive/hive.dart';

class PaymentTypesDatabase {
  static final String _boxName = "payment_types";
  static final String _keyName = "payment_types_key";

  Future<void> onSaveType(String name) async {
    final box = await Hive.openBox(_boxName);
    box.put(_keyName, name);
  }
}
