import 'dart:developer';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/cloud/entity_event.dart';
import 'package:biznex/src/core/cloud/local_changes_db.dart';
import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/extensions/for_date.dart';
import 'package:biznex/src/core/model/product_models/shopping_model.dart';
import 'package:biznex/src/core/model/product_models/recipe_item_model.dart';
import 'package:biznex/src/providers/employee_orders_provider.dart';
import '../../../controllers/warehouse_monitoring_controller.dart';

class ShoppingDatabase {
  final String _boxName = "shopping";

  String get boxName => _boxName;

  Future<void> clear() async {
    final box = await Hive.openBox(_boxName);
    await box.clear();
  }

  Future<void> createShopping(Shopping shopping) async {
    final oldShopping = await getShopping(shopping.id);
    if (oldShopping == null) {
      for (final item in shopping.items) {
        await WarehouseMonitoringController.updateFromShopping(
          item,
          AppLocales.shopping,
        );
      }
    } else {
      for (final item in shopping.items) {
        final itemChanges = oldShopping.items
            .where((el) => el.ingredient.id == item.ingredient.id)
            .firstOrNull;
        if (itemChanges == null) continue;

        final decrease = itemChanges.amount - item.amount;
        // item.amount = decrease.abs();

        await WarehouseMonitoringController.updateFromShopping(
          RecipeItem(
            ingredient: item.ingredient,
            amount: decrease.abs(),
          ),
          AppLocales.shoppingUpdated.tr(),
        );
      }
    }

    final box = await Hive.openBox(_boxName);
    await box.put(shopping.id, shopping.toMap());

    await LocalChanges.instance.saveChange(
      event: oldShopping == null
          ? ShoppingEvent.SHOPPING_CREATED
          : ShoppingEvent.SHOPPING_UPDATED,
      entity: Entity.SHOPPING,
      objectId: shopping.id,
    );
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

  Future<double> getShoppingStats(DateTime day, {DateTime? end}) async {
    final box = await Hive.openBox(_boxName);
    final data = box.values;

    double totalSum = 0.0;

    for (final item in data) {
      final shopping = Shopping.fromMap(item);
      if (end != null && end.dayEqualTo(shopping.createdDate)) {
        totalSum += shopping.totalPrice;
        continue;
      }
      if (day.dayEqualTo(shopping.createdDate)) {
        totalSum += shopping.totalPrice;
      }
    }

    return totalSum;
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
