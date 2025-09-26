import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/core/database/product_database/recipe_database.dart';
import 'package:biznex/src/core/database/product_database/shopping_database.dart';
import 'package:biznex/src/core/database/transactions_database/transactions_database.dart';
import 'package:biznex/src/core/model/product_models/ingredient_model.dart';
import 'package:biznex/src/core/model/product_models/recipe_model.dart';
import 'package:biznex/src/core/services/image_service.dart';
import 'package:biznex/src/providers/recipe_providers.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:uuid/uuid.dart';

import '../core/model/product_models/product_model.dart';
import '../core/model/product_models/recipe_item_model.dart';
import '../core/model/product_models/shopping_model.dart';

class RecipeController {
  final BuildContext context;

  RecipeController({required this.context});

  final RecipeDatabase recipeDatabase = RecipeDatabase();
  final ShoppingDatabase shoppingDatabase = ShoppingDatabase();
  final ProductDatabase productDatabase = ProductDatabase();
  final TransactionsDatabase transactionsDatabase = TransactionsDatabase();

  Future saveIngredientFromProduct({
    required WidgetRef ref,
    required Product product,
  }) async {
    String? imageUrl;
    if (product.images?.firstOrNull != null) {
      imageUrl = await ImageService.copyImageToAppFolder(
        product.images?.firstOrNull ?? '',
      );
    }

    final Ingredient ingredient = Ingredient(
      name: product.name,
      quantity: product.amount,
      unitPrice: product.price,
      image: imageUrl,
      calory: 0,
      measure: product.measure,
      id: Uuid().v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final recipe = Recipe(
      items: [
        RecipeItem(
          ingredient: ingredient,
          amount: 1,
          price: product.price,
        ),
      ],
      product: product,
      id: Uuid().v4(),
      createdDate: DateTime.now(),
      updatedDate: DateTime.now(),
    );

    await recipeDatabase.saveIngredient(ingredient);
    await recipeDatabase.saveRecipe(recipe);
    ref.invalidate(ingredientsProvider);
    ref.invalidate(recipesProvider);
  }

  Future saveIngredient({
    required WidgetRef ref,
    String? name,
    double? quantity,
    double? price,
    String? image,
    String? id,
    String? measure,
    double? calory,
  }) async {
    String? imageUrl;
    if (image != null && image.isNotEmpty) {
      imageUrl = await ImageService.copyImageToAppFolder(image);
    }

    if (name != null && name.isEmpty && id == null) {
      return ShowToast.error(context, AppLocales.nameInputError.tr());
    }

    if (id != null) {
      final old = await recipeDatabase.getIngredient(id);
      if (old != null) {
        old.updatedAt = DateTime.now();
        if (name != null) old.name = name;
        if (quantity != null) old.quantity = quantity;
        if (price != null) old.unitPrice = price;
        if (image != null) old.image = imageUrl;
        if (calory != null) old.calory = calory;
        if (measure != null) old.measure = measure;

        await recipeDatabase.saveIngredient(old);
        ref.invalidate(ingredientsProvider);
        return;
      }
    }

    final Ingredient ingredient = Ingredient(
      name: name ?? '',
      quantity: quantity ?? 0,
      unitPrice: price,
      image: imageUrl,
      calory: calory,
      measure: measure,
      id: Uuid().v4(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await recipeDatabase.saveIngredient(ingredient);
    ref.invalidate(ingredientsProvider);
  }

  Future saveRecipe({
    required WidgetRef ref,
    required Product product,
    List<RecipeItem>? items,
  }) async {
    final old = await recipeDatabase.productRecipe(product.id);

    if (old == null && items == null) {
      return ShowToast.error(context, AppLocales.recipeItemsError.tr());
    }

    if (old != null && items != null) {
      old.items = items;
      old.updatedDate = DateTime.now();
      await recipeDatabase.saveRecipe(old);
      ref.invalidate(productRecipeProvider);
      ref.invalidate(productRecipeProvider(product.id));
      ref.invalidate(recipesProvider);
      return;
    }

    Recipe recipe = Recipe(
      items: items ?? [],
      product: product,
      id: product.id,
      createdDate: DateTime.now(),
      updatedDate: DateTime.now(),
    );

    await recipeDatabase.saveRecipe(recipe);
    ref.invalidate(productRecipeProvider);
    ref.invalidate(productRecipeProvider(product.id));
    ref.invalidate(recipesProvider);
    return;
  }

  Future<void> saveShopping({
    required WidgetRef ref,
    String? note,
    String? id,
    double? price,
    List<RecipeItem>? items,
  }) async {
    if (id == null && (items == null || items.isEmpty)) {
      return ShowToast.error(context, AppLocales.shoppingItemsError.tr());
    }

    if (id != null) {
      final old = await shoppingDatabase.getShopping(id);
      if (old != null) {
        old.updatedDate = DateTime.now();
        if (note != null) old.note = note;
        if (price != null) old.totalPrice = price;
        if (items != null) old.items = items;

        await shoppingDatabase.createShopping(old);
        for (final item in items ?? <RecipeItem>[]) {
          final ingredient = item.ingredient;
          ingredient.quantity += item.amount;
          ingredient.updatedAt = DateTime.now();
          if (item.price != null) ingredient.unitPrice = item.price;
          await recipeDatabase.saveIngredient(ingredient);
        }
        ref.invalidate(shoppingProvider);
        ref.invalidate(ingredientsProvider);
        return;
      }
    }

    final Shopping shopping = Shopping(
      id: Uuid().v4(),
      createdDate: DateTime.now(),
      updatedDate: DateTime.now(),
      totalPrice: price ??
          ((items ?? []).fold(0.0, (tot, el) {
            return tot += el.amount * (el.price ?? 0.0);
          })),
      items: items ?? [],
      note: note,
    );

    await shoppingDatabase.createShopping(shopping);
    for (final item in items ?? <RecipeItem>[]) {
      final ingredient = item.ingredient;
      ingredient.quantity += item.amount;
      ingredient.updatedAt = DateTime.now();
      if (item.price != null) ingredient.unitPrice = item.price;
      await recipeDatabase.saveIngredient(ingredient);
    }

    ref.invalidate(shoppingProvider);
    ref.invalidate(ingredientsProvider);

    return;
  }
}
