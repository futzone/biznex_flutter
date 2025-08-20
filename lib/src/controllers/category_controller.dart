import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/app_controller.dart';
import 'package:biznex/src/core/database/category_database/category_database.dart';
import 'package:biznex/src/core/model/category_model/category_model.dart';
import 'package:biznex/src/providers/category_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_confirm_dialog.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';

class CategoryController extends AppController {
  CategoryController({required super.context, required super.state});

  @override
  Future<void> create(data) async {
    data as Category;
    if (data.name.isEmpty) return error(AppLocales.categoryNameInputError.tr());
    showAppLoadingDialog(context);
    CategoryDatabase sizeDatabase = CategoryDatabase();
    await sizeDatabase.set(data: data).then((_) {
      state.ref!.invalidate(categoryProvider);
      closeLoading();
      closeLoading();
    });
  }

  @override
  Future<void> delete(key) async {
    showConfirmDialog(
      context: context,
      title: AppLocales.deleteCategoryQuestion.tr(),
      onConfirm: () async {
        showAppLoadingDialog(context);
        CategoryDatabase sizeDatabase = CategoryDatabase();
        await sizeDatabase.delete(key: key).then((_) {
          state.ref!.invalidate(categoryProvider);
          closeLoading();
        });
      },
    );
  }

  @override
  Future<void> update(data, key) async {
    data as Category;
    if (data.name.isEmpty) return error(AppLocales.categoryNameInputError.tr());
    showAppLoadingDialog(context);
    CategoryDatabase sizeDatabase = CategoryDatabase();
    await sizeDatabase.update(data: data, key: data.id).then((_) {
      state.ref!.invalidate(categoryProvider);
      closeLoading();
      closeLoading();
    });
  }

  Future<void> forceUpdate(data, key) async {
    data as Category;
    if (data.name.isEmpty) return error(AppLocales.categoryNameInputError.tr());
    showAppLoadingDialog(context);
    CategoryDatabase sizeDatabase = CategoryDatabase();
    await sizeDatabase.update(data: data, key: data.id).then((_) {
      closeLoading();
      state.ref!.invalidate(categoryProvider);
    });
  }
}
