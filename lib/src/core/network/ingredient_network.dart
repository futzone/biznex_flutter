import 'package:biznex/src/core/database/product_database/recipe_database.dart';
import 'package:biznex/src/core/model/app_changes_model.dart';
import 'package:biznex/src/core/model/product_models/ingredient_model.dart';
import 'endpoints.dart';
import '../services/license_services.dart';
import 'network_base.dart';

class IngredientNetwork {
  final List<Change> changes;

  IngredientNetwork(this.changes);

  bool _isConnected = false;
  String? clientId;
  final Network network = Network();
  final LicenseServices licenseServices = LicenseServices();
  final RecipeDatabase recipeDatabase = RecipeDatabase();

  Future<String> _getDeviceId() async {
    return await licenseServices.getDeviceId() ?? '';
  }

  Future<void> init() async {
    clientId = await _getDeviceId();
    _isConnected = await network.isConnected();
    _onSyncOwnerChanges();
    _onSyncIngredients();
  }

  Future<void> _onSyncOwnerChanges() async {
    if (!_isConnected) return;

    final response = await network.get(
      ApiEndpoints.updatedIngredientsList(clientId, 1, 1000),
    );

    if (response != null && response is List) {
      for (final item in response) {
        try {
          final ing = Ingredient.fromJson(item);
          await recipeDatabase.saveIngredient(ing);
        } catch (_) {
          continue;
        }
      }
    }
  }

  Future<void> _onSyncIngredients() async {
    if (!_isConnected) return;
    List<Change> creates = [];
    List<Change> updates = [];
    List<Change> deletes = [];
    List<Change> clear = [];

    for (final change in changes) {
      if (change.database != recipeDatabase.ingBox) continue;

      if (change.method == 'create') creates.add(change);
      if (change.method == 'update') updates.add(change);
      if (change.method == 'delete') deletes.add(change);
      if (change.method == 'clear') clear.add(change);
    }

    if (clear.isNotEmpty) {
      final response = await network.delete(
        ApiEndpoints.ingredientsClear(clientId),
      );

      if (response) {
        for (final change in clear) {
          await recipeDatabase.changesDatabase.delete(key: change.id);
        }
      }
    }

    if (creates.isNotEmpty) {
      List<Map<String, dynamic>> list = [];
      for (final item in creates) {
        final ing = await recipeDatabase.getIngredient(item.itemId);
        if (ing == null) continue;
        list.add({
          "id": ing.id,
          "client_id": clientId,
          "name": ing.name,
          "last_updater": "local",
          "created_at": ing.createdAt.toIso8601String(),
          "updated_at": ing.updatedAt.toIso8601String(),
          "price": ing.unitPrice,
          "amount": ing.quantity,
        });
      }

      final response = await network.post(
        ApiEndpoints.ingredients,
        body: list,
      );

      if (response) {
        for (final change in creates) {
          await recipeDatabase.changesDatabase.delete(key: change.id);
        }
      }
    }

    if (updates.isNotEmpty) {
      List<Map<String, dynamic>> list = [];
      for (final item in updates) {
        final ing = await recipeDatabase.getIngredient(item.itemId);
        if (ing == null) continue;
        list.add({
          "id": ing.id,
          "client_id": clientId,
          "name": ing.name,
          "last_updater": "local",
          "created_at": ing.createdAt.toIso8601String(),
          "updated_at": ing.updatedAt.toIso8601String(),
          "price": ing.unitPrice,
          "amount": ing.quantity,
        });
      }

      final response = await network.put(
        ApiEndpoints.ingredients,
        body: list,
      );

      if (response) {
        for (final change in creates) {
          await recipeDatabase.changesDatabase.delete(key: change.id);
        }
      }
    }

    if (deletes.isNotEmpty) {
      List<String> list = [];
      for (final item in deletes) {
        list.add(item.itemId);
      }

      final response = await network.delete(
        ApiEndpoints.ingredientsOne(clientId),
        body: list,
      );

      if (response) {
        for (final change in creates) {
          await recipeDatabase.changesDatabase.delete(key: change.id);
        }
      }
    }
  }
}
