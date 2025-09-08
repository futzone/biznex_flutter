import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/app_controller.dart';
import 'package:biznex/src/core/database/product_params_database/product_measure_database.dart';
import 'package:biznex/src/core/model/product_params_models/product_measure.dart';
import 'package:biznex/src/ui/widgets/custom/app_confirm_dialog.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';
import '../providers/product_measure_provider.dart';

class ProductMeasureController extends AppController {
  ProductMeasureController({required super.context, required super.state});

  @override
  Future<void> create(data) async {
    data as ProductMeasure;
    if (data.name.isEmpty) return error(AppLocales.productMeasureInputError.tr());
    showAppLoadingDialog(context);
    ProductMeasureDatabase sizeDatabase = ProductMeasureDatabase();
    await sizeDatabase.set(data: data).then((_) {
      state.ref!.invalidate(productMeasureProvider);
      closeLoading();
      closeLoading();
    });
  }

  @override
  Future<void> delete(key) async {
    showConfirmDialog(
      context: context,
      title: AppLocales.deleteMeasureQuestionText.tr(),
      onConfirm: () async {
        showAppLoadingDialog(context);
        ProductMeasureDatabase sizeDatabase = ProductMeasureDatabase();
        await sizeDatabase.delete(key: key).then((_) {
          state.ref!.invalidate(productMeasureProvider);
          closeLoading();
        });
      },
    );
  }

  @override
  Future<void> update(data, key) async {
    data as ProductMeasure;
    if (data.name.isEmpty) return error(AppLocales.productMeasureInputError.tr());
    showAppLoadingDialog(context);
    ProductMeasureDatabase sizeDatabase = ProductMeasureDatabase();
    await sizeDatabase.update(data: data, key: data.id).then((_) {
      state.ref!.invalidate(productMeasureProvider);
      closeLoading();
      closeLoading();
    });
  }
}
