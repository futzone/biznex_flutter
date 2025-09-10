import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/database/product_database/recipe_database.dart';
import 'package:biznex/src/core/database/product_database/shopping_database.dart';
import 'package:biznex/src/core/model/ingredient_models/ingredient_model.dart';
import 'package:isar/isar.dart';

final productRecipeProvider = FutureProvider.family((ref, String id) async {
  final RecipeDatabase recipeDatabase = RecipeDatabase();
  final recipe = await recipeDatabase.productRecipe(id);
  return recipe;
});

final ingredientsProvider = FutureProvider((ref) async {
  final RecipeDatabase recipeDatabase = RecipeDatabase();
  final data = await recipeDatabase.getIngredients();
  return data;
});

final recipesProvider = FutureProvider((ref) async {
  final RecipeDatabase recipeDatabase = RecipeDatabase();
  final data = await recipeDatabase.getRecipe();
  return data;
});

final shoppingProvider = FutureProvider((ref) async {
  final ShoppingDatabase shoppingDatabase = ShoppingDatabase();
  final data = await shoppingDatabase.get();
  return data;
});

final ingredientTransactionsProvider = FutureProvider((ref) async {
  final isar = IsarDatabase.instance.isar;
  final data = await isar.ingredientTransactions.where().findAll();
  return data;
});
