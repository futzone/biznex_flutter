import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/model/product_models/shopping_model.dart';

class ShoppingDatabase {
  final String _boxName = "shopping";

  Future<void> createShopping(Shopping shopping) async {
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
      } catch (_) {
        continue;
      }
    }

    return list;
  }
}
