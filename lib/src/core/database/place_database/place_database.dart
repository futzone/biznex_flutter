import 'dart:convert';
import 'dart:developer';

import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/model/place_models/place_model.dart';

class PlaceDatabase extends AppDatabase {
  final String boxName = 'places';

  Future<void> clear() async {
    final box = await openBox(boxName);
    await box.clear();
  }

  String get endpoint => '/api/v2/$boxName';

  @override
  Future delete({required String key, Place? father}) async {
    final box = await openBox(boxName);
    await box.delete(key);

    if (father != null) {
      Place kFather = father;
      kFather.children = [...(father.children ?? []).where((el) => el.id != key)];
      update(key: kFather.id, data: kFather);
      log('deleted');
    }
  }

  @override
  Future<List<Place>> get() async {
    final List<Place> productInfoList = [];

    if ((await connectionStatus()) != null) {
      final response = await getRemote(boxName: boxName);
      if (response != null) {
        for (final item in jsonDecode(response)) {
          productInfoList.add(Place.fromJson(item));
        }
      }

      return productInfoList;
    }

    final box = await openBox(boxName);
    final boxData = box.values;

    for (final item in boxData) {
      productInfoList.add(Place.fromJson(item));
    }

    return productInfoList;
  }

  @override
  Future<void> set({required data}) async {
    if (data is! Place) return;

    Place productInfo = data;
    productInfo.id = generateID;

    final box = await openBox(boxName);
    if (productInfo.father != null) {
      Place father = productInfo.father!;
      father.children = [
        ...father.children ?? [],
        productInfo,
      ];

      await update(key: father.id, data: father);
      return;
    }
    await box.put(productInfo.id, productInfo.toJson());
  }

  @override
  Future<void> update({required String key, required data}) async {
    if (data is! Place) return;

    final box = await openBox(boxName);
    box.put(key, data.toJson());
  }
}
