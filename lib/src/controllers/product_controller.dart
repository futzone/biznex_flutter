import 'dart:convert';
import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/app_controller.dart';
import 'package:biznex/src/controllers/warehouse_monitoring_controller.dart';
import 'package:biznex/src/core/cloud/cloud_services.dart';
import 'package:biznex/src/core/cloud/entity_event.dart';
import 'package:biznex/src/core/cloud/local_changes_db.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/core/database/product_database/recipe_database.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/core/services/image_service.dart';
import 'package:biznex/src/providers/products_provider.dart';
import 'package:biznex/src/providers/recipe_providers.dart';
import 'package:biznex/src/ui/widgets/custom/app_confirm_dialog.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import 'package:biznex/src/core/database/audit_log_database/logger_service.dart';
import 'package:uuid/uuid.dart';

class ProductController extends AppController {
  final void Function()? onClose;
  final RecipeDatabase recipeDatabase = RecipeDatabase();
  final BiznexCloudServices cloudServices = BiznexCloudServices();

  ProductController({
    this.onClose,
    required super.context,
    required super.state,
  });

  Future _onUpdateChanges(Product product) async {
    final recipe = await recipeDatabase.productRecipe(product.id);
    if (recipe == null) {
      log("Recipe not found for product: ${product.id}");
      return;
    }

    for (final item in recipe.items) {
      await WarehouseMonitoringController.updateFromShopping(
        item,
        AppLocales.productUpdate.tr(),
      );

      log("updated for: ${item.ingredient.name}");
    }
  }

  @override
  Future<void> create(data) async {
    data as Product;
    if (data.name.isEmpty) return error(AppLocales.productNameInputError.tr());
    showAppLoadingDialog(context);
    Product kProduct = data;
    List<String> kImages = [];
    final images = data.images;

    for (final item in images ?? []) {
      try {
        final path = await ImageService.copyImageToAppFolder(item.toString());
        kImages.add(path);
      } catch (error) {
        log(error.toString());
      }
    }

    kProduct.images = kImages;
    kProduct.oldImage = kImages.firstOrNull;
    Uuid uuid = Uuid();
    ProductDatabase sizeDatabase = ProductDatabase();
    kProduct.id = uuid.v4();

    await sizeDatabase.set(data: kProduct).then((_) async {
      await LoggerService.save(
        logType: LogType.product,
        actionType: ActionType.create,
        itemId: kProduct.id,
        newValue: jsonEncode(kProduct.toJson()),
      );

      state.ref!.invalidate(productsProvider);
      closeLoading();
      if (onClose != null) onClose!();
    });

    await LocalChanges.instance.saveChange(
      event: ProductEvent.PRODUCT_IMAGE_UPDATED,
      entity: Entity.PRODUCT,
      objectId: kProduct.id,
    );
  }

  @override
  Future<void> delete(key, {void Function()? c}) async {
    showConfirmDialog(
      context: context,
      title: AppLocales.deleteProductQuestion.tr(),
      onConfirm: () async {
        showAppLoadingDialog(context);
        ProductDatabase sizeDatabase = ProductDatabase();
        await sizeDatabase.delete(key: key).then((_) async {
          await LoggerService.save(
            logType: LogType.product,
            actionType: ActionType.delete,
            itemId: key,
          );

          await RecipeDatabase().deleteRecipe(key);
          state.ref!.invalidate(productsProvider);
          state.ref!.invalidate(recipesProvider);
          closeLoading();
          if (c != null) c();
        });
      },
    );
  }

  @override
  Future<void> update(data, key) async {
    data as Product;

    if (data.name.isEmpty) return error(AppLocales.productNameInputError.tr());
    showAppLoadingDialog(context);

    Product kProduct = data;
    List<String> kImages = [];
    final images = data.images;

    for (final item in images ?? []) {
      try {
        final path = await ImageService.copyImageToAppFolder(item.toString());
        kImages.add(path);
      } catch (error) {
        log("image update error: ", error: error);
      }
    }

    kProduct.images = kImages;
    final newImage = kProduct.images?.firstOrNull;
    if (newImage != data.oldImage && newImage != null) {
      await LocalChanges.instance.saveChange(
        event: ProductEvent.PRODUCT_IMAGE_UPDATED,
        entity: Entity.PRODUCT,
        objectId: kProduct.id,
      );

      kProduct.oldImage = kImages.firstOrNull;
    }

    ProductDatabase sizeDatabase = ProductDatabase();
    await sizeDatabase.update(data: kProduct, key: data.id).then((_) async {
      await LoggerService.save(
        logType: LogType.product,
        actionType: ActionType.update,
        itemId: kProduct.id,
        newValue: jsonEncode(kProduct.toJson()),
      );

      await _onUpdateChanges(kProduct);
      state.ref!.invalidate(productsProvider);
      closeLoading();
      if (onClose != null) onClose!();
    });
  }

  static Future<void> onDeleteProduct({
    required BuildContext context,
    required AppModel state,
    required dynamic id,
  }) async {
    ProductController controller =
        ProductController(context: context, state: state);
    await controller.delete(id);
  }
}
