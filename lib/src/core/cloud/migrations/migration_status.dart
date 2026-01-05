import 'package:hive/hive.dart';

class MigrationStatus {
  final String _boxName = "cloud_migration";
  final String _key = "status";

  Future<bool> getStatus() async {
    try {
      final box = await Hive.openBox(_boxName);
      final status = await box.get(_key) ?? false;
      return status;
    } catch (_) {
      return false;
    }
  }

  Future<void> saveStatus(bool status) async {
    final box = await Hive.openBox(_boxName);
    await box.put(_key, status);
  }
}
