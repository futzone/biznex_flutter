import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/app_controller.dart';
import 'package:biznex/src/core/database/product_params_database/product_size_database.dart';
import 'package:biznex/src/core/model/product_params_models/product_size.dart';
import 'package:biznex/src/providers/product_size_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_confirm_dialog.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';

class ProductSizeController extends AppController {
  ProductSizeController({required super.context, required super.state});

  @override
  Future<void> create(data) async {
    data as ProductSize;
    if (data.name.isEmpty) return error(AppLocales.productSizeInputError.tr());
    showAppLoadingDialog(context);
    ProductSizeDatabase sizeDatabase = ProductSizeDatabase();
    await sizeDatabase.set(data: data).then((_) {
      state.ref!.invalidate(productSizeProvider);
      closeLoading();
      closeLoading();
    });
  }

  @override
  Future<void> delete(key) async {
    showConfirmDialog(
      context: context,
      title: AppLocales.deleteSizeRequest.tr(),
      onConfirm: () async {
        showAppLoadingDialog(context);
        ProductSizeDatabase sizeDatabase = ProductSizeDatabase();
        await sizeDatabase.delete(key: key).then((_) {
          state.ref!.invalidate(productSizeProvider);
          closeLoading();
        });
      },
    );
  }

  @override
  Future<void> update(data, key) async {
    data as ProductSize;
    if (data.name.isEmpty) return error(AppLocales.productSizeInputError.tr());
    showAppLoadingDialog(context);
    ProductSizeDatabase sizeDatabase = ProductSizeDatabase();
    await sizeDatabase.update(data: data, key: data.id).then((_) {
      state.ref!.invalidate(productSizeProvider);
      closeLoading();
      closeLoading();
    });
  }
}
