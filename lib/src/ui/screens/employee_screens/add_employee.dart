import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/employee_controller.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/core/model/employee_models/role_model.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/ui/screens/employee_screens/add_role.dart';
import 'package:biznex/src/ui/widgets/custom/app_custom_popup_menu.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AddEmployee extends HookConsumerWidget {
  final Employee? employee;

  const AddEmployee({super.key, this.employee});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController(text: employee?.fullname);
    final phoneController = useTextEditingController(text: employee?.fullname);
    final pincode = useTextEditingController(text: employee?.pincode);
    final selectedRole = useState<Role?>(null);
    return AppStateWrapper(builder: (theme, state) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppText.$18Bold(AppLocales.employeeNameLabel.tr(), padding: 8.bottom),
            AppTextField(
              title: AppLocales.employeeNameHint.tr(),
              controller: nameController,
              theme: theme,
            ),
            20.h,
            AppText.$18Bold(AppLocales.employeePhoneLabel.tr(), padding: 8.bottom),
            AppTextField(
              title: AppLocales.employeePhoneHint.tr(),
              controller: phoneController,
              theme: theme,
            ),
            20.h,
            AppText.$18Bold(AppLocales.enterNewPincode.tr(), padding: 8.bottom),
            AppTextField(
              maxLength: 4,
              title: AppLocales.enterNewPincode.tr(),
              controller: pincode,
              theme: theme,
              textInputType: TextInputType.number,
            ),
            20.h,
            AppText.$18Bold(AppLocales.employeeRoleLabel.tr(), padding: 8.bottom),
            state.whenProviderData(
              provider: roleProvider,
              builder: (roles) {
                roles as List<Role>;
                return CustomPopupMenu(
                  theme: theme,
                  children: [
                    for (final item in roles)
                      CustomPopupItem(
                        title: item.name,
                        icon: Icons.admin_panel_settings_outlined,
                        onPressed: () => selectedRole.value = item,
                      ),
                    CustomPopupItem(
                      title: AppLocales.addRole.tr(),
                      icon: Icons.add,
                      onPressed: () => showDesktopModal(context: context, body: AddRole()),
                    ),
                  ],
                  child: IgnorePointer(
                    ignoring: true,
                    child: AppTextField(
                      onlyRead: true,
                      title: AppLocales.employeeRoleHint.tr(),
                      controller: TextEditingController(text: selectedRole.value?.name),
                      theme: theme,
                    ),
                  ),
                );
              },
            ),
            24.h,
            ConfirmCancelButton(
              onConfirm: () {
                EmployeeController employeeController = EmployeeController(context: context, state: state);
                if (employee == null) {
                  if (selectedRole.value == null) {
                    employeeController.error(AppLocales.roleInputError.tr());
                    return;
                  }
                  Employee kEmployee = Employee(
                    fullname: nameController.text.tr(),
                    roleId: selectedRole.value?.id ?? '',
                    roleName: selectedRole.value?.name ?? '',
                    phone: phoneController.text,
                    pincode: pincode.text.trim(),
                  );

                  employeeController.create(kEmployee);
                  return;
                }

                if (selectedRole.value == null) {
                  employeeController.error(AppLocales.roleInputError.tr());
                  return;
                }
                Employee kEmployee = employee!;
                kEmployee.roleId = selectedRole.value!.id;
                kEmployee.roleName = selectedRole.value!.name;
                kEmployee.phone = phoneController.text;
                kEmployee.fullname = nameController.text;
                kEmployee.pincode = pincode.text;
                employeeController.update(kEmployee, employee?.id);
              },
            ),
          ],
        ),
      );
    });
  }
}
