import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/app_controller.dart';
import 'package:biznex/src/core/database/product_params_database/product_color_database.dart';
import 'package:biznex/src/core/model/product_params_models/product_color.dart';
import 'package:biznex/src/providers/product_color_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_confirm_dialog.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';

class ProductColorController extends AppController {
  ProductColorController({required super.context, required super.state});

  @override
  Future<void> create(data) async {
    data as ProductColor;
    if (data.name.isEmpty) return error(AppLocales.productColorNameInputError.tr());
    showAppLoadingDialog(context);
    ProductColorDatabase database = ProductColorDatabase();
    await database.set(data: data).then((_) {
      state.ref!.invalidate(productColorProvider);
      closeLoading();
      closeLoading();
    });
  }

  @override
  Future<void> delete(key) async {
    showConfirmDialog(
      context: context,
      title: AppLocales.deleteProductColorQueastion.tr(),
      onConfirm: () async {
        showAppLoadingDialog(context);
        ProductColorDatabase database = ProductColorDatabase();
        await database.delete(key: key).then((_) {
          state.ref!.invalidate(productColorProvider);
          closeLoading();
        });
      },
    );
  }

  @override
  Future<void> update(data, key) async {
    data as ProductColor;
    if (data.name.isEmpty) return error(AppLocales.productColorNameInputError.tr());

    showAppLoadingDialog(context);
    ProductColorDatabase database = ProductColorDatabase();
    await database.update(data: data, key: data.id).then((_) {
      state.ref!.invalidate(productColorProvider);
      closeLoading();
      closeLoading();
    });
  }
}
