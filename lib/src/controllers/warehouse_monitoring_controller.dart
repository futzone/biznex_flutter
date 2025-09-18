import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/database/isar_database/isar_extension.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/core/database/product_database/recipe_database.dart';
import 'package:biznex/src/core/database/product_database/shopping_database.dart';
import 'package:biznex/src/core/database/transactions_database/transactions_database.dart';
import 'package:biznex/src/core/model/ingredient_models/ingredient_model.dart';
import 'package:biznex/src/core/model/product_models/ingredient_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/core/model/product_models/recipe_item_model.dart';
import 'package:uuid/uuid.dart';
import 'package:isar/isar.dart';

class WarehouseMonitoringController {
  final AppModel model;

  WarehouseMonitoringController(this.model);

  final ProductDatabase productDatabase = ProductDatabase();
  static final RecipeDatabase recipeDatabase = RecipeDatabase();
  final TransactionsDatabase transactionsDatabase = TransactionsDatabase();
  final ShoppingDatabase shoppingDatabase = ShoppingDatabase();
  static final Isar isarDatabase = IsarDatabase.instance.isar;

  static Future<void> updateFromShopping(
      RecipeItem item, String message) async {
    // IngredientTransaction ingredientTransaction = IngredientTransaction()
    //   ..updatedDate = DateTime.now().toIso8601String()
    //   ..createdDate = DateTime.now().toIso8601String()
    //   ..amount = item.amount
    //   ..product = Product(name: message, price: 0.0).toIsar()
    //   ..fromShopping = true
    //   ..id = item.ingredient.id;
    //
    // await isarDatabase.writeTxn(() async {
    //   await isarDatabase.ingredientTransactions.put(ingredientTransaction);
    // });
  }

  static Future<void> updateIngredientDetails({
    List<OrderItem>? products,
    bool fromShopping = false,
  }) async {
    if (products != null) {
      for (final item in products) {
        await _updateProduct(item.product, shopping: fromShopping);
      }
    }
  }

  static Future<void> _updateProduct(Product product,
      {bool shopping = false}) async {
    final recipe = await recipeDatabase.productRecipe(product.id);
    if (recipe == null) return;
    for (final ingredient in recipe.items) {
      final updatedIngredient = ingredient.ingredient;

      updatedIngredient.updatedAt = DateTime.now();

      final decrease = ingredient.amount * product.amount;

      updatedIngredient.quantity =
          (decrease > (updatedIngredient.quantity - decrease))
              ? 0
              : (updatedIngredient.quantity - decrease);

      IngredientTransaction ingredientTransaction = IngredientTransaction()
        ..updatedDate = DateTime.now().toIso8601String()
        ..createdDate = DateTime.now().toIso8601String()
        ..amount = decrease
        ..product = product.toIsar()
        ..fromShopping = shopping
        ..id = ingredient.ingredient.id;

      await isarDatabase.writeTxn(() async {
        await isarDatabase.ingredientTransactions.put(ingredientTransaction);
      });

      await recipeDatabase.saveIngredient(updatedIngredient, product: product);
    }
  }
}
