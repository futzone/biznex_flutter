import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/cloud/entity_event.dart';
import 'package:biznex/src/core/cloud/local_changes_db.dart';
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
        Product product = item.product;
        product.amount = item.amount;
        await _updateProduct(product, shopping: fromShopping);
      }
    }
  }

  static Future<void> _updateProduct(Product product,
      {bool shopping = false}) async {
    final recipe = await recipeDatabase.productRecipe(product.id);
    if (recipe == null) return;
    for (final ingredient in recipe.items) {
      final updatedIngredient =
          await recipeDatabase.getIngredient(ingredient.ingredient.id);
      if (updatedIngredient == null) continue;

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

      await LocalChanges.instance.saveChange(
        event: IngredientTransactionEvent.INGREDIENT_TRANSACTION_CREATED,
        entity: Entity.INGREDIENT_TRANSACTION,
        objectId: ingredientTransaction.id,
      );

      await recipeDatabase.saveIngredient(updatedIngredient, product: product);
    }
  }
}
