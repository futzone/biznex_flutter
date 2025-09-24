import 'dart:convert';

import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/model/category_model/category_model.dart';

class CategoryDatabase extends AppDatabase {
  final String boxName = 'categories';

  Future<void> clear() async {
    final box = await openBox(boxName);
    await box.clear();
  }

  String get endpoint => '/api/v2/$boxName';

  @override
  Future delete({required String key}) async {
    final box = await openBox(boxName);
    await box.delete(key);
  }

  @override
  Future<List<Category>> get() async {
    if ((await connectionStatus()) != null) {
      List<Category> list = [];
      final response = await getRemote(boxName: boxName);
      if (response != null) {
        for (final item in jsonDecode(response)) {
          list.add(Category.fromJson(item));
        }
      }

      return list;
    }

    final box = await openBox(boxName);
    final boxData = box.values;

    Map<String, Category> categoryMap = {};

    for (var category in boxData) {
      categoryMap[category['id']] = Category(
        id: category['id'],
        name: category['name'],
        parentId: category['parentId'],
      );
    }

    List<Category> rootCategories = [];

    for (var category in categoryMap.values) {
      if (category.parentId == null) {
        rootCategories.add(category);
      } else {
        var parent = categoryMap[category.parentId];
        if (parent != null) {
          parent.subcategories ??= [];
          parent.subcategories!.add(category);
        }
      }
    }

    return rootCategories;
  }

  @override
  Future<void> set({required data}) async {
    if (data is! Category) return;

    Category productInfo = data;
    productInfo.id = generateID;
    productInfo.updatedDate = DateTime.now().toIso8601String().toString();

    final box = await openBox(boxName);
    await box.put(productInfo.id, productInfo.toJson());
  }

  @override
  Future<void> update({required String key, required data}) async {
    if (data is! Category) return;
    data.updatedDate = DateTime.now().toIso8601String().toString();

    final box = await openBox(boxName);
    box.put(key, data.toJson());
  }

  Future<List<Category>> getAll() async {
    final box = await openBox(boxName);
    final boxData = box.values;

    final List<Category> productInfoList = [];
    for (final item in boxData) {
      productInfoList.add(Category.fromJson(item));
    }

    return productInfoList;
  }
}
