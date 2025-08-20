import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/app_controller.dart';
import 'package:biznex/src/core/database/product_params_database/product_information_database.dart';
import 'package:biznex/src/core/model/product_params_models/product_info.dart';
import 'package:biznex/src/providers/product_information_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_confirm_dialog.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';

class ProductInfoController extends AppController {
  ProductInfoController({required super.context, required super.state});

  @override
  Future<void> create(data) async {
    data as ProductInfo;
    if (data.name.isEmpty) return error(AppLocales.productInfoKeyError.tr());
    if (data.data.isEmpty) return error(AppLocales.productInfoValueError.tr());
    showAppLoadingDialog(context);
    ProductInformationDatabase database = ProductInformationDatabase();
    await database.set(data: data).then((_) {
      state.ref!.invalidate(productInformationProvider);
      closeLoading();
      closeLoading();
    });
  }

  @override
  Future<void> delete(key) async {
    showConfirmDialog(
      context: context,
      title: AppLocales.deleteProductInformationQuestion.tr(),
      onConfirm: () async {
        showAppLoadingDialog(context);
        ProductInformationDatabase database = ProductInformationDatabase();
        await database.delete(key: key).then((_) {
          state.ref!.invalidate(productInformationProvider);
          closeLoading();
        });
      },
    );
  }

  @override
  Future<void> update(data, key) async {
    data as ProductInfo;
    if (data.name.isEmpty) return error(AppLocales.productInfoKeyError.tr());
    if (data.data.isEmpty) return error(AppLocales.productInfoValueError.tr());
    showAppLoadingDialog(context);
    ProductInformationDatabase database = ProductInformationDatabase();
    await database.update(data: data, key: data.id).then((_) {
      state.ref!.invalidate(productInformationProvider);
      closeLoading();
      closeLoading();
    });
  }
}
