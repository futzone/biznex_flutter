import 'dart:developer';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/cloud/entity_event.dart';
import 'package:biznex/src/core/cloud/local_changes_db.dart';
import 'package:biznex/src/core/model/product_models/ingredient_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/core/model/product_models/recipe_item_model.dart';
import 'package:biznex/src/core/model/product_models/recipe_model.dart';
import 'package:biznex/src/core/utils/action_listener.dart';
import 'package:hive/hive.dart';
import '../../../controllers/warehouse_monitoring_controller.dart';

class RecipeDatabase {
  final String _recipeBox = "recipe";
  final String _ingredientsBox = "ingredients";

  String get recipeBox => _recipeBox;

  String get ingBox => _ingredientsBox;

  Future<Box> ingredientsBox() async {
    return await Hive.openBox(_recipeBox);
  }

  Future<List<Recipe>> getRecipe() async {
    final box = await Hive.openBox(_recipeBox);
    final data = box.values;

    List<Recipe> list = [];
    for (final item in data) {
      try {
        list.add(Recipe.fromJson(item));
      } catch (_) {
        continue;
      }
    }

    return list;
  }

  Future<List<Ingredient>> getIngredients() async {
    final box = await Hive.openBox(_ingredientsBox);
    final data = box.values;

    List<Ingredient> list = [];
    for (final item in data) {
      try {
        list.add(Ingredient.fromMap(item));
      } catch (_) {
        continue;
      }
    }

    return list;
  }

  Future<Ingredient?> getIngredient(id) async {
    final box = await Hive.openBox(_ingredientsBox);
    final data = await box.get(id);
    if (data == null) return null;
    try {
      return Ingredient.fromMap(data);
    } catch (e) {
      log("Get in error:", error: e);
      return null;
    }
  }

  Future<void> deleteIngredient(id) async {
    final box = await Hive.openBox(_ingredientsBox);

    final ingredient = await getIngredient(id);
    if (ingredient != null) {
      await LocalChanges.instance.saveChange(
        event: IngredientEvent.INGREDIENT_DELETED,
        entity: Entity.INGREDIENT,
        objectId: id,
      );
    }

    await box.delete(id);

    ActionController.add('value');
  }

  Future<void> deleteRecipe(id) async {
    final box = await Hive.openBox(_recipeBox);

    final recipe = await getOneRecipe(id);
    if (recipe != null) {
      await LocalChanges.instance.saveChange(
        event: RecipeEvent.RECIPE_DELETED,
        entity: Entity.RECIPE,
        objectId: id,
      );
    }

    await box.delete(id);
  }

  Future<Recipe?> productRecipe(String id) async {
    final box = await Hive.openBox(_recipeBox);
    final data = await box.get(id);
    if (data == null) return null;
    try {
      return Recipe.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<Recipe?> getOneRecipe(String id) async {
    final box = await Hive.openBox(_recipeBox);
    final data = await box.get(id);
    if (data == null) return null;
    try {
      return Recipe.fromJson(data);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveRecipe(Recipe recipe) async {
    final box = await Hive.openBox(_recipeBox);

    final old = await getOneRecipe(recipe.id);
    await LocalChanges.instance.saveChange(
      event:
          old != null ? RecipeEvent.RECIPE_UPDATED : RecipeEvent.RECIPE_CREATED,
      entity: Entity.RECIPE,
      objectId: recipe.id,
    );

    await box.put(recipe.id, recipe.toJson());
  }

  Future<void> saveIngredient(Ingredient ing, {Product? product}) async {
    final box = await Hive.openBox(_ingredientsBox);
    final old = await getIngredient(ing.id);
    if (old == null) {
      if (product == null) {
        await WarehouseMonitoringController.updateFromShopping(
          RecipeItem(ingredient: ing, amount: ing.quantity),
          AppLocales.createIngredient.tr(),
        );
      }
    } else {
      if (product == null) {
        await WarehouseMonitoringController.updateFromShopping(
          RecipeItem(
            ingredient: ing,
            amount: (ing.quantity - old.quantity).abs(),
          ),
          AppLocales.updateIngredient.tr(),
        );
      }
    }

    ActionController.add('value');

    await LocalChanges.instance.saveChange(
      event: old != null
          ? IngredientEvent.INGREDIENT_UPDATED
          : IngredientEvent.INGREDIENT_CREATED,
      entity: Entity.INGREDIENT,
      objectId: ing.id,
    );

    await box.put(ing.id, ing.toMap());
  }

  Future<void> clearRecipe() async {
    final box = await Hive.openBox(_recipeBox);
    await box.clear();
  }

  Future<void> clearIngredients() async {
    final box = await Hive.openBox(_ingredientsBox);
    await box.clear();

    ActionController.add('value');
  }
}
