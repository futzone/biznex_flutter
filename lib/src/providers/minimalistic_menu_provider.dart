import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/app_database/app_database.dart';

const _boxName = "menu_mode";
const _key = "key";

Future<bool> _getMenuMode() async {
  final box = await Hive.openBox(_boxName);
  final mode = await box.get(_key);
  return mode ?? true;
}

Future<void> setMenuMode(WidgetRef ref, bool mode) async {
  final box = await Hive.openBox(_boxName);
  await box.put(_key, mode);
  ref.invalidate(minimalisticMenuProvider);
  // ref.refresh(appStateProvider);
  // ref.invalidate(appStateProvider);
}

final minimalisticMenuProvider = FutureProvider((ref) async {
  final mode = await _getMenuMode();
  return mode;
});
