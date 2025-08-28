import 'package:hive/hive.dart';

class ScreenDatabase {
  static final String _boxName = "screen_state";
  static final String _key = "key";

  static Future<bool> get() async {
    final box = await Hive.openBox(_boxName);
    return box.get(_key) ?? false;
  }

  static Future<void> set() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_key, (!(await get())));
  }
}
