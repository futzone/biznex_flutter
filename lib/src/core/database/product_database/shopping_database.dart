import 'dart:developer';

import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/model/product_models/shopping_model.dart';

import '../../model/ingredient_models/ingredient_model.dart';

class ShoppingDatabase {
  final String _boxName = "shopping";

  Future<void> createShopping(Shopping shopping) async {

    for(final item in shopping.items) {
      // IngredientTransaction ingredientTransaction = IngredientTransaction()
      //   ..updatedDate = DateTime.now().toIso8601String()
      //   ..createdDate = DateTime.now().toIso8601String()
      //   ..amount = decrease
      //   ..product = product.toIsar()
      //   ..id = Uuid().v4();
      //
      // await isarDatabase.writeTxn(() async {
      //   await isarDatabase.ingredientTransactions.put(ingredientTransaction);
      // });
    }



    final box = await Hive.openBox(_boxName);
    await box.put(shopping.id, shopping.toMap());
  }

  Future<List<Shopping>> get() async {
    final box = await Hive.openBox(_boxName);
    final data = box.values;
    final List<Shopping> list = [];
    for (final item in data) {
      try {
        list.add(Shopping.fromMap(item));
      } catch (kd) {
        log("Shopping fromMap():", error: kd);
        continue;
      }
    }

    return list;
  }

  Future<Shopping?> getShopping(id) async {
    final box = await Hive.openBox(_boxName);
    final data = box.get(id);
    if (data == null) return null;
    try {
      return Shopping.fromMap(data);
    } catch (_) {
      return null;
    }
  }
}
