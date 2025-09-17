import 'dart:convert';

import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/model/app_changes_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/core/utils/product_utils.dart';

class ProductDatabase extends AppDatabase {
  final String boxName = 'products';

  String get endpoint => '/api/v2/$boxName';

  @override
  Future delete({required String key}) async {
    final box = await openBox(boxName);

    final product = await getProductById(key);
    if (product == null) return;

    await changesDatabase.set(
      data: Change(
        database: boxName,
        method: 'delete',
        itemId: key,
        data: product.name,
      ),
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

    Map<String, Product> productMap = {};

    for (var prod in boxData) {
      productMap[prod['id']] = Product.fromJson(prod);
    }

    for (var prod in productMap.values) {
      if (prod.productId == null) {
        rootCategories.add(prod);
      } else {
        var parent = productMap[prod.productId];
        if (parent != null) {
          parent.variants ??= [];
          parent.variants!.add(prod);
        }
      }
    }

    return rootCategories;
  }

  @override
  Future<void> set({required data}) async {
    if (data is! Product) return;

    Product productInfo = data;
    productInfo.id = generateID;

    if (productInfo.barcode == null || productInfo.barcode!.isEmpty) {
      productInfo.barcode = ProductUtils.generateBarcode();
    }

    if (productInfo.tagnumber == null || productInfo.tagnumber!.isEmpty) {
      productInfo.tagnumber = ProductUtils.newTagnumber;
    }

    final box = await openBox(boxName);
    await box.put(productInfo.id, productInfo.toJson());

    await changesDatabase.set(
      data: Change(
        database: boxName,
        method: 'create',
        itemId: productInfo.id,
      ),
    );
  }

  @override
  Future<void> update({required String key, required data}) async {
    if (data is! Product) return;

    final box = await openBox(boxName);
    box.put(key, data.toJson());

    await changesDatabase.set(
      data: Change(
        database: boxName,
        method: 'update',
        itemId: key,
      ),
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
