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
import 'package:biznex/src/providers/recipe_providers.dart';
import 'package:isar/isar.dart';
import 'package:uuid/uuid.dart';

class WarehouseMonitoringController {
   final AppModel model;

  WarehouseMonitoringController(this.model);

  final ProductDatabase productDatabase = ProductDatabase();
  final RecipeDatabase recipeDatabase = RecipeDatabase();
  final TransactionsDatabase transactionsDatabase = TransactionsDatabase();
  final ShoppingDatabase shoppingDatabase = ShoppingDatabase();
  final Isar isarDatabase = IsarDatabase.instance.isar;

  Future<void> updateIngredientDetails(
      {List<OrderItem>? products, Product? product}) async {
    if (model.after) {
      await _updateAfterOrder(products ?? []);
      return;
    }

    if (product == null) return;

    await _updateBeforeOrder(product);
  }

  Future<void> _updateAfterOrder(List<OrderItem> products) async {
    for (final item in products) {
      final recipe = await recipeDatabase.productRecipe(item.product.id);
      if (recipe == null) continue;

      for (final ingredient in recipe.items) {
        Ingredient? updatedIngredient =
            await recipeDatabase.getIngredient(ingredient.ingredient.id);

        if (updatedIngredient == null) continue;

        updatedIngredient.updatedAt = DateTime.now();

        final decrease = ingredient.amount * item.amount;
        updatedIngredient.quantity = (updatedIngredient.quantity - decrease > 0)
            ? (updatedIngredient.quantity - decrease)
            : 0;

        await recipeDatabase.saveIngredient(updatedIngredient);
      }
    }
  }

  Future<void> _updateBeforeOrder(Product product) async {
    final recipe = await recipeDatabase.productRecipe(product.id);
    if (recipe == null) return;
    for (final ingredient in recipe.items) {
      Ingredient? updatedIngredient =
          await recipeDatabase.getIngredient(ingredient.ingredient.id);

      if (updatedIngredient == null) continue;
      updatedIngredient.updatedAt = DateTime.now();

      final decrease = ingredient.amount * product.amount;
      updatedIngredient.quantity =
          (decrease > (updatedIngredient.quantity - decrease))
              ? 0
              : (updatedIngredient.quantity - decrease);
      await recipeDatabase.saveIngredient(updatedIngredient);

      IngredientTransaction ingredientTransaction = IngredientTransaction()
        ..updatedDate = DateTime.now().toIso8601String()
        ..createdDate = DateTime.now().toIso8601String()
        ..amount = decrease
        ..product = product.toIsar()
        ..id = Uuid().v4();

      await isarDatabase.writeTxn(() async {
        await isarDatabase.ingredientTransactions.put(ingredientTransaction);
      });
    }
  }
}
