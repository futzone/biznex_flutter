import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/employee_controller.dart';
import 'package:biznex/src/core/model/employee_models/role_model.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/custom/app_text_widgets.dart';
import 'package:biznex/src/ui/widgets/helpers/app_decorated_button.dart';
import 'package:biznex/src/ui/widgets/helpers/app_text_field.dart';

class AddRole extends StatefulWidget {
  final Role? role;

  const AddRole({super.key, this.role});

  @override
  State<AddRole> createState() => _AddRoleState();
}

class _AddRoleState extends State<AddRole> {
  final nameController = TextEditingController();
  final permissions = [];

  void _initRoleState() {
    if (widget.role != null) {
      permissions.addAll(widget.role!.permissions);
      nameController.text = widget.role!.name;
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _initRoleState();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateWrapper(builder: (theme, state) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AppText.$18Bold(AppLocales.roleNameLabel.tr(), padding: 8.bottom),
            AppTextField(
              title: AppLocales.roleNameHint.tr(),
              controller: nameController,
              theme: theme,
            ),
            24.h,
            AppText.$18Bold(AppLocales.rolePermissionsLabel.tr(), padding: 8.bottom),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in Role.permissionList)
                  HookBuilder(
                    builder: (context) {
                      return ChoiceChip(
                        label: Text(item.tr()),
                        selected: permissions.contains(item),
                        onSelected: (selected) {
                          if (!permissions.contains(item)) {
                            permissions.add(item);
                          } else {
                            permissions.remove(item);
                          }

                          setState(() {});
                        },
                      );
                    },
                  ),
              ],
            ),
            24.h,
            ConfirmCancelButton(
              onConfirm: () {
                EmployeeController employeeController = EmployeeController(context: context, state: state);
                if (widget.role == null) {
                  Role newRole = Role(
                    name: nameController.text.trim(),
                    permissions: permissions,
                  );
                  employeeController.createRole(newRole);
                  return;
                }

                Role newRole = widget.role!;
                newRole.name = nameController.text.trim();
                newRole.permissions = permissions;
                employeeController.updateRole(newRole, widget.role?.id);
              },
            ),
          ],
        ),
      );
    });
  }
}
