import 'package:biznex/src/controllers/changes_controller.dart';
import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/model/app_changes_model.dart';
import 'package:uuid/uuid.dart';

class ChangesDatabase {
  final String boxName = 'changes';

  Future delete({required String key}) async {
    final box = await openBox(boxName);
    await box.delete(key);
  }

  Future<List<Change>> get() async {
    final box = await openBox(boxName);
    final boxData = box.values;

    final List<Change> productInfoList = [];
    for (final item in boxData) {
      productInfoList.add(Change.fromJson(item));
    }

    return productInfoList;
  }

  Future<Box> openBox(String boxName) async {
    final box = await Hive.openBox(boxName);
    return box;
  }

  String get generateID {
    var uuid = Uuid();
    return uuid.v1();
  }

  Future<void> set({required data}) async {
    if (data is! Change) return;

    Change productInfo = data;
    productInfo.id = generateID;

    final box = await openBox(boxName);
    await box.put(productInfo.id, productInfo.toJson());
  }

  Future<void> update({required String key, required data}) async {
    if (data is! Change) return;

    final box = await openBox(boxName);
    box.put(key, data.toJson());
  }
}
