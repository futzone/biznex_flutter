import 'package:biznex/src/core/database/app_database/app_database.dart';
  import 'package:biznex/src/core/model/product_params_models/product_size.dart';

class ProductSizeDatabase extends AppDatabase {
  final String boxName = 'product_size';

  @override
  Future delete({required String key}) async {
    final box = await openBox(boxName);
    await box.delete(key);
  }

  @override
  Future<List<ProductSize>> get() async {
    final box = await openBox(boxName);
    final boxData = box.values;

    final List<ProductSize> productInfoList = [];
    for (final item in boxData) {
      productInfoList.add(ProductSize.fromJson(item));
    }

    return productInfoList;
  }

  @override
  Future<void> set({required data}) async {
    if (data is! ProductSize) return;

    ProductSize productInfo = data;
    productInfo.id = generateID;

    final box = await openBox(boxName);
    await box.put(productInfo.id, productInfo.toJson());
  }

  @override
  Future<void> update({required String key, required data}) async {
    if (data is! ProductSize) return;

    final box = await openBox(boxName);
    box.put(key, data.toJson());
  }
}
