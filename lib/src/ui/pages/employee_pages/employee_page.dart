import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/employee_controller.dart';
import 'package:biznex/src/core/database/app_database/app_database.dart';
import 'package:biznex/src/core/extensions/app_responsive.dart';
import 'package:biznex/src/core/extensions/for_string.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/ui/screens/employee_screens/add_employee.dart';
import 'package:biznex/src/ui/screens/employee_screens/add_role.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_state_wrapper.dart';
import 'package:biznex/src/ui/widgets/dialogs/app_custom_dialog.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../core/model/employee_models/employee_model.dart';
import '../../../core/model/employee_models/role_model.dart';
import '../../widgets/helpers/app_text_field.dart';

class EmployeePage extends HookConsumerWidget {
  final ValueNotifier<AppBar> appbar;
  final ValueNotifier<FloatingActionButton?> floatingActionButton;

  const EmployeePage(this.floatingActionButton, {super.key, required this.appbar});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employeesScreen = useState(true);
    final searchController = useTextEditingController();
    final searchResultList = useState([]);
    final employeesListener = ref.watch(employeeProvider).value ?? [];
    final rolesListener = ref.watch(roleProvider).value ?? [];

    void onSearchQuery(String char) {
      searchResultList.value = [
        ...employeesListener.where((e) {
          return e.fullname.toLowerCase().contains(char.toLowerCase());
        }),
        ...rolesListener.where((e) {
          return e.name.toLowerCase().contains(char.toLowerCase());
        }),
      ];
    }

    return AppStateWrapper(
      builder: (theme, state) {
        return Scaffold(
          floatingActionButton: WebButton(
            onPressed: () {
              if (employeesScreen.value) {
                showDesktopModal(context: context, body: AddEmployee());
                return;
              }

              showDesktopModal(context: context, body: AddRole());
            },
            builder: (focused) => AnimatedContainer(
              duration: theme.animationDuration,
              height: focused ? 80 : 64,
              width: focused ? 80 : 64,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xff5CF6A9), width: 2),
                color: theme.mainColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    spreadRadius: 3,
                    blurRadius: 5,
                    offset: Offset(3, 3),
                  )
                ],
              ),
              child: Center(
                child: Icon(
                  Iconsax.add_copy,
                  color: Colors.white,
                  size: focused ? 40 : 32,
                ),
              ),
            ),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: Dis.only(lr: context.w(24), top: context.h(24)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: context.w(16),
                  children: [
                    Expanded(
                      child: Text(
                        AppLocales.employees.tr(),
                        style: TextStyle(
                          fontSize: context.s(24),
                          fontFamily: mediumFamily,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    0.w,
                    SizedBox(
                      width: context.w(400),
                      child: AppTextField(
                        prefixIcon: Icon(Iconsax.search_normal_copy),
                        title: AppLocales.search.tr(),
                        controller: searchController,
                        onChanged: onSearchQuery,
                        theme: theme,
                        fillColor: Colors.white,
                        // useBorder: false,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: Dis.only(
                  lr: context.w(24),
                  top: context.h(24),
                  bottom: context.h(16),
                ),
                padding: 4.all,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  spacing: 16,
                  children: [
                    Expanded(
                      child: SimpleButton(
                        onPressed: () => employeesScreen.value = true,
                        child: Container(
                          padding: 12.all,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: employeesScreen.value ? theme.mainColor : null,
                          ),
                          child: Center(
                            child: Text(
                              AppLocales.employees.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: mediumFamily,
                                color: employeesScreen.value ? Colors.white : theme.secondaryTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: SimpleButton(
                        onPressed: () => employeesScreen.value = false,
                        child: Container(
                          padding: 12.all,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: !employeesScreen.value ? theme.mainColor : null,
                          ),
                          child: Center(
                            child: Text(
                              AppLocales.roles.tr(),
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: mediumFamily,
                                color: !employeesScreen.value ? Colors.white : theme.secondaryTextColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (searchResultList.value.isEmpty && searchController.text.trim().isNotEmpty) Expanded(child: AppEmptyWidget()),
              if (employeesScreen.value)
                Expanded(
                  child: state.whenProviderData(
                    provider: employeeProvider,
                    builder: (emp) {
                      List<Employee> employees = [];
                      if (searchController.text.trim().isNotEmpty) {
                        employees = [...searchResultList.value.whereType<Employee>()];
                      } else {
                        employees = emp;
                      }

                      return ListView.builder(
                        padding: context.w(24).lr,
                        itemCount: employees.length,
                        itemBuilder: (context, index) {
                          final Employee employee = employees[index];
                          return Container(
                            margin: 16.bottom,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            padding: 12.all,
                            child: Row(
                              spacing: 12,
                              children: [
                                Container(
                                  padding: 8.all,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: theme.scaffoldBgColor,
                                  ),
                                  child: Text(
                                    employee.fullname.initials,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontFamily: boldFamily,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    spacing: 4,
                                    children: [
                                      Text(
                                        employee.fullname,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: mediumFamily,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        employee.roleName,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: regularFamily,
                                          fontWeight: FontWeight.w500,
                                          color: theme.secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SimpleButton(
                                  onPressed: () {
                                    showDesktopModal(context: context, body: AddEmployee(employee: employee));
                                  },
                                  child: Container(
                                    height: 36,
                                    width: 36,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: theme.scaffoldBgColor,
                                    ),
                                    child: Icon(
                                      Iconsax.edit_copy,
                                      color: theme.secondaryTextColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                SimpleButton(
                                  onPressed: () {
                                    EmployeeController ec = EmployeeController(context: context, state: state);
                                    ec.delete(employee.id);
                                  },
                                  child: Container(
                                    height: 36,
                                    width: 36,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: theme.scaffoldBgColor,
                                    ),
                                    child: Icon(
                                      Iconsax.trash_copy,
                                      color: theme.red,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                )
              else
                Expanded(
                  child: state.whenProviderData(
                    provider: roleProvider,
                    builder: (roles) {
                      List<Role> employees = [];
                      if (searchController.text.trim().isNotEmpty) {
                        employees = [...searchResultList.value.whereType<Role>()];
                      } else {
                        employees = roles;
                      }
                      return ListView.builder(
                        padding: context.w(24).lr,
                        itemCount: employees.length,
                        itemBuilder: (context, index) {
                          final Role employee = employees[index];
                          return Container(
                            margin: 16.bottom,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                            ),
                            padding: 12.all,
                            child: Row(
                              spacing: 12,
                              children: [
                                Container(
                                  padding: 8.all,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: theme.scaffoldBgColor,
                                  ),
                                  child: Text(
                                    employee.name.initials,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontFamily: boldFamily,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    spacing: 4,
                                    children: [
                                      Text(
                                        employee.name,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: mediumFamily,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        employee.permissions.join(", ").capitalize,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: regularFamily,
                                          fontWeight: FontWeight.w500,
                                          color: theme.secondaryTextColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SimpleButton(
                                  onPressed: () {
                                    showDesktopModal(context: context, body: AddRole(role: employee));
                                  },
                                  child: Container(
                                    height: 36,
                                    width: 36,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: theme.scaffoldBgColor,
                                    ),
                                    child: Icon(
                                      Iconsax.edit_copy,
                                      color: theme.secondaryTextColor,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                SimpleButton(
                                  onPressed: () {
                                    EmployeeController ec = EmployeeController(context: context, state: state);
                                    ec.deleteRole(employee.id);
                                  },
                                  child: Container(
                                    height: 36,
                                    width: 36,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: theme.scaffoldBgColor,
                                    ),
                                    child: Icon(
                                      Iconsax.trash_copy,
                                      color: theme.red,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
