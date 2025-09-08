import 'package:biznex/biznex.dart';
import 'package:biznex/src/controllers/employee_controller.dart';
import 'package:biznex/src/core/config/router.dart';
import 'package:biznex/src/core/extensions/for_double.dart';
import 'package:biznex/src/core/model/employee_models/employee_model.dart';
import 'package:biznex/src/providers/employee_provider.dart';
import 'package:biznex/src/ui/screens/employee_screens/add_employee.dart';
import 'package:biznex/src/ui/screens/other_screens/header_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_empty_widget.dart';
import 'package:biznex/src/ui/widgets/custom/app_error_screen.dart';
import 'package:biznex/src/ui/widgets/custom/app_list_tile.dart';
import 'package:biznex/src/ui/widgets/helpers/app_loading_screen.dart';
import 'package:biznex/src/ui/widgets/helpers/app_simple_button.dart';
import '../../widgets/dialogs/app_custom_dialog.dart';

class EmployeeReponsive extends AppStatelessWidget {
  final bool useBack;

  const EmployeeReponsive({super.key, this.useBack = false});

  @override
  Widget builder(context, theme, ref, state) {
    return Column(
      children: [
        Row(
          children: [
            if (useBack)
              SimpleButton(
                child: Icon(Icons.arrow_back_ios_new),
                onPressed: () => AppRouter.close(context),
              ),
            if (useBack) 24.w,
            Expanded(
              child: HeaderScreen(
                title: AppLocales.employees.tr(),
                onAddPressed: () => showDesktopModal(
                  context: context,
                  body: AddEmployee(),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: ref.watch(employeeProvider).when(
                loading: () => AppLoadingScreen(),
                error: RefErrorScreen,
                data: (data) {
                  if (data.isEmpty) return AppEmptyWidget();
                  return ListView.builder(
                    padding: 8.top,
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final Employee info = data[index];
                      return AppListTile(
                        title: info.fullname,
                        theme: theme,
                        leadingIcon: Icons.person,
                        onDelete: () {
                          EmployeeController eController = EmployeeController(context: context, state: state);
                          eController.delete(info.id);
                        },
                        onEdit: () {
                          showDesktopModal(context: context, body: AddEmployee(employee: info));
                        },
                      );
                    },
                  );
                },
              ),
        ),
      ],
    );
  }
}
