import 'package:biznex/src/controllers/changes_controller.dart';
import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/model/app_changes_model.dart';

class ChangesDatabase extends AppDatabase {
  final String boxName = 'changes';

  @override
  Future delete({required String key}) async {
    final box = await openBox(boxName);
    await box.delete(key);
  }

  @override
  Future<List<Change>> get() async {
    final box = await openBox(boxName);
    final boxData = box.values;

    final List<Change> productInfoList = [];
    for (final item in boxData) {
      productInfoList.add(Change.fromJson(item));
    }

    return productInfoList;
  }

  @override
  Future<void> set({required data}) async {
    if (data is! Change) return;

    ChangesController changesController = ChangesController(data);
    final status = await changesController.saveStatus();
    if (status) return;

    Change productInfo = data;
    productInfo.id = generateID;

    final box = await openBox(boxName);
    await box.put(productInfo.id, productInfo.toJson());
  }

  @override
  Future<void> update({required String key, required data}) async {
    if (data is! Change) return;

    final box = await openBox(boxName);
    box.put(key, data.toJson());
  }
}
