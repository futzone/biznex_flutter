import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/app_controller.dart';
import 'package:biznex/src/core/database/employee_database/employee_database.dart';
import 'package:biznex/src/core/database/employee_database/role_database.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/employee_models/role_model.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_confirm_dialog.dart';
import 'package:biznex/src/ui/widgets/custom/app_loading.dart';

class EmployeeController extends AppController {
  EmployeeController({required super.context, required super.state});

  @override
  Future<void> create(data) async {
    data as Employee;
    if (data.fullname.isEmpty) return error(AppLocales.nameInputError.tr());
    showAppLoadingDialog(context);
    EmployeeDatabase sizeDatabase = EmployeeDatabase();
    await sizeDatabase.set(data: data).then((_) {
      state.ref!.invalidate(employeeProvider);
      closeLoading();
      closeLoading();
    });
  }

  @override
  Future<void> delete(key) async {
    showConfirmDialog(
      context: context,
      title: AppLocales.deleteEmployeeRequest.tr(),
      onConfirm: () async {
        showAppLoadingDialog(context);
        EmployeeDatabase sizeDatabase = EmployeeDatabase();
        await sizeDatabase.delete(key: key).then((_) {
          state.ref!.invalidate(employeeProvider);
          closeLoading();
        });
      },
    );
  }

  @override
  Future<void> update(data, key) async {
    data as Employee;
    if (data.fullname.isEmpty) return error(AppLocales.nameInputError.tr());
    showAppLoadingDialog(context);
    EmployeeDatabase sizeDatabase = EmployeeDatabase();
    await sizeDatabase.update(data: data, key: data.id).then((_) {
      state.ref!.invalidate(employeeProvider);
      closeLoading();
      closeLoading();
    });
  }

  Future<void> createRole(data) async {
    data as Role;
    if (data.name.isEmpty) return error(AppLocales.nameInputError.tr());
    showAppLoadingDialog(context);
    RoleDatabase sizeDatabase = RoleDatabase();
    await sizeDatabase.set(data: data).then((_) {
      state.ref!.invalidate(roleProvider);
      closeLoading();
      closeLoading();
    });
  }

  Future<void> deleteRole(key) async {
    showConfirmDialog(
      context: context,
      title: AppLocales.deleteRoleQuestion.tr(),
      onConfirm: () async {
        showAppLoadingDialog(context);
        RoleDatabase sizeDatabase = RoleDatabase();
        await sizeDatabase.delete(key: key).then((_) {
          state.ref!.invalidate(roleProvider);
          closeLoading();
        });
      },
    );
  }

  Future<void> updateRole(data, key) async {
    data as Role;
    if (data.name.isEmpty) return error(AppLocales.nameInputError.tr());
    showAppLoadingDialog(context);
    RoleDatabase sizeDatabase = RoleDatabase();
    await sizeDatabase.update(data: data, key: data.id).then((_) {
      state.ref!.invalidate(roleProvider);
      closeLoading();
      closeLoading();
    });
  }
}
