import 'dart:convert';
import 'package:biznex/src/core/cloud/entity_event.dart';
import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import '../../cloud/local_changes_db.dart';

class ProductDatabase extends AppDatabase {
  final String boxName = 'products';

  Future<void> clear() async {
    final box = await openBox(boxName);
    await box.clear();
  }

  String get endpoint => '/api/v2/$boxName';

  @override
  Future delete({required String key}) async {
    final box = await openBox(boxName);

    final product = await getProductById(key);
    if (product == null) return;

    await LocalChanges.instance.saveChange(
      event: ProductEvent.PRODUCT_DELETED,
      entity: Entity.PRODUCT,
      objectId: key,
    );
    await box.delete(key);
  }

  @override
  Future<List<Product>> get() async {
    List<Product> rootCategories = [];

    if ((await connectionStatus()) != null) {
      final response = await getRemote(boxName: boxName);
      if (response != null) {
        for (final item in jsonDecode(response)) {
          rootCategories.add(Product.fromJson(item));
        }
      }

      return rootCategories;
    }

    final box = await openBox(boxName);
    final boxData = box.values;

    for (var prod in boxData) {
      rootCategories.add(Product.fromJson(prod));
    }

    return rootCategories;
  }

  @override
  Future<void> set({required data}) async {
    if (data is! Product) return;

    Product productInfo = data;

    final box = await openBox(boxName);
    await box.put(productInfo.id, productInfo.toJson());

    await LocalChanges.instance.saveChange(
      event: ProductEvent.PRODUCT_CREATED,
      entity: Entity.PRODUCT,
      objectId: productInfo.id,
    );


  }

  @override
  Future<void> update({required String key, required data}) async {
    if (data is! Product) return;

    final box = await openBox(boxName);
    box.put(key, data.toJson());

    await LocalChanges.instance.saveChange(
      event: ProductEvent.PRODUCT_UPDATED,
      entity: Entity.PRODUCT,
      objectId: key,
    );
  }

  Future<List<Product>> getAll() async {
    final box = await openBox(boxName);
    final boxData = box.values;

    final List<Product> productInfoList = [];
    for (final item in boxData) {
      productInfoList.add(Product.fromJson(item));
    }

    return productInfoList;
  }

  Future<Product?> getProductById(String id) async {
    final box = await openBox(boxName);
    final productData = await box.get(id);

    return productData == null ? null : Product.fromJson(productData);
  }
}
