import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/model/employee_models/role_model.dart';
 
class RoleDatabase extends AppDatabase {
  final String boxName = 'roles';

  @override
  Future delete({required String key}) async {
    final box = await openBox(boxName);
    await box.delete(key);
  }

  @override
  Future<List<Role>> get() async {
    final box = await openBox(boxName);
    final boxData = box.values;

    final List<Role> productInfoList = [];
    for (final item in boxData) {
      productInfoList.add(Role.fromJson(item));
    }

    return productInfoList;
  }

  @override
  Future<void> set({required data}) async {
    if (data is! Role) return;

    Role productInfo = data;
    productInfo.id = generateID;

    final box = await openBox(boxName);
    await box.put(productInfo.id, productInfo.toJson());
  }

  @override
  Future<void> update({required String key, required data}) async {
    if (data is! Role) return;

    final box = await openBox(boxName);
    box.put(key, data.toJson());
  }
}
