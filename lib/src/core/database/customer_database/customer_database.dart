import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/model/other_models/customer_model.dart';
 
class CustomerDatabase extends AppDatabase {
  final String boxName = 'customer';

  String get endpoint => '/api/v2/$boxName';

  @override
  Future delete({required String key}) async {
    final box = await openBox(boxName);
    await box.delete(key);
  }

  @override
  Future<List<Customer>> get() async {
    final box = await openBox(boxName);
    final boxData = box.values;

    final List<Customer> productInfoList = [];
    for (final item in boxData) {
      productInfoList.add(Customer.fromJson(item));
    }

    return productInfoList;
  }

  @override
  Future<void> set({required data}) async {
    if (data is! Customer) return;

    Customer productInfo = data;
    productInfo.id = generateID;

    final box = await openBox(boxName);
    await box.put(productInfo.id, productInfo.toJson());
  }

  @override
  Future<void> update({required String key, required data}) async {
    if (data is! Customer) return;

    final box = await openBox(boxName);
    box.put(key, data.toJson());
  }
}
