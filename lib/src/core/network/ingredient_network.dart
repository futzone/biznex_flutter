import 'dart:async';
import 'dart:developer';
import 'package:biznex/src/core/database/product_database/recipe_database.dart';
import 'package:biznex/src/core/model/product_models/ingredient_model.dart';
import 'endpoints.dart';
import '../services/license_services.dart';
import 'network_base.dart';

class IngredientNetwork {
  bool _isConnected = false;
  String? clientId;
  final Network network = Network();
  final LicenseServices licenseServices = LicenseServices();
  final RecipeDatabase recipeDatabase = RecipeDatabase();

  Future<void> create() async {
    if (!_isConnected) return;
    final List list = [];
    final ingredients = await recipeDatabase.getIngredients();
    for (final ing in ingredients) {
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

    await network
        .post(ApiEndpoints.ingredients, body: list)
        .then(printResponse);
  }

  Future<String> _getDeviceId() async {
    return await licenseServices.getDeviceId() ?? '';
  }

  Future<void> init(bool fromListener) async {
    clientId = await _getDeviceId();
    _isConnected = await network.isConnected();

    log("clientID: $clientId");
    await _onSyncOwnerChanges();
    await onSyncIngredients(fromListener);
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

  Future<void> onSyncIngredients(bool fromListener) async {
    if (!_isConnected) return;

    await network.delete("/ingredients/ingredient/clear/$clientId");

    await Future.delayed(Duration(milliseconds: 300));
    await create();
  }

  void printResponse(bool value) {
    log('CRUD ing-s: $value');
  }
}
