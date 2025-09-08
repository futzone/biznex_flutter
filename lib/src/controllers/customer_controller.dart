import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/app_controller.dart';
import 'package:biznex/src/core/database/customer_database/customer_database.dart';
import 'package:biznex/src/core/model/other_models/customer_model.dart';
import 'package:biznex/src/providers/customer_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_confirm_dialog.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';

class CustomerController extends AppController {
  CustomerController({required super.context, required super.state});

  @override
  Future<void> create(data) async {
    data as Customer;
    if (data.name.isEmpty) return error(AppLocales.customerNameInputError.tr());
    showAppLoadingDialog(context);
    CustomerDatabase sizeDatabase = CustomerDatabase();
    await sizeDatabase.set(data: data).then((_) {
      state.ref!.invalidate(customerProvider);
      closeLoading();
      closeLoading();
    });
  }

  @override
  Future<void> delete(key) async {
    showConfirmDialog(
      context: context,
      title: AppLocales.deleteCustomerController.tr(),
      onConfirm: () async {
        showAppLoadingDialog(context);
        CustomerDatabase sizeDatabase = CustomerDatabase();
        await sizeDatabase.delete(key: key).then((_) {
          state.ref!.invalidate(customerProvider);
          closeLoading();
        });
      },
    );
  }

  @override
  Future<void> update(data, key) async {
    data as Customer;
    if (data.name.isEmpty) return error(AppLocales.customerNameInputError.tr());
    showAppLoadingDialog(context);
    CustomerDatabase sizeDatabase = CustomerDatabase();
    await sizeDatabase.update(data: data, key: data.id).then((_) {
      state.ref!.invalidate(customerProvider);
      closeLoading();
      closeLoading();
    });
  }
}
