import 'package:hive/hive.dart';

class SyncService {
  static const String _boxName = "syncBox";
  static const String _lastSyncedKey = "lastSynced";
  final int hours;

  SyncService(this.hours);

  Future<String> canSync() async {
    final box = await Hive.openBox(_boxName);

    final lastSynced = box.get(_lastSyncedKey) as DateTime?;
    final now = DateTime.now();

    if (lastSynced == null) {
      await box.put(_lastSyncedKey, now);
      return 'first';
    }

    final diff = now.difference(lastSynced).inHours;
    if (diff >= hours) {
      await box.put(_lastSyncedKey, now);
      return 'default';
    }

    return 'no';
  }

  bool shouldSync(DateTime updated) {
    final now = DateTime.now();
    final diff = now.difference(updated).inHours;
    return diff <= hours;
  }
}
