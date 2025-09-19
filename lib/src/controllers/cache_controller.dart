import 'package:biznex/biznex.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/database/category_database/category_database.dart';
import 'package:biznex/src/core/database/employee_database/employee_database.dart';
import 'package:biznex/src/core/database/isar_database/isar.dart';
import 'package:biznex/src/core/database/place_database/place_database.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/core/database/product_database/recipe_database.dart';
import 'package:biznex/src/core/database/product_database/shopping_database.dart';
import 'package:biznex/src/core/database/transactions_database/transactions_database.dart';
import 'package:biznex/src/core/model/ingredient_models/ingredient_model.dart';
import 'package:biznex/src/core/model/order_models/order.dart';
import 'package:biznex/src/providers/category_provider.dart';
import 'package:biznex/src/providers/employee_orders_provider.dart';
import 'package:biznex/src/providers/orders_provider.dart';
import 'package:biznex/src/providers/place_status_provider.dart';
import 'package:biznex/src/providers/places_provider.dart';
import 'package:biznex/src/providers/products_provider.dart';
import 'package:biznex/src/providers/transaction_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:isar/isar.dart';
import '../providers/recipe_providers.dart';

class CacheController {
  final BuildContext context;
  final WidgetRef ref;
  final Isar _isar = IsarDatabase.instance.isar;
  final ShoppingDatabase _shoppingDatabase = ShoppingDatabase();
  final TransactionsDatabase _transactionsDatabase = TransactionsDatabase();
  final ProductDatabase _productDatabase = ProductDatabase();
  final RecipeDatabase _recipeDatabase = RecipeDatabase();
  final EmployeeDatabase _employeeDatabase = EmployeeDatabase();
  final PlaceDatabase _placeDatabase = PlaceDatabase();
  final CategoryDatabase _categoryDatabase = CategoryDatabase();

  void showLoading() => showAppLoadingDialog(context);

  void closeLoading() {
    AppRouter.close(context);
    AppRouter.close(context);
    ShowToast.success(context, AppLocales.clearCacheSuccess.tr());
  }

  CacheController(this.context, this.ref);

  void onClearCollections(List<String> collections) async {
    showLoading();

    if (collections.contains("categories")) {
      _categoryDatabase.clear().then((_) {
        ref.invalidate(categoryProvider);
        ref.invalidate(allCategoryProvider);
      });
    }

    if (collections.contains("places")) {
      _placeDatabase.clear().then((_) {
        ref.invalidate(placesProvider);
        ref.read(placeStatusProvider).clear();
      });
    }

    if (collections.contains("employees")) {
      _employeeDatabase.clear().then((_) {
        ref.invalidate(productsProvider);
      });
    }

    if (collections.contains("products")) {
      _productDatabase.clear().then((_) {
        ref.invalidate(productsProvider);
      });
    }

    if (collections.contains("ingredients")) {
      _recipeDatabase.clearIngredients().then((_) {
        ref.invalidate(ingredientsProvider);
      });
    }

    if (collections.contains("recipe")) {
      _recipeDatabase.clearRecipe().then((_) {
        ref.invalidate(recipesProvider);
      });
    }

    if (collections.contains("orders")) {
      await _isar.writeTxn(() async {
        await _isar.orderIsars.clear().then((_) {
          ref.invalidate(ordersFilterProvider);
          ref.invalidate(ordersProvider);
          ref.invalidate(employeeOrdersProvider);
          ref.read(orderSetProvider).clear();
        });
      });
    }

    if (collections.contains("ingredientTransactions")) {
      await _isar.writeTxn(() async {
        await _isar.ingredientTransactions.clear().then((_) {
          ref.invalidate(ingredientTransactionsProvider);
        });
      });
    }

    if (collections.contains("transactions")) {
      await _transactionsDatabase.clear().then((_) {
        ref.invalidate(transactionProvider);
      });
    }

    if (collections.contains("shopping")) {
      await _shoppingDatabase.clear().then((_) {
        ref.invalidate(shoppingProvider);
      });
    }

    closeLoading();
  }
}
