import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/model/product_models/ingredient_model.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/core/model/product_models/recipe_item_model.dart';
import 'package:biznex/src/core/model/product_models/recipe_model.dart';
import 'package:hive/hive.dart';

import '../../../controllers/warehouse_monitoring_controller.dart';

class RecipeDatabase {
  final String _recipeBox = "recipe";
  final String _ingredientsBox = "ingredients";

  String get recipeBox => _recipeBox;

  String get ingBox => _ingredientsBox;

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

  Future<void> saveRecipe(Recipe recipe) async {
    final box = await Hive.openBox(_recipeBox);
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

    await box.put(ing.id, ing.toMap());
  }

  Future<void> clearRecipe() async {
    final box = await Hive.openBox(_recipeBox);
    await box.clear();
  }

  Future<void> clearIngredients() async {
    final box = await Hive.openBox(_ingredientsBox);
    await box.clear();
  }
}
