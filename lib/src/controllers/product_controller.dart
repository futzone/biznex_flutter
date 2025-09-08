import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/app_controller.dart';
import 'package:biznex/src/core/database/product_database/product_database.dart';
import 'package:biznex/src/core/model/product_models/product_model.dart';
import 'package:biznex/src/core/services/image_service.dart';
import 'package:biznex/src/providers/products_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_confirm_dialog.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';

class ProductController extends AppController {
  final void Function()? onClose;

  ProductController({this.onClose, required super.context, required super.state});

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
      } catch (_) {}
    }

    kProduct.images = kImages;

    ProductDatabase sizeDatabase = ProductDatabase();
    // for (int i = 0; i < 5000; i++) {
    //   await sizeDatabase.set(data: data);
    // }

    await sizeDatabase.set(data: kProduct).then((_) {
      state.ref!.invalidate(productsProvider);
      closeLoading();
      if (onClose != null) onClose!();
    });
  }

  @override
  Future<void> delete(key, {void Function()? c}) async {
    showConfirmDialog(
      context: context,
      title: AppLocales.deleteProductQuestion.tr(),
      onConfirm: () async {
        showAppLoadingDialog(context);
        ProductDatabase sizeDatabase = ProductDatabase();
        await sizeDatabase.delete(key: key).then((_) {
          state.ref!.invalidate(productsProvider);
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
      } catch (_) {}
    }

    kProduct.images = kImages;
    ProductDatabase sizeDatabase = ProductDatabase();
    await sizeDatabase.update(data: kProduct, key: data.id).then((_) {
      state.ref!.invalidate(productsProvider);
      closeLoading();
      if (onClose != null) onClose!();
    });
  }

  static Future<void> onDeleteProduct({required BuildContext context, required AppModel state, required dynamic id}) async {
    ProductController controller = ProductController(context: context, state: state);
    await controller.delete(id);
  }
}
