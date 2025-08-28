import 'dart:convert';
import 'dart:developer';

import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/database/order_database/order_database.dart';
import 'package:biznex/src/core/model/app_changes_model.dart';
import 'package:biznex/src/core/model/order_models/percent_model.dart';
import 'package:biznex/src/core/network/endpoints.dart';

import '../../model/order_models/order_model.dart';

class OrderPercentDatabase extends AppDatabase {
  final String boxName = 'percent';
  final OrderDatabase orderDatabase = OrderDatabase();

  @override
  Future delete({required String key}) async {
    final percent = await getPercentById(key);
    if (percent == null) return;

    final box = await openBox(boxName);
    await box.delete(key);

    await changesDatabase.set(
      data: Change(
        database: boxName,
        method: 'delete',
        itemId: key,
        data: "${percent.name} (${percent.percent}%)",
      ),
    );
  }

  @override
  Future<List<Percent>> get() async {
    final List<Percent> productInfoList = [];
    if ((await connectionStatus()) != null) {
      await orderDatabase.connectionStatus();
      final response = await orderDatabase.getRemote(path: 'percents');
      if (response != null) {
        for (final item in jsonDecode(response)) {
          productInfoList.add(Percent.fromJson(item));
        }

        return productInfoList;
      }
    }

    final box = await openBox(boxName);
    final boxData = box.values;

    for (final item in boxData) {
      productInfoList.add(Percent.fromJson(item));
    }

    return productInfoList;
  }

  @override
  Future<void> set({required data}) async {
    if (data is! Percent) return;

    Percent productInfo = data;
    productInfo.id = generateID;

    final box = await openBox(boxName);
    await box.put(productInfo.id, productInfo.toJson());

    await changesDatabase.set(
      data: Change(
        database: boxName,
        method: 'create',
        itemId: productInfo.id,
        // data: "${percent.name} (${percent.percent}%)",
      ),
    );
  }

  @override
  Future<void> update({required String key, required data}) async {
    if (data is! Percent) return;

    final box = await openBox(boxName);
    box.put(key, data.toJson());
  }

  Future<Percent?> getPercentById(String id) async {
    final box = await openBox(boxName);
    final data = box.get(id);
    if (data == null) return null;
    return Percent.fromJson(data);
  }
}
