import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/model/product_params_models/product_measure.dart';
 
class ProductMeasureDatabase extends AppDatabase {
  final String boxName = 'product_measure';

  @override
  Future delete({required String key}) async {
    final box = await openBox(boxName);
    await box.delete(key);
  }

  @override
  Future<List<ProductMeasure>> get() async {
    final box = await openBox(boxName);
    final boxData = box.values;

    final List<ProductMeasure> productInfoList = [];
    for (final item in boxData) {
      productInfoList.add(ProductMeasure.fromJson(item));
    }

    return productInfoList;
  }

  @override
  Future<void> set({required data}) async {
    if (data is! ProductMeasure) return;

    ProductMeasure productInfo = data;
    productInfo.id = generateID;

    final box = await openBox(boxName);
    await box.put(productInfo.id, productInfo.toJson());
  }

  @override
  Future<void> update({required String key, required data}) async {
    if (data is! ProductMeasure) return;

    final box = await openBox(boxName);
    box.put(key, data.toJson());
  }
}
