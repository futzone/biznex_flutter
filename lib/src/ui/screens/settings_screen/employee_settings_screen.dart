import 'dart:developer';

import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/employee_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/database/changes_database/changes_database.dart';
import 'package:biznex/src/core/model/app_changes_model.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';

class EmployeeSettingsScreen extends HookConsumerWidget {
  const EmployeeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final employee = ref.watch(currentEmployeeProvider);
    final pincode = useTextEditingController();
    final phone = useTextEditingController(text: employee.phone);
    final fullname = useTextEditingController(text: employee.fullname);
    final pincodeNew = useTextEditingController();

    return AppStateWrapper(builder: (theme, state) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            4.h,
            AppText.$18Bold(AppLocales.employeeNameLabel.tr()),
            8.h,
            AppTextField(title: AppLocales.employeeNameHint.tr(), controller: fullname, theme: theme),
            24.h,
            AppText.$18Bold(AppLocales.employeePhoneLabel.tr()),
            8.h,
            AppTextField(title: AppLocales.employeePhoneHint.tr(), controller: phone, theme: theme),
            24.h,
            AppText.$18Bold(AppLocales.oldPincodeLabel.tr()),
            8.h,
            AppTextField(title: AppLocales.oldPincodeHint.tr(), controller: pincode, theme: theme, maxLength: 4),
            24.h,
            AppText.$18Bold(AppLocales.newPincodeLabel.tr()),
            8.h,
            AppTextField(title: AppLocales.enterNewPincode.tr(), controller: pincodeNew, theme: theme, maxLength: 4),
            24.h,
            ConfirmCancelButton(
              confirmText: AppLocales.save.tr(),
              onConfirm: () async {
                log(employee.toJson().toString());
                log(pincode.text.trim());
                log(pincodeNew.text.trim());

                if (employee.roleName.toString().toLowerCase() == "admin") {
                  if (state.pincode != pincode.text.trim() && pincodeNew.text.trim().length == 4) {
                    ShowToast.error(context, AppLocales.incorrectPincode.tr());
                    return;
                  }

                  AppModel app = state;
                  app.pincode = pincodeNew.text.trim();
                  await AppStateDatabase().updateApp(app).then((_) async {
                    ref.invalidate(appStateProvider);
                    ChangesDatabase changesDatabase = ChangesDatabase();
                    await changesDatabase.set(
                      data: Change(
                        database: "app",
                        method: "update",
                        itemId: "pincode",
                        data: app.pincode ,
                      ),
                    );
                    AppRouter.close(context);
                    ShowToast.success(context, AppLocales.update.tr());
                  });
                  return;
                }

                if (employee.pincode != pincode.text.trim() && pincodeNew.text.trim().length == 4) {
                  ShowToast.error(context, AppLocales.incorrectPincode.tr());
                  return;
                }

                EmployeeController employeeController = EmployeeController(context: context, state: state);
                Employee updateEmployee = employee;
                if (employee.pincode == pincode.text.trim() && pincodeNew.text.trim().length == 4) {
                  updateEmployee.pincode = pincodeNew.text;
                }

                updateEmployee.phone = phone.text.trim();
                updateEmployee.fullname = fullname.text.trim();
                ref.read(currentEmployeeProvider.notifier).update((state) => updateEmployee);
                employeeController.update(updateEmployee, employee.id);
              },
            ),
          ],
        ),
      );
    });
  }
}
