import 'dart:developer';
import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/employee_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/database/app_database/app_state_database.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/providers/app_state_provider.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/ui/screens/settings_screen/language_settings_screen.dart';
import 'package:biznex/src/ui/screens/settings_screen/network_interface_screen.dart';
import 'package:biznex/src/ui/screens/settings_screen/settings_page_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/custom/app_toast.dart';
import 'package:biznex/src/ui/widgets/helpers/app_back_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import '../../widgets/dialogs/app_custom_dialog.dart';
import 'app_updater_screen.dart';

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
            Row(
              spacing: 16,
              children: [
                AppBackButton(),
                Expanded(
                  child: Text(
                    employee.fullname,
                    style: TextStyle(
                      fontSize: context.s(20),
                      fontFamily: boldFamily,
                    ),
                  ),
                ),
                state.whenProviderData(
                  provider: appUpdaterProvider,
                  builder: (data) {
                    final current = data['current'];
                    final version = data['version'];
                    return SimpleButton(
                      onLongPress: () {
                        showDesktopModal(
                          body: NetworkConnection(),
                          context: context,
                        );
                      },
                      onPressed: () {
                        showDesktopModal(
                          context: context,
                          body: AppUpdaterScreen(
                            version: version,
                            theme: theme,
                          ),
                        );
                      },
                      child: Container(
                        padding: Dis.only(lr: 12, tb: 12),
                        decoration: BoxDecoration(
                          // color: theme.accentColor,
                          border: Border.all(color: theme.accentColor),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "${AppLocales.appVersions.tr()}: v$current",
                              style: TextStyle(
                                fontSize: context.s(14),
                                fontFamily: mediumFamily,
                                color: Colors.black,
                              ),
                            ),
                            12.w,
                            Icon(Icons.sync)
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            24.h,
            if (state.apiUrl == null) ...[
              AppText.$18Bold(AppLocales.employeeNameLabel.tr()),
              8.h,
              AppTextField(
                title: AppLocales.employeeNameHint.tr(),
                controller: fullname,
                theme: theme,
              ),
              24.h,
              AppText.$18Bold(AppLocales.employeePhoneLabel.tr()),
              8.h,
              AppTextField(
                title: AppLocales.employeePhoneHint.tr(),
                controller: phone,
                theme: theme,
              ),
              24.h,
              AppText.$18Bold(AppLocales.oldPincodeLabel.tr()),
              8.h,
              AppTextField(
                title: AppLocales.oldPincodeHint.tr(),
                controller: pincode,
                theme: theme,
                maxLength: 4,
              ),
              24.h,
              AppText.$18Bold(AppLocales.newPincodeLabel.tr()),
              8.h,
              AppTextField(
                title: AppLocales.enterNewPincode.tr(),
                controller: pincodeNew,
                theme: theme,
                maxLength: 4,
              ),
              24.h,
            ],
            AppLanguageBar(),
            24.h,
            NetworkInterfaceScreen(),
            24.h,
            ConfirmCancelButton(
              confirmText: AppLocales.save.tr(),
              onConfirm: () async {
                log(employee.toJson().toString());
                log(pincode.text.trim());
                log(pincodeNew.text.trim());

                if (employee.roleName.toString().toLowerCase() == "admin") {
                  if (state.pincode != pincode.text.trim() &&
                      pincodeNew.text.trim().length == 4) {
                    ShowToast.error(context, AppLocales.incorrectPincode.tr());
                    return;
                  }

                  AppModel app = state;
                  app.pincode = pincodeNew.text.trim();
                  await AppStateDatabase().updateApp(app).then((_) async {
                    ref.invalidate(appStateProvider);

                    AppRouter.close(context);
                    ShowToast.success(context, AppLocales.update.tr());
                  });
                  return;
                }

                if (employee.pincode != pincode.text.trim() &&
                    pincodeNew.text.trim().length == 4) {
                  ShowToast.error(context, AppLocales.incorrectPincode.tr());
                  return;
                }

                EmployeeController employeeController =
                    EmployeeController(context: context, state: state);
                Employee updateEmployee = employee;
                if (employee.pincode == pincode.text.trim() &&
                    pincodeNew.text.trim().length == 4) {
                  updateEmployee.pincode = pincodeNew.text;
                }

                updateEmployee.phone = phone.text.trim();
                updateEmployee.fullname = fullname.text.trim();
                ref
                    .read(currentEmployeeProvider.notifier)
                    .update((state) => updateEmployee);
                employeeController.update(updateEmployee, employee.id);
              },
            ),
          ],
        ),
      );
    });
  }
}
