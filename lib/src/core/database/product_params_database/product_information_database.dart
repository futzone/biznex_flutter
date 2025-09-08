import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/model/product_params_models/product_info.dart';

class ProductInformationDatabase extends AppDatabase {
  final String boxName = 'product_info';

  @override
  Future delete({required String key}) async {
    final box = await openBox(boxName);
    await box.delete(key);
  }

  @override
  Future<List<ProductInfo>> get() async {
    final box = await openBox(boxName);
    final boxData = box.values;

    final List<ProductInfo> productInfoList = [];
    for (final item in boxData) {
      productInfoList.add(ProductInfo.fromJson(item));
    }

    return productInfoList;
  }

  @override
  Future<void> set({required data}) async {
    if (data is! ProductInfo) return;

    ProductInfo productInfo = data;
    productInfo.id = generateID;

    final box = await openBox(boxName);
    await box.put(productInfo.id, productInfo.toJson());
  }

  @override
  Future<void> update({required String key, required data}) async {
    if (data is! ProductInfo) return;

    final box = await openBox(boxName);
    box.put(key, data.toJson());
  }
}
